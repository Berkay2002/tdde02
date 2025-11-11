# Firebase AI with Gemini API - Quick Setup Guide

## Prerequisites
- ✅ Firebase project already set up: `eternal-water-477911-m6`
- ✅ App already configured with Firebase (android, ios, web)
- ✅ `firebase_ai: ^3.5.0` already in pubspec.yaml

## Setup Steps

### 1. Enable Gemini API in Firebase Console

#### Option A: Using Firebase Console UI
1. Go to Firebase Console: https://console.firebase.google.com/project/eternal-water-477911-m6
2. Navigate to **Build** → **AI Logic** in left sidebar
3. Click **Get started** button
4. Select **Gemini Developer API** (free tier)
5. Click **Enable API**
6. Accept terms of service if prompted
7. Done! API key is automatically managed by Firebase

#### Option B: Using Firebase MCP Tool (Recommended)
Since you have the Firebase MCP server available, use it:

```bash
# Check current Firebase environment
firebase_get_environment

# The Gemini API can be enabled via Firebase Console or automatically
# when you make your first API call
```

### 2. Verify API is Enabled

Run this test in your app (or use Firebase Console):

```dart
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> testGeminiAPI() async {
  await Firebase.initializeApp();
  
  try {
    final ai = FirebaseAI.googleAI();
    final model = ai.generativeModel(model: 'gemini-2.5-flash');
    final response = await model.generateContent([
      Content.text('Hello, Gemini!')
    ]);
    print('✅ Gemini API is working: ${response.text}');
  } catch (e) {
    print('❌ Gemini API error: $e');
  }
}
```

### 3. Configure for Production (Optional but Recommended)

#### A. Set up Firebase App Check
Protects your API from abuse:

1. Go to: https://console.firebase.google.com/project/eternal-water-477911-m6/appcheck
2. Click **Get started**
3. Select your apps
4. For Android: Choose **Play Integrity**
5. For iOS: Choose **App Attest**
6. For Web: Choose **reCAPTCHA**
7. Click **Save**

Then add to your app:

```dart
// In main.dart
import 'package:firebase_app_check/firebase_app_check.dart';

await FirebaseAppCheck.instance.activate(
  webRecaptchaSiteKey: 'your-site-key',
  androidProvider: AndroidProvider.playIntegrity,
  appleProvider: AppleProvider.appAttest,
);
```

#### B. Monitor Usage
- Dashboard: https://console.firebase.google.com/project/eternal-water-477911-m6/ailogic
- Check daily quota usage
- Set up budget alerts if needed

### 4. Test the Integration

#### A. Run the App
```bash
cd c:\Users\berka\Project\flutter\tdde02
flutter run
```

#### B. Test Ingredient Detection
1. Open app
2. Go to camera screen
3. Take photo of food items
4. Wait for Gemini API to detect ingredients
5. Check console for logs:
   ```
   GeminiAIService: Initializing Firebase AI with Gemini API
   GeminiAIService: Initialization successful with gemini-2.5-flash
   GeminiAIService: Starting ingredient detection
   GeminiAIService: Detected 5 ingredients
   ```

#### C. Test Recipe Generation
1. Use detected ingredients
2. Add preferences
3. Generate recipe
4. Verify formatted output

### 5. Troubleshooting

#### Error: "API not enabled"
**Solution**: Enable Gemini API in Firebase Console (see step 1)

#### Error: "Quota exceeded"
**Solution**: 
- Free tier: 15 requests/minute, 1500/day
- Wait for quota reset or upgrade to paid plan
- Check: https://console.firebase.google.com/project/eternal-water-477911-m6/usage

#### Error: "Network error"
**Solution**:
- Check internet connection
- Verify Firebase configuration
- Check `google-services.json` is up to date

#### Error: "Permission denied"
**Solution**:
- Verify Firebase project setup
- Check App Check is not blocking requests
- Verify API key in Firebase Console

### 6. Rate Limits & Quotas

#### Gemini Developer API (Free Tier)
- **Requests per minute (RPM)**: 15
- **Requests per day (RPD)**: 1,500
- **Input tokens per minute**: 1 million
- **Output tokens per minute**: 32,000

#### Best Practices
- Implement request queuing
- Add retry logic with exponential backoff
- Cache results when possible
- Use streaming for better UX

### 7. Cost Management

#### Free Tier
- Perfect for development and testing
- No billing required
- Generous limits for most apps

#### Paid Plans
If you need more quota:
1. Go to: https://console.firebase.google.com/project/eternal-water-477911-m6/usage
2. Click **Upgrade project**
3. Enable billing
4. Set budget alerts

**Pricing** (Gemini 2.5 Flash):
- Input: $0.075 per 1M tokens
- Output: $0.30 per 1M tokens
- Very cost-effective for most use cases

### 8. Security Best Practices

✅ **DO**:
- Enable Firebase App Check
- Set up rate limiting in your app
- Monitor usage in Firebase Console
- Use environment-specific API keys
- Implement proper error handling

❌ **DON'T**:
- Commit API keys to git (Firebase handles this)
- Allow unlimited retries
- Send sensitive user data without encryption
- Ignore quota limits

## Quick Command Reference

```bash
# Install dependencies
flutter pub get

# Regenerate providers
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Clean build
flutter clean && flutter pub get

# Check for errors
flutter analyze

# Run tests
flutter test
```

## Firebase Console Links

- **Project Overview**: https://console.firebase.google.com/project/eternal-water-477911-m6
- **AI Logic Dashboard**: https://console.firebase.google.com/project/eternal-water-477911-m6/ailogic
- **App Check**: https://console.firebase.google.com/project/eternal-water-477911-m6/appcheck
- **Usage & Billing**: https://console.firebase.google.com/project/eternal-water-477911-m6/usage
- **Settings**: https://console.firebase.google.com/project/eternal-water-477911-m6/settings/general

## Support Resources

- **Firebase AI Logic Docs**: https://firebase.google.com/docs/ai-logic
- **Gemini API Docs**: https://ai.google.dev/gemini-api/docs
- **Flutter Firebase Docs**: https://firebase.flutter.dev/
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/firebase+flutter

## Next Steps

1. ✅ Enable Gemini API in Firebase Console
2. ⬜ Run `flutter run` to test the integration
3. ⬜ Test ingredient detection with real photos
4. ⬜ Test recipe generation with various preferences
5. ⬜ Monitor usage in Firebase Console
6. ⬜ Set up App Check for production
7. ⬜ Configure budget alerts if using paid tier

---

**Setup Guide Created**: November 11, 2025
**Status**: Ready for implementation
**Estimated Setup Time**: 5-10 minutes
