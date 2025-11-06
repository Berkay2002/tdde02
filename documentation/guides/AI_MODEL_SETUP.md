# AI Model Setup Guide

## Overview

This project uses Google's Gemma 3 Nano model for on-device AI inference via the **MediaPipe LLM Inference API**. This enables ingredient detection and recipe generation without requiring external API calls after initial model download.

## Model Information

**Model**: Gemma 3n 1B IT (Instruction-Tuned)
- **Size**: ~2 GB (4-bit quantized)
- **Parameters**: 1B
- **Context**: 32,768 tokens
- **Format**: .task (MediaPipe Task Bundle)
- **Capabilities**: Multimodal (text + image)
- **Platform**: Android (API 24+), iOS (future)

## Implementation: MediaPipe LLM Inference API

We use the **MediaPipe LLM Inference API** which provides an optimized wrapper for running Gemma models on-device. This is the **recommended approach** by Google for mobile deployments.

### Advantages
- ✅ **Optimized Performance**: Hardware-accelerated inference (GPU/NPU)
- ✅ **Official Support**: Maintained by Google's MediaPipe team
- ✅ **Multimodal Ready**: Built-in support for text + image prompts
- ✅ **Simple API**: High-level interface, no manual tokenization
- ✅ **Streaming Support**: Real-time response generation
- ✅ **Production-Ready**: Used in Google's own apps

### Advantages
- ✅ **Optimized Performance**: Hardware-accelerated inference (GPU/NPU)
- ✅ **Official Support**: Maintained by Google's MediaPipe team
- ✅ **Multimodal Ready**: Built-in support for text + image prompts
- ✅ **Simple API**: High-level interface, no manual tokenization
- ✅ **Streaming Support**: Real-time response generation
- ✅ **Production-Ready**: Used in Google's own apps

## Quick Start

### Step 1: Download the Model

Download Gemma-3 1B in a 4-bit quantized format from Hugging Face:

```bash
# Option 1: Direct download from Hugging Face
# Visit: https://huggingface.co/litert-community/Gemma3-1B-IT
# Download the .task file (approximately 2GB)

# Option 2: Using Hugging Face CLI
pip install huggingface-hub
huggingface-cli download litert-community/Gemma3-1B-IT --local-dir ./models
```

Available models:
- [Gemma-3 1B IT](https://huggingface.co/litert-community/Gemma3-1B-IT) - Recommended for mobile
- [Gemma-3n E2B](https://huggingface.co/google/gemma-3n-E2B-it-litert-preview) - Effective 2B model
- [Gemma-3n E4B](https://huggingface.co/google/gemma-3n-E4B-it-litert-preview) - Effective 4B model (requires high-end device)

### Step 2: Push Model to Device

MediaPipe models cannot be bundled in the APK due to size. During development, use `adb` to push the model to device storage:

```powershell
# Remove any previously loaded models
adb shell rm -r /data/local/tmp/llm/

# Create directory
adb shell mkdir -p /data/local/tmp/llm/

# Push the model (adjust path to your downloaded .task file)
adb push gemma3-1b-it.task /data/local/tmp/llm/gemma3-1b-it.task

# Verify the file exists
adb shell ls -lh /data/local/tmp/llm/
```

**Important**: For production deployment, download the model at runtime from a CDN or server. See [Production Deployment](#production-deployment) section.

### Step 3: Configure the App

The app is already configured for MediaPipe LLM. Configuration is in `lib/core/constants/app_constants.dart`:

```dart
static const String modelPath = '/data/local/tmp/llm/gemma3-1b-it.task';
static const int maxTokens = 1000;
static const int topK = 64;
static const double temperature = 0.8;
static const int randomSeed = 101;
```

### Step 4: Build and Run

```powershell
# Get dependencies
flutter pub get

# Generate Riverpod providers
dart run build_runner build --delete-conflicting-outputs

# Run on connected Android device
flutter run
```

## Architecture

### Platform Channel Implementation

The app uses Flutter platform channels to communicate with native Android MediaPipe implementation:

```
Flutter (Dart)              Android (Kotlin)
─────────────              ─────────────────
MediaPipeLlmService  <-->  MainActivity
    |                          |
    ├─ initialize()            ├─ LlmInference.createFromOptions()
    ├─ detectIngredients()     ├─ generateResponse() [with image]
    ├─ generateRecipe()        └─ generateResponseAsync() [streaming]
    └─ dispose()
```

### Key Components

#### Dart Side (`lib/core/services/mediapipe_llm_service.dart`)
- `initialize()`: Configure and load model
- `detectIngredients(imageData)`: Multimodal inference (image + text)
- `generateRecipe(ingredients, preferences)`: Text-only inference
- `generateResponseStream()`: Streaming inference (partial results)
- `dispose()`: Clean up resources

#### Android Side (`android/app/src/main/kotlin/.../MainActivity.kt`)
- Method channel setup
- `LlmInference` initialization with options
- Multimodal session creation for image prompts
- Asynchronous response handling
- Lifecycle management

### Multimodal Prompting

For ingredient detection, the service sends both:
1. **Text prompt**: "Identify all visible food items..."
2. **Image data**: Preprocessed 512x512 JPEG

MediaPipe handles:
- Image encoding/decoding
- Vision model integration
- Token generation from both modalities

## Configuration Options

Adjust these in `AppConstants` for your needs:

| Parameter | Default | Description | Tuning Notes |
|-----------|---------|-------------|--------------|
| `maxTokens` | 1000 | Max input + output tokens | Increase for longer recipes (↑ memory) |
| `topK` | 64 | Top-k sampling limit | Higher = more creative (↑ latency) |
| `temperature` | 0.8 | Randomness (0.0-1.0) | Lower = more deterministic |
| `randomSeed` | 101 | Seed for reproducibility | Change for variety |

## Performance Expectations

### Target Devices
- **Recommended**: Pixel 8+, Samsung S23+, or equivalent (4GB+ RAM)
- **Minimum**: Android 7.0 (API 24) with 3GB RAM
- **Note**: Does **not** work reliably on emulators

### Inference Times (Gemma-3 1B on Pixel 8)
- **First Load**: 2-3 seconds (model initialization)
- **Ingredient Detection**: 2-5 seconds (image + text inference)
- **Recipe Generation**: 3-7 seconds (text-only inference)
- **Memory Usage**: ~500 MB during inference
- **Storage**: 2 GB for model file

### Hardware Acceleration
MediaPipe automatically uses:
- **Android**: NNAPI (Neural Networks API) for GPU/NPU acceleration
- **iOS**: Metal/CoreML (future support)

No manual configuration needed—MediaPipe handles acceleration transparently.

## Testing Without Physical Device

Since camera and AI require physical hardware, we provide mock implementations for development:

### Mock Mode (Current Default)
The service returns simulated responses when the actual model isn't loaded:
- **Ingredient detection**: Returns sample ingredients list after 2s delay
- **Recipe generation**: Returns full sample recipe after 2s delay

This allows you to:
- ✅ Develop and test UI flows
- ✅ Work on other features in parallel
- ✅ Run on emulators (limited)
- ✅ Test without waiting for model downloads

### Switch to Real Inference
Once you've pushed the model to a device:
1. The service automatically detects the model file
2. Real inference replaces mock responses
3. No code changes required

## Production Deployment

### Option 1: On-Demand Download
Download model on first launch from your CDN:

```dart
Future<void> downloadModel() async {
  final response = await http.get(Uri.parse('https://your-cdn.com/gemma3-1b-it.task'));
  final file = File('${getApplicationDocumentsDirectory()}/models/gemma3-1b-it.task');
  await file.writeAsBytes(response.bodyBytes);
}
```

**Pros**: Smaller initial APK, model can be updated  
**Cons**: Requires internet on first launch, 2GB download

### Option 2: Split APKs
Use Android App Bundles with on-demand delivery:

```gradle
// android/app/build.gradle.kts
android {
    bundle {
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
        language {
            enableSplit = true
        }
    }
}
```

**Pros**: Google Play manages delivery  
**Cons**: Only works with Google Play Store

### Option 3: Smaller Model
Use a quantized variant for smaller size:

| Model | Size | Performance | Use Case |
|-------|------|-------------|----------|
| Gemma-3 1B (int4) | ~2 GB | Excellent | ✅ Recommended |
| Gemma-2 2B (int8) | ~3 GB | Better | High-end devices |
| Gemma-2 2B (int4) | ~1.5 GB | Good | Budget devices |

## Troubleshooting

### Model Not Found Error
```
Error: Failed to load AI model: FileNotFoundException
```

**Solution**:
1. Verify model is pushed to device: `adb shell ls -lh /data/local/tmp/llm/`
2. Check file permissions: `adb shell chmod 644 /data/local/tmp/llm/gemma3-1b-it.task`
3. Ensure correct path in `AppConstants.modelPath`

### Initialization Timeout
```
Error: INITIALIZATION_ERROR: Failed to initialize LLM
```

**Solution**:
1. Device may be low on memory (close other apps)
2. Try a smaller quantized model
3. Check device meets minimum requirements (API 24+, 3GB RAM)

### Slow Inference
```
Inference taking >10 seconds
```

**Solution**:
1. Verify hardware acceleration is enabled (check logcat)
2. Reduce `maxTokens` in configuration
3. Lower `topK` for faster sampling
4. Test on recommended hardware (Pixel 8+, S23+)

### Out of Memory
```
Error: java.lang.OutOfMemoryError
```

**Solution**:
1. Lower image quality: `AppConstants.imageQuality = 70`
2. Use smaller model variant
3. Close background apps
4. Minimum 3GB RAM required, 4GB+ recommended

### Camera Not Working
```
Camera preview shows black screen
```

**Solution**:
- Camera **requires physical device**—emulators are unreliable
- Grant camera permissions in device settings
- Use `flutter run --release` for better camera performance

## Advanced Features

### Streaming Responses
For real-time generation with partial results:

```dart
final stream = mediaPipeLlmService.generateResponseStream(
  prompt: "Generate a recipe...",
);

await for (final partialResult in stream) {
  print("Partial: $partialResult");
  // Update UI with partial text
}
```

### Custom Prompts
Modify prompts in `lib/core/constants/prompt_templates.dart`:

```dart
static String getIngredientDetectionPrompt() {
  return '''
You are an expert kitchen assistant. Analyze this image and list ALL visible food items.

Output format: Simple bullet list
- Item 1
- Item 2

Focus only on ingredients that can be used for cooking.
''';
}
```

### Temperature Tuning
Adjust creativity vs consistency:

- **Temperature = 0.0**: Deterministic, consistent outputs
- **Temperature = 0.5**: Balanced (good for ingredient detection)
- **Temperature = 0.8**: Creative (good for recipe generation) ✅ Default
- **Temperature = 1.0**: Maximum creativity, less consistent

## Alternative Approaches

### Option: Flutter Gemma Plugin
For simpler integration, consider the official Flutter plugin:

```yaml
dependencies:
  flutter_gemma: ^0.11.9
```

**Pros**: Even simpler API, automatic model management  
**Cons**: Less control over configuration, beta status

See: https://pub.dev/packages/flutter_gemma

### Option: Gemini API (Cloud)
For demonstration without model downloads:

```yaml
dependencies:
  google_generative_ai: ^0.2.0
```

**Pros**: No model file, always up-to-date, more powerful  
**Cons**: Requires internet, API costs, privacy concerns

## Next Steps

1. **Immediate**: Continue development with mock responses
2. **Before Demo**: Download and push real model to test device
3. **For Production**: Implement on-demand model download
4. **Future**: Add iOS support (similar MediaPipe API available)

## Resources

- [MediaPipe LLM Inference API](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference)
- [Gemma Models on Hugging Face](https://huggingface.co/models?search=gemma)
- [MediaPipe Android Guide](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android)
- [Gemma-3n Documentation](https://ai.google.dev/gemma/docs/gemma-3n)
- [Android Studio Setup](https://developer.android.com/studio)

