# Quick Shipping Commands

Copy and paste these commands in order to build and prepare your app for shipping.

## 1. Navigate to Project
```bash
cd /Users/vaishnavkrishnanunni/flutter-dev/finance_app
```

## 2. Clean Build (Optional but Recommended)
```bash
flutter clean
flutter pub get
```

## 3. Verify Code Quality
```bash
flutter analyze
```

## 4. Build iOS Release
```bash
flutter build ios --release
```

✅ Output: `build/ios/iphoneos/Runner.app`

## 5. Build Android Release (App Bundle - Recommended)
```bash
flutter build appbundle --release
```

✅ Output: `build/app/outputs/bundle/release/app-release.aab`

## 6. Alternative: Build Android APK
```bash
flutter build apk --release --split-per-abi
```

✅ Output: `build/app/outputs/apk/release/`

---

## Next: Upload to App Stores

### iOS App Store Connect
1. Open Transporter app
2. Select the iOS build
3. Upload to App Store Connect
4. Complete app information
5. Submit for review

### Google Play Console
1. Go to Google Play Console
2. Select your app
3. Go to Release → Production
4. Upload the AAB file
5. Complete store listing
6. Review and publish

---

## Important Configuration

Before building, update these files:

### iOS: ios/Runner.xcworkspace
- Bundle ID: `com.yourcompany.financeapp`
- App Name: "FinTrack"
- Version: 1.0.0
- Build: 1

### Android: android/app/build.gradle
```gradle
android {
    defaultConfig {
        applicationId = "com.yourcompany.financeapp"
        versionCode = 1
        versionName = "1.0.0"
    }
}
```

---

## Build Verification Checklist

- [ ] Navigate to correct directory
- [ ] Run `flutter clean && flutter pub get`
- [ ] Run `flutter analyze` (should show only info warnings)
- [ ] Update Bundle ID / Package Name
- [ ] Update version numbers
- [ ] Prepare app icons (1024x1024 for iOS, 512x512 for Android)
- [ ] Run build commands
- [ ] Verify output directories
- [ ] Upload to respective app stores

---

## All Builds in One Command

Run this to build everything:
```bash
cd /Users/vaishnavkrishnanunni/flutter-dev/finance_app && \
flutter clean && \
flutter pub get && \
flutter analyze && \
flutter build ios --release && \
flutter build appbundle --release
```

---

## Check Build Outputs

```bash
# iOS Build Location
ls -la build/ios/iphoneos/Runner.app

# Android Build Location
ls -la build/app/outputs/bundle/release/

# Verify sizes
du -sh build/ios/iphoneos/Runner.app
du -sh build/app/outputs/bundle/release/app-release.aab
```

---

## Estimated Build Times

- iOS Release Build: 5-10 minutes
- Android AAB Build: 3-5 minutes
- Total: ~15 minutes

## Estimated Submission Times

- iOS App Store: 1-3 days review
- Google Play: 1 hour - 1 day review
- **Total to Launch: 1-3 days**

---

**Version**: 1.0.0+1
**Date**: January 29, 2026
**Status**: Ready for Production ✅
