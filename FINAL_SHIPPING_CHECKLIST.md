# FinTrack - Final Shipping Checklist

Complete this checklist to ship your app. Check off each item as you complete it.

## Phase 1: Setup (Estimated: 1-2 hours)

### Developer Accounts
- [ ] Create Apple Developer Account
  - [ ] Cost: $99/year
  - [ ] URL: developer.apple.com/account
  - [ ] Save login credentials

- [ ] Create Google Play Developer Account
  - [ ] Cost: $25 one-time
  - [ ] URL: play.google.com/console
  - [ ] Save login credentials

### Asset Preparation
- [ ] Design/Prepare App Icon (1024x1024 PNG)
  - [ ] File ready: __________
  - [ ] File location: __________

- [ ] Prepare Screenshots
  - [ ] iPhone screenshots (minimum 2)
  - [ ] Android screenshots (minimum 4-8)
  - [ ] Location saved: __________

- [ ] Create Privacy Policy
  - [ ] URL ready: __________
  - [ ] Copy saved locally

- [ ] Write App Description
  - [ ] Short description (80 chars): __________
  - [ ] Full description (4000 chars): __________
  - [ ] Keywords: __________
  - [ ] Support email: __________

---

## Phase 2: App Configuration (Estimated: 1 hour)

### iOS Configuration
- [ ] Open ios/Runner.xcworkspace in Xcode
- [ ] Update Bundle ID
  - [ ] From: ____________
  - [ ] To: com.yourcompany.financeapp
  
- [ ] Update App Name
  - [ ] Display Name: FinTrack
  
- [ ] Set Version
  - [ ] Version: 1.0.0
  - [ ] Build: 1

- [ ] Add App Icon
  - [ ] 1024x1024 PNG ready
  - [ ] Placed in Assets.xcassets

- [ ] Set Minimum iOS Version
  - [ ] Version: 12.0

### Android Configuration
- [ ] Edit android/app/build.gradle
- [ ] Update Package Name
  - [ ] From: ____________
  - [ ] To: com.yourcompany.financeapp

- [ ] Update Version
  - [ ] versionCode: 1
  - [ ] versionName: "1.0.0"

- [ ] Add App Icon
  - [ ] 512x512 PNG ready
  - [ ] Placed in mipmap folders

- [ ] Set Minimum Android Version
  - [ ] minSdkVersion: 21

---

## Phase 3: Code Verification (Estimated: 30 minutes)

- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Run `flutter analyze` (verify no critical errors)
- [ ] Test app on iOS device/simulator
  - [ ] All features working
  - [ ] Dark mode working
  - [ ] No crashes
  
- [ ] Test app on Android device/emulator
  - [ ] All features working
  - [ ] Dark mode working
  - [ ] No crashes

---

## Phase 4: Building Releases (Estimated: 30-45 minutes)

### Automated Build (Recommended)
- [ ] Make build script executable
  - [ ] Run: `chmod +x build-release.sh`

- [ ] Run build script
  - [ ] Run: `./build-release.sh`
  - [ ] Wait for completion
  - [ ] Verify no errors

### Manual Build (Alternative)
- [ ] Build iOS Release
  - [ ] Run: `flutter build ios --release`
  - [ ] Verify output in: build/ios/iphoneos/Runner.app

- [ ] Build Android AAB
  - [ ] Run: `flutter build appbundle --release`
  - [ ] Verify output in: build/app/outputs/bundle/release/

---

## Phase 5: iOS Submission (App Store Connect)

- [ ] Log in to App Store Connect
  - [ ] Username: __________
  - [ ] Password: [saved securely]

- [ ] Create New App
  - [ ] Bundle ID: com.yourcompany.financeapp
  - [ ] App Name: FinTrack
  - [ ] Primary Language: English

- [ ] Configure App Information
  - [ ] Privacy Policy URL: __________
  - [ ] Support URL: __________
  - [ ] Email: __________

- [ ] Add App Icon
  - [ ] 1024x1024 PNG uploaded

- [ ] Add Screenshots
  - [ ] Minimum 2 screenshots for iPhone
  - [ ] In correct resolution format

- [ ] Fill in App Preview
  - [ ] Description: [from your list]
  - [ ] Keywords: [from your list]
  - [ ] Category: Finance

- [ ] Set Pricing
  - [ ] Free or paid: Free (recommended for v1.0)

- [ ] Build & Upload
  - [ ] Use Transporter app to upload
  - [ ] Select iOS build from: build/ios/iphoneos/Runner.app
  - [ ] Verify upload successful

- [ ] Submit for Review
  - [ ] All information complete
  - [ ] Ready for submission
  - [ ] Date submitted: __________

- [ ] Track Review Status
  - [ ] Check status daily in App Store Connect
  - [ ] Note: Usually 1-3 days

---

## Phase 6: Android Submission (Google Play)

- [ ] Log in to Google Play Console
  - [ ] Username: __________
  - [ ] Password: [saved securely]

- [ ] Create New App
  - [ ] App Name: FinTrack
  - [ ] Default Language: English

- [ ] Add App Icon
  - [ ] 512x512 PNG uploaded

- [ ] Add Screenshots
  - [ ] 4-8 screenshots (1080x1920)
  - [ ] Uploaded for phone category

- [ ] Add Feature Graphic
  - [ ] 1024x500 PNG (optional but recommended)

- [ ] Fill in Store Listing
  - [ ] Short Description (80 chars): __________
  - [ ] Full Description: __________
  - [ ] Category: Finance
  - [ ] Content Rating: [Complete questionnaire]

- [ ] Set Pricing
  - [ ] Free (recommended for v1.0)

- [ ] Configure Release
  - [ ] Upload AAB file: app-release.aab
  - [ ] Verify upload successful

- [ ] Review & Publish
  - [ ] All information complete
  - [ ] Submit for review
  - [ ] Date submitted: __________

- [ ] Track Review Status
  - [ ] Check status in Play Console
  - [ ] Note: Usually <24 hours

---

## Phase 7: Post-Submission (1-3 days)

### Monitoring
- [ ] Set up email notifications for both stores
- [ ] Check for rejection emails daily
- [ ] Monitor crash reports

### If Approved ✅
- [ ] App appears on Apple App Store
- [ ] App appears on Google Play Store
- [ ] Create social media posts
- [ ] Share with friends and family
- [ ] Request reviews from beta testers

### If Rejected ❌
- [ ] Read rejection reason carefully
- [ ] Fix the issue
- [ ] Resubmit for review

---

## Phase 8: Launch & Monitoring

- [ ] App live on both stores
- [ ] Test download from live stores
- [ ] Monitor app reviews
- [ ] Respond to user feedback
- [ ] Fix bugs if reported
- [ ] Plan v1.1 features

---

## Post-Launch Tasks

### Immediate (First Week)
- [ ] Monitor crash reports
- [ ] Respond to user reviews
- [ ] Fix any critical bugs
- [ ] Gather user feedback

### Short-term (Weeks 2-4)
- [ ] Analyze user data
- [ ] Plan v1.1 features
- [ ] Create update roadmap
- [ ] Build community

### Medium-term (Months 2-3)
- [ ] Cloud backup implementation
- [ ] Additional features
- [ ] Bug fixes and improvements
- [ ] Marketing push

---

## Important Notes

**App Identifiers:**
- iOS Bundle ID: ___________________________
- Android Package Name: ___________________________

**Account Information:**
- Apple Dev Account: ___________________________
- Google Play Account: ___________________________

**Support Email:** ___________________________

**Privacy Policy URL:** ___________________________

**Submission Dates:**
- iOS Submitted: _____________ Status: ________
- Android Submitted: _____________ Status: ________
- iOS Approved: _____________ Live Date: _______
- Android Approved: _____________ Live Date: _______

---

## Files Location Reference

- Project: `/Users/vaishnavkrishnanunni/flutter-dev/finance_app`
- iOS Build: `build/ios/iphoneos/Runner.app`
- Android AAB: `build/app/outputs/bundle/release/app-release.aab`
- Documentation: `SHIPPING_GUIDE.md`

---

## Final Checklist Before Submitting

- [ ] All code changes committed
- [ ] App tested on real devices
- [ ] Version numbers updated everywhere
- [ ] Bundle ID / Package Name updated
- [ ] App icons added
- [ ] Screenshots prepared
- [ ] Privacy policy ready
- [ ] Support email set
- [ ] Builds created successfully
- [ ] Ready to upload to stores

---

**Good luck with your app launch! 🚀**

Check off items as you complete them. Once everything is checked, your app will be ready for the world!
