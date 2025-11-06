# AI Model Setup Guide

## Overview

This project uses Google's Gemma 3 Nano model for on-device AI inference. The model enables ingredient detection and recipe generation without requiring external API calls.

## Model Information

**Model**: Gemma 3n-E4B-it-int4
- **Size**: ~2-3 GB (4-bit quantized)
- **Parameters**: 4B effective
- **Context**: 32,768 tokens
- **Format**: TFLite
- **Capabilities**: Multimodal (text + image)

## Option 1: Using flutter_gemma Plugin (Recommended)

Google provides an official Flutter plugin that simplifies Gemma 3 Nano integration with MediaPipe optimizations.

### Installation

1. Add the plugin to `pubspec.yaml`:
```yaml
dependencies:
  flutter_gemma: ^0.11.9  # Check pub.dev for latest version
```

2. Run:
```bash
flutter pub get
```

3. The plugin handles model downloading and initialization automatically.

### Resources
- [flutter_gemma on pub.dev](https://pub.dev/packages/flutter_gemma)
- [MediaPipe Gemma Documentation](https://developers.google.com/mediapipe/solutions/genai/gemma)

## Option 2: Manual TFLite Setup (Current Implementation)

If you prefer direct TFLite integration, follow these steps:

### Step 1: Download the Model

#### From Hugging Face:
```bash
# Install huggingface-cli
pip install huggingface-hub

# Download Gemma 3n model (requires authentication)
huggingface-cli login
huggingface-cli download google/gemma-3n-e4b-it --local-dir ./models
```

#### From Google AI Studio:
1. Visit [Google AI Studio](https://aistudio.google.com/)
2. Navigate to model downloads
3. Select Gemma 3n (4-bit quantized TFLite)
4. Download the `.tflite` file

### Step 2: Convert to TFLite (if needed)

If the model is not in TFLite format:
```bash
# Install TensorFlow
pip install tensorflow

# Convert model (example script)
python convert_to_tflite.py --input gemma-3n-e4b-it --output gemma-3n-e4b-it-int4.tflite
```

### Step 3: Add Model to Project

1. Place the model file in the project:
```bash
mkdir -p assets/models
cp gemma-3n-e4b-it-int4.tflite assets/models/
```

2. **Important**: Add to `.gitignore` (model is too large for git):
```
# .gitignore
assets/models/*.tflite
```

3. Verify `pubspec.yaml` includes:
```yaml
flutter:
  assets:
    - assets/models/
```

### Step 4: Update App Constants

The model path is already configured in `lib/core/constants/app_constants.dart`:
```dart
static const String modelPath = 'assets/models/gemma-3n-e4b-it-int4.tflite';
```

If your model has a different name, update this constant.

## Testing Without the Model

The current implementation includes mock responses for development and testing:

- **Ingredient Detection**: Returns sample ingredients list
- **Recipe Generation**: Returns sample recipe

This allows you to:
- ✅ Test UI/UX flows
- ✅ Verify app structure
- ✅ Develop features in parallel
- ✅ Test on emulator (real model requires physical device)

### Switching from Mock to Real Inference

In `lib/core/services/gemma_inference_service.dart`, the `_runInference` method currently returns mock data. Once the model is in place:

1. Implement actual tokenization
2. Process image embeddings
3. Call `_interpreter!.run()` with prepared inputs
4. Decode output tensors

The TODO comments mark where real inference logic should be added.

## Hardware Acceleration

### Android (NNAPI)
The service is configured to use NNAPI delegate for hardware acceleration on Android devices with SDK 27+ (Android 8.1+).

### iOS (Metal/GPU)
For iOS, GPU delegation will be configured when iOS support is added.

### Configuration
Thread count and acceleration settings are in `AppConstants`:
```dart
static const int modelThreads = 4;
```

Adjust based on target device capabilities.

## Performance Expectations

### With Real Model:
- **First Load**: 2-5 seconds (model initialization)
- **Ingredient Detection**: 2-5 seconds
- **Recipe Generation**: 3-7 seconds
- **Memory**: ~500 MB during inference
- **Storage**: 2-3 GB for model file

### With Mock Responses (Current):
- **Detection**: 2 seconds (simulated)
- **Recipe Generation**: 2 seconds (simulated)
- **Memory**: Minimal
- **Storage**: None

## Troubleshooting

### Model Not Found Error
- Verify file exists in `assets/models/`
- Check `pubspec.yaml` includes assets
- Run `flutter clean && flutter pub get`
- Rebuild app

### Out of Memory
- Reduce image quality in `AppConstants.imageQuality`
- Lower thread count in `AppConstants.modelThreads`
- Test on device with 4GB+ RAM

### Slow Inference
- Enable hardware acceleration (NNAPI/GPU)
- Use quantized model (int4 or int8)
- Reduce input image size (already 512x512)

### Model Loading Timeout
- Increase timeout in splash screen
- Check device storage space
- Verify model file is not corrupted

## Alternative: Cloud-Based Inference

For demonstration or if model size is prohibitive:

1. Use Gemini API (cloud-based):
```dart
// In pubspec.yaml
dependencies:
  google_generative_ai: ^0.2.0

// Alternative service implementation
class GeminiApiService {
  final model = GenerativeModel(model: 'gemini-1.5-flash');
  // ... cloud inference
}
```

2. Trade-offs:
   - ✅ No large model download
   - ✅ Always up-to-date
   - ❌ Requires internet
   - ❌ API costs
   - ❌ Privacy concerns (data sent to cloud)

## Next Steps

1. **Immediate**: Continue development with mock responses
2. **Before Demo**: Obtain and integrate real Gemma 3n model
3. **For Production**: Evaluate flutter_gemma vs manual TFLite
4. **Alternative**: Consider Gemini API for MVP

## Resources

- [TFLite Flutter Plugin](https://pub.dev/packages/tflite_flutter)
- [Gemma Models on Hugging Face](https://huggingface.co/models?search=gemma)
- [Google AI Studio](https://aistudio.google.com/)
- [MediaPipe Gemma](https://developers.google.com/mediapipe/solutions/genai/gemma)
- [TensorFlow Lite Guide](https://www.tensorflow.org/lite)
