# MediaPipe LLM Setup - Quick Commands

This file contains the essential commands to set up and use the MediaPipe LLM Inference API in this project.

## Prerequisites

- Android device with Android 7.0+ (API 24)
- ADB installed and device connected
- Flutter SDK installed
- ~2 GB free space on device

## Step 1: Download Model

Download Gemma-3 1B IT model from Hugging Face:

```powershell
# Visit this URL and download the .task file:
# https://huggingface.co/litert-community/Gemma3-1B-IT
# File size: ~2 GB
```

## Step 2: Push Model to Device

```powershell
# Check if device is connected
adb devices

# Remove old models (if any)
adb shell rm -r /data/local/tmp/llm/

# Create model directory
adb shell mkdir -p /data/local/tmp/llm/

# Push model to device (adjust path to your downloaded file)
adb push "C:\Users\YourName\Downloads\gemma3-1b-it.task" /data/local/tmp/llm/gemma3-1b-it.task

# Verify file was transferred
adb shell ls -lh /data/local/tmp/llm/

# Check file size (should be ~2 GB)
adb shell du -h /data/local/tmp/llm/gemma3-1b-it.task
```

## Step 3: Build Project

```powershell
# Navigate to project directory
cd C:\Users\berka\Project\tdde02

# Get dependencies
flutter pub get

# Generate Riverpod providers and Freezed models
dart run build_runner build --delete-conflicting-outputs

# This will generate:
# - ingredient_detection_provider.g.dart (with mediaPipeLlmServiceProvider)
# - Other generated files
```

## Step 4: Run App

```powershell
# List available devices
flutter devices

# Run on connected device
flutter run

# Or run in release mode for better performance
flutter run --release
```

## Step 5: Test Model

1. Launch the app
2. Wait for splash screen to load model (2-3 seconds)
3. If successful: "Ready!" message appears
4. If failed: Error message with retry option

### Expected Logs

Successful initialization:
```
MediaPipeLlmService: Initializing MediaPipe LLM
MediaPipeLlmService: Initialization successful
```

### Testing Ingredient Detection

1. Tap "Scan Fridge" button
2. Take a photo of ingredients
3. AI will detect ingredients (~2-5 seconds)
4. Review and edit results

Expected logs:
```
MediaPipeLlmService: Starting ingredient detection
MediaPipeLlmService: Detected 8 ingredients
```

### Testing Recipe Generation

1. After detecting ingredients
2. Tap "Generate Recipe"
3. AI will create recipe (~3-7 seconds)
4. View full recipe with instructions

Expected logs:
```
MediaPipeLlmService: Starting recipe generation
MediaPipeLlmService: Generated recipe: Chicken and Vegetable Stir Fry
```

## Troubleshooting

### Model Not Found

```powershell
# Check if model file exists
adb shell ls -lh /data/local/tmp/llm/

# If missing, push again
adb push gemma3-1b-it.task /data/local/tmp/llm/gemma3-1b-it.task
```

### Permission Denied

```powershell
# Fix file permissions
adb shell chmod 644 /data/local/tmp/llm/gemma3-1b-it.task
```

### Build Errors

```powershell
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Code Generation Issues

```powershell
# Delete generated files
Get-ChildItem -Path "lib" -Recurse -Filter "*.g.dart" | Remove-Item
Get-ChildItem -Path "lib" -Recurse -Filter "*.freezed.dart" | Remove-Item

# Regenerate
dart run build_runner build --delete-conflicting-outputs
```

### Gradle Build Fails

```powershell
# In android/ directory
cd android
./gradlew clean

# Return to project root
cd ..

# Rebuild
flutter run
```

## Configuration

Model configuration is in `lib/core/constants/app_constants.dart`:

```dart
// Model path (on device)
static const String modelPath = '/data/local/tmp/llm/gemma3-1b-it.task';

// Inference parameters
static const int maxTokens = 1000;      // Increase for longer recipes
static const int topK = 64;             // Higher = more creative
static const double temperature = 0.8;  // 0.0-1.0 (higher = more random)
static const int randomSeed = 101;      // For reproducibility
```

Adjust these values based on your needs and device capabilities.

## Performance Tips

### For Faster Inference
- Lower `maxTokens` (e.g., 500)
- Lower `topK` (e.g., 40)
- Use release mode: `flutter run --release`

### For Better Quality
- Increase `maxTokens` (e.g., 1500)
- Increase `topK` (e.g., 100)
- Adjust `temperature` (0.7-0.9 for recipes)

### For Lower Memory Usage
- Lower image quality in `AppConstants.imageQuality`
- Close other apps on device
- Use release build (more optimized)

## Mock Mode (No Model Required)

The app includes mock responses for development. If the model isn't found:

- App still launches successfully
- Mock ingredients returned after 2s delay
- Mock recipe generated after 2s delay
- All UI features work for testing

This allows development without waiting for model downloads.

## Production Deployment

For production apps, do NOT use `/data/local/tmp/`. Instead:

1. **Download model on first launch** from your CDN
2. Store in app's documents directory
3. Update `AppConstants.modelPath` accordingly

Example:
```dart
final appDir = await getApplicationDocumentsDirectory();
final modelPath = '${appDir.path}/models/gemma3-1b-it.task';
```

## Additional Resources

- [MediaPipe LLM Android Guide](https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android)
- [Gemma-3 on Hugging Face](https://huggingface.co/litert-community/Gemma3-1B-IT)
- [Full AI Model Setup Guide](./AI_MODEL_SETUP.md)

## Summary Checklist

- [ ] Android device connected (check with `adb devices`)
- [ ] Model downloaded from Hugging Face (~2 GB)
- [ ] Model pushed to device (`/data/local/tmp/llm/gemma3-1b-it.task`)
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Code generated (`dart run build_runner build --delete-conflicting-outputs`)
- [ ] App running (`flutter run`)
- [ ] Model initialized successfully (check splash screen)
- [ ] Camera permissions granted
- [ ] Ingredient detection tested
- [ ] Recipe generation tested

Once all checkboxes are complete, your app is ready to use!
