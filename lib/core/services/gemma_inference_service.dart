import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../constants/app_constants.dart';
import '../constants/prompt_templates.dart';
import '../errors/ai_exceptions.dart';

/// Service for running AI inference using Gemma 3n model
class GemmaInferenceService {
  Interpreter? _interpreter;
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;

  /// Initialize the TFLite model with hardware acceleration
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final options = InterpreterOptions();
      
      // Configure thread count for optimal performance
      options.threads = AppConstants.modelThreads;

      // TODO: Add hardware acceleration delegates once model is in place
      // For Android: NnApiDelegate() for hardware acceleration
      // For iOS: GpuDelegateV2() for Metal/GPU acceleration
      // These require specific delegate initialization based on tflite_flutter version
      
      if (Platform.isAndroid) {
        print('GemmaInferenceService: Android platform detected (delegates can be added later)');
      } else if (Platform.isIOS) {
        print('GemmaInferenceService: iOS platform detected (delegates can be added later)');
      }

      // Load the model from assets
      print('GemmaInferenceService: Loading model from ${AppConstants.modelPath}');
      _interpreter = await Interpreter.fromAsset(
        AppConstants.modelPath,
        options: options,
      );

      _isInitialized = true;
      print('GemmaInferenceService: Model loaded successfully');
      print('GemmaInferenceService: Input tensors: ${_interpreter!.getInputTensors().length}');
      print('GemmaInferenceService: Output tensors: ${_interpreter!.getOutputTensors().length}');
    } catch (e) {
      print('GemmaInferenceService: Failed to load model: $e');
      throw ModelLoadException('Failed to load AI model: $e');
    }
  }

  /// Detect ingredients from preprocessed image data
  Future<List<String>> detectIngredients(Uint8List imageData) async {
    if (!_isInitialized) {
      throw ModelNotInitializedException('Model has not been initialized');
    }

    try {
      print('GemmaInferenceService: Starting ingredient detection');
      
      // Get the prompt for ingredient detection
      final prompt = PromptTemplates.getIngredientDetectionPrompt();
      
      // Run inference with timeout
      final result = await _runInferenceWithTimeout(
        imageData: imageData,
        prompt: prompt,
        timeout: AppConstants.ingredientDetectionTimeout,
      );

      // Parse the response to extract ingredient list
      final ingredients = PromptTemplates.parseIngredientResponse(result);
      
      print('GemmaInferenceService: Detected ${ingredients.length} ingredients');
      return ingredients;
    } catch (e) {
      print('GemmaInferenceService: Ingredient detection failed: $e');
      throw InferenceException('Failed to detect ingredients: $e');
    }
  }

  /// Generate recipe from ingredients and preferences
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
      print('GemmaInferenceService: Starting recipe generation');
      
      // Get the prompt for recipe generation
      final prompt = PromptTemplates.getRecipeGenerationPrompt(
        ingredients: ingredients,
        dietaryRestrictions: dietaryRestrictions,
        skillLevel: skillLevel,
        cuisinePreference: cuisinePreference,
      );

      // Run inference with timeout
      final result = await _runInferenceWithTimeout(
        prompt: prompt,
        timeout: AppConstants.recipeGenerationTimeout,
      );

      // Parse the response to extract recipe details
      final recipe = PromptTemplates.parseRecipeResponse(result);
      
      print('GemmaInferenceService: Generated recipe: ${recipe['name']}');
      return recipe;
    } catch (e) {
      print('GemmaInferenceService: Recipe generation failed: $e');
      throw InferenceException('Failed to generate recipe: $e');
    }
  }

  /// Run inference with timeout protection
  Future<String> _runInferenceWithTimeout({
    Uint8List? imageData,
    required String prompt,
    required Duration timeout,
  }) async {
    return await Future.any([
      _runInference(imageData: imageData, prompt: prompt),
      Future.delayed(timeout).then((_) => throw TimeoutException()),
    ]);
  }

  /// Core inference execution
  /// 
  /// Note: This is a simplified implementation that needs to be adapted
  /// to the actual input/output format of the Gemma 3n model.
  /// The actual implementation will depend on:
  /// 1. Model's expected input tensor format (text tokens + image embeddings)
  /// 2. Tokenization strategy for text prompts
  /// 3. Image embedding format
  /// 4. Output tensor format and decoding strategy
  Future<String> _runInference({
    Uint8List? imageData,
    required String prompt,
  }) async {
    if (_interpreter == null) {
      throw ModelNotInitializedException('Interpreter is null');
    }

    try {
      // TODO: Implement actual inference logic based on Gemma 3n model requirements
      // This is a placeholder that demonstrates the structure
      
      // Step 1: Tokenize text prompt
      // final tokens = _tokenizePrompt(prompt);
      
      // Step 2: Prepare image embeddings (if image provided)
      // final imageEmbeddings = imageData != null ? _processImageEmbeddings(imageData) : null;
      
      // Step 3: Combine inputs according to model's multimodal format
      // final inputTensors = _prepareInputTensors(tokens, imageEmbeddings);
      
      // Step 4: Allocate output tensors
      // final outputTensors = _allocateOutputTensors();
      
      // Step 5: Run inference
      // _interpreter!.runForMultipleInputs(inputTensors, outputTensors);
      
      // Step 6: Decode output tokens to text
      // final response = _decodeOutput(outputTensors);
      
      // TEMPORARY: Return mock response for development
      print('GemmaInferenceService: Running inference (mock mode)');
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing
      
      if (imageData != null) {
        // Mock ingredient detection response
        return '''
- Tomatoes
- Bell peppers
- Onions
- Garlic
- Chicken breast
- Eggs
- Milk
- Cheese
''';
      } else {
        // Mock recipe generation response
        return '''
Recipe Name: Chicken and Vegetable Stir Fry
Description: A quick and delicious stir fry featuring tender chicken and fresh vegetables in a savory sauce. Perfect for weeknight dinners.
Prep Time: 15 minutes
Cook Time: 20 minutes
Servings: 4

Ingredients:
- 500g chicken breast, sliced
- 2 bell peppers, sliced
- 1 onion, sliced
- 3 cloves garlic, minced
- 2 tomatoes, chopped
- 2 tablespoons oil
- 3 tablespoons soy sauce
- 1 tablespoon cornstarch
- Salt and pepper to taste

Instructions:
1. Cut the chicken breast into thin strips and season with salt and pepper
2. Heat oil in a large wok or pan over high heat
3. Add chicken strips and cook until golden brown, about 5-6 minutes
4. Remove chicken and set aside
5. In the same pan, add garlic and onions, stir fry for 2 minutes
6. Add bell peppers and tomatoes, cook for 3-4 minutes
7. Return chicken to the pan
8. Mix soy sauce with cornstarch and 1/4 cup water, pour over the mixture
9. Stir well and cook for 2-3 minutes until sauce thickens
10. Serve hot over rice or noodles

Tips: For extra flavor, add a splash of sesame oil at the end. You can also add other vegetables like broccoli or carrots.
''';
      }
    } catch (e) {
      print('GemmaInferenceService: Inference execution failed: $e');
      rethrow;
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    if (_interpreter != null) {
      _interpreter!.close();
      _interpreter = null;
      _isInitialized = false;
      print('GemmaInferenceService: Model disposed');
    }
  }
}

class TimeoutException implements Exception {
  @override
  String toString() => 'Inference operation timed out';
}
