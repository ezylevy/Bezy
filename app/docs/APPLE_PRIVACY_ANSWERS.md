# Apple App Privacy Answers — BEZY 1.0

These answers reflect the current source code and dependency list. Re-check
them before every release if analytics, crash reporting, advertising, accounts,
networking, or a new third-party SDK is added.

## App Store Connect → App Privacy

- **Privacy Policy URL:** `[PUBLISH docs/privacy-policy.html AND INSERT HTTPS URL]`
- **User Privacy Choices URL:** leave blank (optional; no remote user data exists)
- **Does this app or its third-party partners collect data?** No
- Select **“No, we do not collect data from this app”**, save, and publish the
  privacy response.
- **Tracking:** No

Why: BEZY has no account, ads, analytics, crash-reporting or network SDK. Game
progress and preferences are stored locally with `shared_preferences` and are
not transmitted off the device.

## Other related App Store fields

- **Support email:** `naraelapp@gmail.com`
- **Support URL:** `[PUBLISH docs/support.html AND INSERT HTTPS URL]`
- **Marketing URL:** optional; leave blank until a public site exists
- **App access:** no login or review account required
- **Export compliance:** the app does not implement non-exempt encryption;
  `ITSAppUsesNonExemptEncryption` is already `false` in `Info.plist`
- **Advertising identifier / tracking permission:** not used
- **Content rights:** confirm that Ezy Levy/BEZY owns or licenses every included
  image, sound, and logo before selecting the applicable confirmation

Apple requires an HTTPS privacy-policy URL; an email address alone cannot be
entered in that field.
