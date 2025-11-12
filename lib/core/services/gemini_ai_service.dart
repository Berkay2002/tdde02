import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import '../constants/app_constants.dart';
import '../constants/prompt_templates.dart';
import '../errors/ai_exceptions.dart';
import '../errors/rate_limit_exceptions.dart';
import 'rate_limiter_service.dart';

/// Service for running AI inference using Firebase AI Logic with Gemini API
///
/// This service uses Google's Gemini models via Firebase AI for cloud-based
/// multimodal AI inference. No local model downloads required.
///
/// **Rate Limiting**: Enforces per-user limits to prevent API quota abuse.
class GeminiAIService {
  final RateLimiterService _rateLimiter;
  GenerativeModel? _model;
  bool _isInitialized = false;

  GeminiAIService(this._rateLimiter);

  bool get isInitialized => _isInitialized;

  /// Initialize Firebase AI with Gemini model
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('GeminiAIService: Initializing Firebase AI with Gemini API');

      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        throw ModelLoadException(
          'Firebase has not been initialized. Call Firebase.initializeApp() first.',
        );
      }

      // Initialize Firebase AI with Google AI backend (Gemini Developer API)
      final ai = FirebaseAI.googleAI();

      // Create a GenerativeModel instance with multimodal support
      _model = ai.generativeModel(
        model: AppConstants.geminiModel,
        generationConfig: GenerationConfig(
          temperature: AppConstants.temperature,
          topK: AppConstants.topK,
          maxOutputTokens: AppConstants.maxTokens,
          responseMimeType: 'application/json', // JSON for structured output
        ),
      );

      _isInitialized = true;
      print(
        'GeminiAIService: Initialization successful with ${AppConstants.geminiModel}',
      );
    } catch (e) {
      print('GeminiAIService: Initialization failed: $e');
      throw ModelLoadException('Failed to initialize Gemini AI: $e');
    }
  }

  /// Detect ingredients from preprocessed image data using multimodal prompting
  /// Returns structured ingredient data with metadata
  ///
  /// **Rate Limiting**: Enforces hourly and daily limits per user.
  Future<List<Map<String, dynamic>>> detectIngredientsStructured(
    Uint8List imageData,
    String userId,
  ) async {
    if (!_isInitialized || _model == null) {
      throw ModelNotInitializedException('Model has not been initialized');
    }

    // Check rate limit BEFORE making API call
    await _rateLimiter.checkIngredientDetectionLimit(userId);

    try {
      print('GeminiAIService: Starting structured ingredient detection');

      final prompt = PromptTemplates.getIngredientDetectionPrompt();

      // Create multimodal content with image and text
      final content = [
        Content.multi([
          TextPart(prompt),
          InlineDataPart('image/jpeg', imageData),
        ]),
      ];

      // Generate response with timeout
      final response = await _generateWithTimeout(
        content: content,
        timeout: AppConstants.ingredientDetectionTimeout,
      );

      // Parse structured response
      final structuredIngredients =
          PromptTemplates.parseIngredientResponseStructured(response);

      print(
        'GeminiAIService: Detected ${structuredIngredients.length} ingredients with metadata',
      );

      // Log confidence distribution
      final confidenceCounts = <String, int>{};
      for (final item in structuredIngredients) {
        final conf = item['quantityConfidence']?.toString() ?? 'none';
        confidenceCounts[conf] = (confidenceCounts[conf] ?? 0) + 1;
      }
      print('Confidence distribution: $confidenceCounts');

      // Increment counter after successful API call
      await _rateLimiter.incrementIngredientDetection(userId);

      return structuredIngredients;
    } catch (e) {
      if (e is RateLimitException) {
        rethrow;
      }
      print('GeminiAIService: Structured ingredient detection failed: $e');
      throw InferenceException('Failed to detect ingredients: $e');
    }
  }

  /// Detect ingredients from preprocessed image data using multimodal prompting
  /// Returns simple list of ingredient names (legacy)
  ///
  /// **Rate Limiting**: Enforces hourly and daily limits per user.
  /// Throws [IngredientDetectionHourlyLimitException] or [IngredientDetectionDailyLimitException]
  /// if user has exceeded their quota.
  Future<List<String>> detectIngredients(
    Uint8List imageData,
    String userId,
  ) async {
    if (!_isInitialized || _model == null) {
      throw ModelNotInitializedException('Model has not been initialized');
    }

    // Check rate limit BEFORE making API call
    await _rateLimiter.checkIngredientDetectionLimit(userId);

    try {
      print('GeminiAIService: Starting ingredient detection');

      final prompt = PromptTemplates.getIngredientDetectionPrompt();

      // Create multimodal content with image and text
      final content = [
        Content.multi([
          TextPart(prompt),
          InlineDataPart('image/jpeg', imageData),
        ]),
      ];

      // Generate response with timeout
      final response = await _generateWithTimeout(
        content: content,
        timeout: AppConstants.ingredientDetectionTimeout,
      );

      // Try structured parsing first, fallback to simple list
      final structuredIngredients =
          PromptTemplates.parseIngredientResponseStructured(response);

      List<String> ingredients;
      if (structuredIngredients.isNotEmpty) {
        // Extract just the names for now (full objects stored separately)
        ingredients = structuredIngredients
            .map((item) => item['name'] as String? ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
        print(
          'Using structured ingredient data: ${structuredIngredients.length} items',
        );
      } else {
        // Fallback to simple text parsing
        ingredients = PromptTemplates.parseIngredientResponse(response);
        print('Using legacy ingredient parsing: ${ingredients.length} items');
      }

      print('GeminiAIService: Detected ${ingredients.length} ingredients');

      // Increment counter after successful API call
      await _rateLimiter.incrementIngredientDetection(userId);

      return ingredients;
    } catch (e) {
      if (e is RateLimitException) {
        rethrow; // Don't wrap rate limit exceptions
      }
      print('GeminiAIService: Ingredient detection failed: $e');
      throw InferenceException('Failed to detect ingredients: $e');
    }
  }

  /// Generate recipe from ingredients and preferences using text prompting
  ///
  /// **Rate Limiting**: Enforces hourly and daily limits per user.
  /// Throws [RecipeGenerationHourlyLimitException] or [RecipeGenerationDailyLimitException]
  /// if user has exceeded their quota.
  Future<Map<String, dynamic>> generateRecipe({
    required List<String> ingredients,
    required String userId,
    String? dietaryRestrictions,
    String? skillLevel,
    String? cuisinePreference,
    String measurementSystem = 'metric',
  }) async {
    if (!_isInitialized || _model == null) {
      throw ModelNotInitializedException('Model has not been initialized');
    }

    // Check rate limit BEFORE making API call
    await _rateLimiter.checkRecipeGenerationLimit(userId);

    try {
      print('GeminiAIService: Starting recipe generation');

      final prompt = PromptTemplates.getRecipeGenerationPrompt(
        ingredients: ingredients,
        dietaryRestrictions: dietaryRestrictions,
        skillLevel: skillLevel,
        cuisinePreference: cuisinePreference,
        measurementSystem: measurementSystem,
      );

      // Create text-only content
      final content = [Content.text(prompt)];

      // Generate response with timeout and retry
      final response = await _generateWithTimeoutAndRetry(
        content: content,
        timeout: AppConstants.recipeGenerationTimeout,
        maxRetries: AppConstants.maxRetries,
      );

      // Try structured JSON parsing first, fallback to legacy
      Map<String, dynamic> recipe;
      try {
        recipe = PromptTemplates.parseRecipeResponseStructured(response);
        print('Using structured recipe data');
      } catch (e) {
        print('Structured parsing failed, using legacy parser: $e');
        recipe = PromptTemplates.parseRecipeResponse(response);
      }

      print('GeminiAIService: Generated recipe: ${recipe['name']}');

      // Increment counter after successful API call
      await _rateLimiter.incrementRecipeGeneration(userId);

      return recipe;
    } catch (e) {
      if (e is RateLimitException) {
        rethrow; // Don't wrap rate limit exceptions
      }
      print('GeminiAIService: Recipe generation failed: $e');
      throw InferenceException('Failed to generate recipe: $e');
    }
  }

  /// Generate response with timeout and retry protection
  Future<String> _generateWithTimeoutAndRetry({
    required List<Content> content,
    required Duration timeout,
    int maxRetries = 0,
  }) async {
    int attempt = 0;
    Duration retryDelay = AppConstants.initialRetryDelay;

    while (true) {
      try {
        return await _generateWithTimeout(content: content, timeout: timeout);
      } catch (e) {
        attempt++;

        // Check if we should retry
        final shouldRetry =
            attempt <= maxRetries &&
            (e is InferenceTimeoutException ||
                e.toString().contains('network') ||
                e.toString().contains('connection'));

        if (!shouldRetry) {
          rethrow;
        }

        print(
          'GeminiAIService: Attempt $attempt failed: $e. Retrying in ${retryDelay.inSeconds}s...',
        );

        // Wait before retrying with exponential backoff
        await Future.delayed(retryDelay);
        retryDelay *= 2; // Double the delay for next retry
      }
    }
  }

  /// Generate response with timeout protection
  Future<String> _generateWithTimeout({
    required List<Content> content,
    required Duration timeout,
  }) async {
    try {
      final completer = Completer<String>();

      // Create timeout timer
      final timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.completeError(InferenceTimeoutException(timeout));
        }
      });

      // Start inference
      _generate(content: content)
          .then((result) {
            timer.cancel();
            if (!completer.isCompleted) {
              completer.complete(result);
            }
          })
          .catchError((error) {
            timer.cancel();
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          });

      return await completer.future;
    } catch (e) {
      if (e is InferenceTimeoutException) {
        rethrow;
      }
      throw InferenceException('Inference failed: $e');
    }
  }

  /// Core inference method using Firebase AI
  Future<String> _generate({required List<Content> content}) async {
    try {
      final response = await _model!.generateContent(content);

      // Check for safety/block reasons
      if (response.candidates.isEmpty) {
        print('GeminiAIService: No candidates returned');
        throw InferenceException('No response candidates generated');
      }

      final candidate = response.candidates.first;
      print('GeminiAIService: Finish reason: ${candidate.finishReason}');

      // Check if blocked by safety filters
      if (candidate.finishReason == FinishReason.safety) {
        print('GeminiAIService: Response blocked by safety filters');
        throw InferenceException('Response blocked by safety filters');
      }

      final text = response.text;
      if (text == null || text.isEmpty) {
        print(
          'GeminiAIService: Empty response text. Candidates: ${response.candidates.length}',
        );
        throw InferenceException('Received empty response from model');
      }

      return text;
    } catch (e) {
      print('GeminiAIService: Generation error: $e');
      throw InferenceException('Generation failed: $e');
    }
  }

  /// Generate response with streaming support
  ///
  /// Returns a stream of partial results as they are generated
  Stream<String> generateResponseStream({
    required String prompt,
    Uint8List? imageData,
  }) async* {
    if (!_isInitialized || _model == null) {
      throw ModelNotInitializedException('Model has not been initialized');
    }

    try {
      // Create content based on whether image is provided
      final content = imageData != null
          ? [
              Content.multi([
                TextPart(prompt),
                InlineDataPart('image/jpeg', imageData),
              ]),
            ]
          : [Content.text(prompt)];

      // Stream the response
      final response = _model!.generateContentStream(content);

      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null && text.isNotEmpty) {
          yield text;
        }
      }
    } catch (e) {
      print('GeminiAIService: Streaming error: $e');
      throw InferenceException('Streaming failed: $e');
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    if (_isInitialized) {
      _model = null;
      _isInitialized = false;
      print('GeminiAIService: Service disposed');
    }
  }
}
