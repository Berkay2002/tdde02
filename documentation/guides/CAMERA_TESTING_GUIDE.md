# Camera Integration Testing Guide

## Overview
The camera integration is now complete. This guide will help you test all features on a physical device.

## Prerequisites
- Physical Android device (Android 5.0+ / SDK 21+)
- USB debugging enabled
- Device connected via USB or WiFi debugging

## Verification Steps

### 1. Check Device Connection
```powershell
flutter devices
```
You should see your device listed.

### 2. Install and Run
```powershell
# Clean build recommended for permission changes
flutter clean
flutter pub get
flutter run --debug
```

### 3. Test Camera Features

#### Camera Permissions
1. Tap "Scan Fridge" button on home screen
2. **Expected**: Camera permission dialog appears
3. Grant permission
4. **Expected**: Camera preview shows successfully

If permission denied:
- Dialog appears with "Open Settings" option
- Tapping opens app settings to manually grant permission

#### Camera Preview
- **Expected**: Live camera preview displays
- **Expected**: Preview fills screen with correct aspect ratio
- Test rotation: Does preview adapt correctly?

#### Camera Controls

**Capture Button (Center)**
- Tap the large circular button
- **Expected**: 
  - Haptic feedback on tap
  - Button shows loading indicator
  - Image captures successfully
  - Navigates to preview screen

**Flash Toggle (Right)**
- Tap flash icon
- **Expected**: Icon changes between flash_on/flash_off
- **Expected**: Device flashlight toggles on/off
- Test in low light to verify flash works

**Gallery Picker (Left)**
- Tap gallery icon
- **Expected**: Storage permission dialog (first time)
- Grant permission
- **Expected**: Gallery opens
- Select an image
- **Expected**: Navigates to preview screen with selected image

#### Image Preview Screen
After capturing/selecting an image:

**Preview Display**
- **Expected**: Image displays at full size
- **Expected**: Image quality is clear and sharp

**Retake Button**
- Tap "Retake" button
- **Expected**: Returns to camera screen
- Capture another photo

**Use Photo Button**
- Tap "Use Photo" button
- **Expected**: Returns to home screen with image path
- (Later: Will pass to ingredient detection)

### 4. Test Edge Cases

#### No Camera Available
- Test on emulator (should show error)
- **Expected**: Error message with retry button

#### Camera Lifecycle
1. Start camera
2. Press home button (minimize app)
3. Reopen app
4. **Expected**: Camera reinitializes successfully

#### Permission Denied Permanently
1. Deny camera permission
2. Select "Don't ask again" (Android)
3. Try to open camera
4. **Expected**: Dialog offers to open settings

#### Low Memory
- Test on device with <2GB RAM
- **Expected**: App doesn't crash, handles gracefully

## Performance Benchmarks

### Camera Startup Time
- **Target**: <2 seconds from tap to preview
- **Measure**: Time from CameraScreen navigation to preview visible

### Capture Time
- **Target**: <1 second from tap to preview screen
- **Measure**: Time from button tap to ImagePreviewScreen displayed

### Gallery Load Time
- **Target**: <1 second
- **Measure**: Time from gallery icon tap to gallery UI

## Known Issues & Limitations

### Current Limitations
1. **Emulator Support**: Camera doesn't work reliably on emulators
2. **Tablet Support**: UI may need adjustment for large screens
3. **Landscape Mode**: Currently portrait-only optimization

### Future Enhancements
- [ ] Multiple camera support (front/back toggle)
- [ ] Zoom controls
- [ ] Focus/exposure controls
- [ ] Grid overlay for alignment
- [ ] Image quality selector

## Troubleshooting

### Camera Not Initializing
```powershell
# Check for errors
flutter run --verbose
```

Common causes:
- Permission not granted
- Camera in use by another app
- Insufficient memory
- SDK version mismatch

### Black Screen
- Check AndroidManifest.xml has camera permissions
- Check Info.plist has camera usage descriptions
- Restart device
- Clear app data: Settings → Apps → App → Storage → Clear Data

### Build Errors
```powershell
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Permission Issues
- Check Android SDK version ≥21
- Check iOS deployment target ≥12.0
- Verify permission declarations in manifest files

## Report Issues

Document any issues found:
- Device model and Android/iOS version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/videos if possible
- Logcat output (run `flutter logs` in terminal)
