import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../constants/prompt_templates.dart';
import '../errors/ai_exceptions.dart';

/// Service for running AI inference using MediaPipe LLM Inference API
/// 
/// This service uses platform channels to communicate with native Android
/// MediaPipe implementation for on-device LLM inference.
class MediaPipeLlmService {
  static const MethodChannel _channel = MethodChannel('com.example.flutter_application_1/mediapipe_llm');
  
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;

  /// Initialize the MediaPipe LLM with configuration
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('MediaPipeLlmService: Initializing MediaPipe LLM');
      
      final result = await _channel.invokeMethod('initialize', {
        'modelPath': AppConstants.modelPath,
        'maxTokens': AppConstants.maxTokens,
        'topK': AppConstants.topK,
        'temperature': AppConstants.temperature,
        'randomSeed': AppConstants.randomSeed,
      });

      if (result == true) {
        _isInitialized = true;
        print('MediaPipeLlmService: Initialization successful');
      } else {
        throw ModelLoadException('Failed to initialize MediaPipe LLM');
      }
    } on PlatformException catch (e) {
      print('MediaPipeLlmService: Platform exception during initialization: ${e.message}');
      throw ModelLoadException('Failed to load AI model: ${e.message}');
    } catch (e) {
      print('MediaPipeLlmService: Unexpected error during initialization: $e');
      throw ModelLoadException('Failed to load AI model: $e');
    }
  }

  /// Detect ingredients from preprocessed image data
  /// 
  /// Uses multimodal prompting with image + text input
  Future<List<String>> detectIngredients(Uint8List imageData) async {
    if (!_isInitialized) {
      throw ModelNotInitializedException('Model has not been initialized');
    }

    try {
      print('MediaPipeLlmService: Starting ingredient detection');
      
      final prompt = PromptTemplates.getIngredientDetectionPrompt();
      
      final result = await _generateWithTimeout(
        prompt: prompt,
        imageData: imageData,
        timeout: AppConstants.ingredientDetectionTimeout,
      );

      final ingredients = PromptTemplates.parseIngredientResponse(result);
      
      print('MediaPipeLlmService: Detected ${ingredients.length} ingredients');
      return ingredients;
    } catch (e) {
      print('MediaPipeLlmService: Ingredient detection failed: $e');
      throw InferenceException('Failed to detect ingredients: $e');
    }
  }

  /// Generate recipe from ingredients and preferences
  /// 
  /// Uses text-only prompting for recipe generation
  Future<Map<String, dynamic>> generateRecipe({
    required List<String> ingredients,
    String? dietaryRestrictions,
    String? skillLevel,
    String? cuisinePreference,
  }) async {
    if (!_isInitialized) {
      throw ModelNotInitializedException('Model has not been initialized');
    }

    try {
      print('MediaPipeLlmService: Starting recipe generation');
      
      final prompt = PromptTemplates.getRecipeGenerationPrompt(
        ingredients: ingredients,
        dietaryRestrictions: dietaryRestrictions,
        skillLevel: skillLevel,
        cuisinePreference: cuisinePreference,
      );

      final result = await _generateWithTimeout(
        prompt: prompt,
        timeout: AppConstants.recipeGenerationTimeout,
      );

      final recipe = PromptTemplates.parseRecipeResponse(result);
      
      print('MediaPipeLlmService: Generated recipe: ${recipe['name']}');
      return recipe;
    } catch (e) {
      print('MediaPipeLlmService: Recipe generation failed: $e');
      throw InferenceException('Failed to generate recipe: $e');
    }
  }

  /// Generate response with optional image (multimodal)
  Future<String> _generateWithTimeout({
    required String prompt,
    Uint8List? imageData,
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
      _generate(
        prompt: prompt,
        imageData: imageData,
      ).then((result) {
        timer.cancel();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      }).catchError((error) {
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

  /// Core inference method using platform channel
  Future<String> _generate({
    required String prompt,
    Uint8List? imageData,
  }) async {
    try {
      final Map<String, dynamic> arguments = {
        'prompt': prompt,
      };

      if (imageData != null) {
        arguments['imageData'] = imageData;
      }

      final String? result = await _channel.invokeMethod('generateResponse', arguments);
      
      if (result == null || result.isEmpty) {
        throw InferenceException('Received empty response from model');
      }

      return result;
    } on PlatformException catch (e) {
      print('MediaPipeLlmService: Platform exception during inference: ${e.message}');
      throw InferenceException('Inference failed: ${e.message}');
    } catch (e) {
      print('MediaPipeLlmService: Unexpected error during inference: $e');
      rethrow;
    }
  }

  /// Generate response asynchronously with streaming support
  /// 
  /// Returns a stream of partial results as they are generated
  Stream<String> generateResponseStream({
    required String prompt,
    Uint8List? imageData,
  }) async* {
    if (!_isInitialized) {
      throw ModelNotInitializedException('Model has not been initialized');
    }

    try {
      final Map<String, dynamic> arguments = {
        'prompt': prompt,
      };

      if (imageData != null) {
        arguments['imageData'] = imageData;
      }

      // Setup event channel for streaming responses
      const eventChannel = EventChannel('com.example.flutter_application_1/mediapipe_llm_stream');
      
      // Send request to start generation
      await _channel.invokeMethod('generateResponseAsync', arguments);

      // Listen to streaming results
      await for (final result in eventChannel.receiveBroadcastStream()) {
        if (result is String) {
          yield result;
        }
      }
    } on PlatformException catch (e) {
      print('MediaPipeLlmService: Platform exception during streaming: ${e.message}');
      throw InferenceException('Streaming inference failed: ${e.message}');
    } catch (e) {
      print('MediaPipeLlmService: Unexpected error during streaming: $e');
      rethrow;
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        await _channel.invokeMethod('dispose');
        _isInitialized = false;
        print('MediaPipeLlmService: Model disposed');
      } catch (e) {
        print('MediaPipeLlmService: Error during disposal: $e');
      }
    }
  }
}
