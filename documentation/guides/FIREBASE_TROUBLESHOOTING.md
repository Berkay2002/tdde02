# Firebase & Google Sign-In Troubleshooting

**Common issues and their fixes** - bookmark this page!

---

## Google Sign-In Fails - "PlatformException: sign_in_failed"

**Symptoms:**
- Red error banner: "Google sign in failed: Exception..."
- Error code `10` in logs
- "An internal error has occurred"

**Root Cause:** Missing SHA certificates in Firebase

**Fix:**

### Step 1: Get Your SHA Certificates
```bash
cd android

# Windows PowerShell:
.\gradlew signingReport

# Mac/Linux:
./gradlew signingReport

cd ..
```

**Look for this in the output:**
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: 11:9D:A7:93:09:22:E1:01:09:41:10:15:44:4D:A9:DC:4F:DA:66:BB
SHA-256: 7C:B7:E8:20:A7:4F:24:6B:01:D4:94:9E:A8:EF:FD:14:FF:86:3E:00...
```

**Copy the SHA1 and SHA-256 values!**

### Step 2: Add to Firebase (Choose ONE method)

**Method A: Firebase CLI (Recommended)**
```bash
# Login to Firebase
firebase login

# Use the project
firebase use eternal-water-477911-m6

# Add SHA-1 (replace YOUR_SHA1 with your actual SHA-1)
firebase apps:android:sha:create 1:593064071345:android:65206fcaee9311bbb71290 YOUR_SHA1

# Add SHA-256 (replace YOUR_SHA256 with your actual SHA-256)
firebase apps:android:sha:create 1:593064071345:android:65206fcaee9311bbb71290 YOUR_SHA256

# Download updated config
firebase apps:sdkconfig ANDROID 1:593064071345:android:65206fcaee9311bbb71290 -o android/app/google-services.json
```

**Method B: Firebase Console**
1. Go to [Firebase Console](https://console.firebase.google.com/project/eternal-water-477911-m6/settings/general)
2. Scroll to **Your apps** → Find the Android app
3. Under **SHA certificate fingerprints**, click **Add fingerprint**
4. Paste your SHA-1 → Click **Save**
5. Click **Add fingerprint** again
6. Paste your SHA-256 → Click **Save**
7. Download `google-services.json` and replace `android/app/google-services.json`

### Step 3: Clean & Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

**✅ Google Sign-In should now work!**

---

## Firebase App Check Token Invalid

**Symptoms:**
- Red error banner: "Firebase App Check token is invalid"
- Logs show: "Error getting App Check token; using placeholder token"

**Root Cause:** App Check is enforced but you haven't added a debug token

**Fix:**

### Step 1: Get Debug Token from Logs
Run your app once (it will fail, but that's OK):
```bash
flutter run
```

Look in the terminal output for:
```
Enter this debug secret into the allow list in the Firebase Console for your project: 
7b3bd3ef-a19c-447a-a185-a89426b7c496
```

**Copy that token!**

### Step 2: Add Debug Token to Firebase
1. Go to [Firebase App Check](https://console.firebase.google.com/project/eternal-water-477911-m6/appcheck)
2. Click **Apps** tab
3. Find `flutter_application_1 (android)`
4. Click **Manage debug tokens**
5. Paste your debug token → **Save**

### Step 3: Set Enforcement to Unenforced (Development)
1. In the same App Check page
2. Go to **APIs** tab
3. Find **Firebase Authentication**
4. Click the three dots → **Edit enforcement**
5. Set to **Unenforced** (for development)
6. Click **Save**

### Step 4: Restart App
```bash
# Press 'q' in terminal to quit
# Then run again:
flutter run
```

**✅ App Check warnings should be gone!**

---

## Do Team Members Need Their Own SHA Certificates?

**YES - Each developer needs their own!**

**Why?**
- SHA certificates are tied to your machine's Android debug keystore
- Located at: `~/.android/debug.keystore` (Mac) or `C:\Users\YourName\.android\debug.keystore` (Windows)
- Each computer has a different keystore

**What this means:**
- Developer A's SHA won't work for Developer B
- Each team member must add their SHA certificates ONCE
- After adding, you're good forever (unless you change computers)

**Good news:**
- This is a one-time setup per developer
- Firebase allows unlimited SHA certificates per app
- You don't need to remove old ones

---

## SHA Certificates Quick Reference

| What | When |
|------|------|
| Add your SHA-1 & SHA-256 | First time running on a new computer |
| Add App Check debug token | First time running on a new device/emulator |
| Download `google-services.json` | After adding SHA certificates |
| Run `flutter clean` | After updating `google-services.json` |

---

## Still Having Issues?

### Check the Logs
Look for these specific error messages:

**"Unknown calling package name 'com.google.android.gms'"**
- This is just a warning on emulators
- Safe to ignore

**"DEVELOPER_ERROR" in logs**
- Missing SHA certificates
- Follow Step 1-3 above

**"Error 10" from Google Sign-In**
- Missing SHA certificates
- Follow Step 1-3 above

**"Permission denied" from Firestore**
- You're not signed in
- Try signing in first

### Debug Checklist
- [ ] Added SHA-1 to Firebase
- [ ] Added SHA-256 to Firebase
- [ ] Downloaded updated `google-services.json`
- [ ] Placed `google-services.json` in `android/app/` folder
- [ ] Ran `flutter clean`
- [ ] Ran `flutter pub get`
- [ ] Restarted the app completely

### Get the Debug SHA Again (If you forgot)
```bash
cd android
./gradlew signingReport | grep SHA  # Mac/Linux
.\gradlew signingReport | Select-String SHA  # Windows PowerShell
cd ..
```

---

## Production Release (Future)

When building for production release, you'll need:
1. **Release keystore SHA-1 & SHA-256** (different from debug)
2. **Google Play Store SHA-1** (added automatically by Play Store)
3. **App Check with Play Integrity** (not debug tokens)

For now, we're only using debug keystores for development.
