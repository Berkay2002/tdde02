# AI Models Directory

This directory contains TFLite model files for on-device AI inference.

## Required Model

**File**: `gemma-3n-e4b-it-int4.tflite`
**Size**: ~2-3 GB
**Format**: TFLite (TensorFlow Lite)

## Getting the Model

See [AI_MODEL_SETUP.md](../../documentation/guides/AI_MODEL_SETUP.md) for detailed instructions on:
- Downloading the Gemma 3n model
- Converting to TFLite format (if needed)
- Installing in this directory

## Important Notes

⚠️ **Model files are NOT included in git** due to their large size (2-3 GB)

✅ **Development**: The app works with mock responses until the real model is added

📱 **Testing**: Real model required only for physical device testing

## Quick Setup

```bash
# 1. Download the model (see documentation for sources)
# 2. Place it in this directory
cp /path/to/gemma-3n-e4b-it-int4.tflite ./assets/models/

# 3. Verify the file exists
ls -lh assets/models/

# 4. Rebuild the app
flutter clean
flutter pub get
flutter run
```

## File Structure

```
assets/models/
├── README.md (this file)
└── gemma-3n-e4b-it-int4.tflite (you need to add this)
```

## Alternatives

If the model file is too large or unavailable:
1. Use mock responses (current default)
2. Use `flutter_gemma` plugin (handles model automatically)
3. Use cloud-based Gemini API

See the setup guide for details on each approach.
