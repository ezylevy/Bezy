# BEZY V1 Release Checklist

Last updated: 26 September 2026

## Already prepared in the repository

- [x] Production identifiers: Android and iOS use `com.ezylevy.bezy`.
- [x] Public app label is `BEZY` (the Android “Test” label was removed).
- [x] Version is `1.0.0+1`; every upload must use a higher build number.
- [x] Free Play is hidden from V1 but retained behind a feature switch.
- [x] No Android runtime permissions are requested.
- [x] iOS declares that the app does not use non-exempt encryption.
- [x] Upload-keystore configuration is supported without committing secrets.
- [x] English/Hebrew store copy, review notes, and privacy-policy text exist.
- [x] Automated tests verify all 50 cached solutions and every open stage from
  25 through 50 using cache-free DFS.

## Owner actions required before a store build

- [ ] Approve a final BEZY app icon. The repository still contains the default
  Flutter launcher icon, which is not suitable for publication.
- [ ] Produce truthful screenshots from stable builds (recommended: home,
  world map, normal board, Joker/teleport board, and victory). Apple accepts
  1–10 screenshots per device class; Google Play also requires preview assets.
- [ ] Produce a Google Play feature graphic and localized screenshots if desired.
- [ ] Replace the support-email placeholder in `PRIVACY_POLICY.md`, publish it
  at a stable public HTTPS URL, and create a public support page/URL.
- [ ] Confirm ownership/licensing for every image and sound asset.
- [ ] Decide whether the app is listed as “Made for Kids”. Do not select it
  casually: Apple treats this as a lasting category commitment. Complete both
  stores' target-audience and content-rating questionnaires truthfully.

## Android / Google Play

1. Create or verify a Play Console developer account and complete developer
   identity verification.
2. Reserve package `com.ezylevy.bezy`. A package name cannot be changed after
   the first Play release.
3. Generate a private upload keystore whose certificate remains valid beyond
   22 October 2033. Back it up securely outside the repository.
4. Copy `android/key.properties.example` to `android/key.properties`, fill in
   the local path, alias, and passwords, then run:

   ```powershell
   flutter clean
   flutter pub get
   flutter analyze
   flutter test
   flutter build appbundle --release
   ```

5. Confirm the build used the private upload key, then upload
   `build/app/outputs/bundle/release/app-release.aab` and enroll in Play App
   Signing. Never upload a debug-signed bundle.
6. Complete App content: privacy policy, ads = No, app access = unrestricted,
   target audience, content rating, news declaration if shown, and Data safety.
   Current code supports “no data collected or shared”; re-audit dependencies
   before answering.
7. Add store listing text/assets, category, contact details, countries, and
   pricing. Start with Internal testing, promote to Closed/Open testing as
   required by the account, then Production.
8. Verify the final AAB targets the Play-required API level. As of this checklist,
   Google requires Android 15 / API 35 or higher for applicable phone apps.

Official references:

- https://developer.android.com/studio/publish/preparing
- https://developer.android.com/studio/publish/app-signing
- https://support.google.com/googleplay/android-developer/answer/11926878
- https://support.google.com/googleplay/android-developer/answer/9866151

## iOS / App Store

1. Enroll in the Apple Developer Program and accept current agreements.
2. On macOS with Xcode, register the explicit App ID `com.ezylevy.bezy` and
   create the App Store Connect app record. Let Xcode manage distribution
   signing, or create the matching certificate and provisioning profile.
3. Open `ios/Runner.xcworkspace`, assign the correct Team, confirm the bundle
   ID, version/build number, supported devices, orientations, and signing.
4. Run the full suite, archive a Release build, validate it in Xcode, and upload
   it to App Store Connect/TestFlight.
5. Enter both localizations, category, age rating, content rights, copyright,
   support URL, privacy-policy URL, screenshots, availability, and price.
6. App Privacy answer for the current build: “No, we do not collect data from
   this app.” Re-audit this if analytics, crash reporting, ads, accounts, or any
   network SDK is added.
7. Test through TestFlight on real iPhone/iPad hardware, attach the selected
   build, add the review notes from `STORE_LISTING.md`, and submit for review.

Official references:

- https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile
- https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
- https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots
- https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app

## Final release gate

- [ ] `flutter analyze` is clean.
- [ ] Full `flutter test` passes.
- [ ] Signed Android AAB passes Play pre-launch/internal testing.
- [ ] Signed iOS archive passes validation and TestFlight testing.
- [ ] Portrait/landscape, Hebrew/English, fresh install, upgrade, offline use,
  sound/haptics, persistence, and all special cells are manually tested.
- [ ] Store screenshots match the submitted build and do not show hidden Free Play.
- [ ] Privacy declarations still match the exact production binary and SDKs.
- [ ] Git tag the approved commit (recommended: `v1.0.0`) only after both store
  binaries are built from it.
