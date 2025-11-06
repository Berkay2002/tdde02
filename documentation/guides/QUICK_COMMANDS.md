# Quick Testing Commands

## Prerequisites Check
```powershell
# Check Flutter installation
flutter doctor

# List connected devices
flutter devices

# Check Android emulators (not recommended for camera testing)
flutter emulators
```

## Build and Run

### Clean Build (Recommended after permission changes)
```powershell
# Full clean and rebuild
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Quick Run (For development)
```powershell
# Run on default device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with hot reload in debug mode
flutter run --debug
```

## Development Commands

### Code Generation
```powershell
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerates on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

### Analysis
```powershell
# Check for errors
flutter analyze

# Format code
dart format .

# Check formatting without changes
dart format --output=none --set-exit-if-changed .
```

## Testing

### Run Tests
```powershell
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### View Logs
```powershell
# View app logs in real-time
flutter logs

# Clear logs
flutter logs --clear
```

## Device Management

### Physical Device Setup (Android)
1. Enable Developer Options:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   
2. Enable USB Debugging:
   - Settings → Developer Options → USB Debugging

3. Connect device via USB

4. Verify connection:
   ```powershell
   flutter devices
   ```

### Install APK
```powershell
# Build and install debug APK
flutter build apk --debug
flutter install

# Or run directly
flutter run --debug
```

## Troubleshooting

### Camera Not Working
```powershell
# Check for build errors
flutter run --verbose

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Permission Issues
```powershell
# Uninstall and reinstall app
flutter clean
flutter run

# Or manually uninstall from device:
# Settings → Apps → [App Name] → Uninstall
```

### Build Errors
```powershell
# Reset everything
flutter clean
rm -r build/
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Hot Reload Not Working
- Press `r` in terminal to hot reload
- Press `R` in terminal to hot restart
- Press `q` to quit

## Performance Profiling

### Flutter DevTools
```powershell
# Activate DevTools
flutter pub global activate devtools

# Run DevTools
flutter pub global run devtools

# Or launch with app
flutter run --enable-vm-service
```

### Performance Overlay
- Press `P` in terminal while app is running
- Shows FPS, frame rendering time, GPU usage

## Release Build (For Testing Performance)

```powershell
# Build release APK
flutter build apk --release

# Install release APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Common Issues

### "Dart build runner not found"
```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### "No devices found"
- Check USB connection
- Enable USB debugging on device
- Try `flutter devices` again
- Restart adb: `adb kill-server && adb start-server`

### "Camera permission denied"
- Uninstall app
- Reinstall to trigger fresh permission prompt
- Or manually grant in device settings

### "Build failed"
```powershell
flutter clean
flutter pub get
flutter pub upgrade
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Next Steps After Camera Testing

Once camera is verified working:

1. **Download AI Model**
   ```powershell
   # Create models directory if not exists
   mkdir -p assets/models
   
   # Download Gemma 3n model (command will be provided)
   # Place in assets/models/
   ```

2. **Update pubspec.yaml**
   - Verify assets section includes `assets/models/`

3. **Implement AI Inference**
   - Create `GemmaInferenceService`
   - Load model on startup
   - Connect camera output to inference

## Useful Shortcuts

While app is running in terminal:
- `r` - Hot reload
- `R` - Hot restart
- `h` - List all available commands
- `o` - Toggle platform (Android/iOS if both connected)
- `P` - Toggle performance overlay
- `w` - Toggle widget inspector
- `v` - Open DevTools
- `q` - Quit

## Device-Specific Testing

### Test on Multiple Devices
```powershell
# List all devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on all connected devices
flutter run -d all
```

### Recommended Test Devices
- **Minimum**: Android 5.0 (API 21) with 2GB RAM
- **Optimal**: Android 8.0+ (API 26+) with 4GB+ RAM
- **Best**: Android 10+ (API 29+) with 6GB+ RAM

Low-end testing important for performance validation.
