# Subsum Debug / God Mode Guide

## What Is Debug Mode?

The Debug section is a hidden panel at the bottom of the **Settings** tab that only appears when the app is compiled in `DEBUG` mode (i.e. during development in Xcode). It is completely invisible and inaccessible in `Release` builds — which is what ships to the App Store.

It provides four tools:

| Tool | What It Does |
|------|-------------|
| **God Mode (Pro)** | Toggle to instantly enable/disable Pro status without going through StoreKit |
| **Reset Onboarding** | Clears the onboarding-completed flag so the 3-screen flow shows again on next launch |
| **Add Sample Subscriptions** | Inserts 7 realistic subscriptions (Netflix, Spotify, iCloud+, ChatGPT Plus, YouTube Premium, Apple One, Nintendo Online) with random upcoming charge dates |
| **Clear All Subscriptions** | Deletes every subscription from the database |

---

## How To Use Debug Mode During Development

1. Open `Subsum.xcodeproj` in Xcode
2. Make sure the **scheme** is set to **Debug** (this is the default when you hit Run):
   - Click the scheme selector in the toolbar (next to the device picker)
   - Click **Edit Scheme...**
   - Under **Run** → **Info**, confirm **Build Configuration** is set to **Debug**
3. Build and run on a simulator or device
4. Navigate to the **Settings** tab
5. Scroll to the bottom — you will see the **Debug** section with the ladybug icon

### Testing Pro Features

- Toggle **God Mode (Pro)** ON → all Pro features unlock immediately (yearly projection unblurs, Insights charts appear, custom reminders become available, biometric lock and CSV export activate)
- Toggle **God Mode (Pro)** OFF → the app reverts to free-tier behavior (yearly projection blurs, Insights locks, etc.)

### Testing Onboarding

- Tap **Reset Onboarding** → close and relaunch the app (or the state will update on next app launch) to see the full 3-screen onboarding flow again

### Populating Test Data

- Tap **Add Sample Subscriptions** → 7 subscriptions appear across the app with randomized charge dates
- You can tap it multiple times to add more (duplicates will be created)
- Tap **Clear All Subscriptions** to wipe everything and start fresh

---

## How To Disable Debug Mode For App Store Release

**You do not need to manually remove any code.** The Debug section is wrapped in a Swift compiler directive:

```swift
#if DEBUG
debugSection
#endif
```

This means:

- **Debug builds** (running from Xcode with the Run button, TestFlight internal builds with Debug config) → Debug section **is visible**
- **Release builds** (Archive for App Store, TestFlight release builds) → Debug section **is completely compiled out** — the code does not exist in the binary at all

### Verifying It Is Gone Before Submission

If you want to double-check before submitting to the App Store:

1. In Xcode, go to **Product** → **Archive**
2. Archiving always uses the **Release** build configuration
3. Install the archived build on a device via the Organizer window or export an `.ipa`
4. Open the app and go to Settings — the Debug section will not be there

Alternatively, you can test the Release configuration on a simulator:

1. **Edit Scheme** → **Run** → **Info**
2. Change **Build Configuration** from `Debug` to `Release`
3. Build and run
4. Go to Settings — the Debug section will be gone
5. **Remember to switch back to Debug** when you resume development

---

## How To Bring Debug Mode Back

If you previously switched to Release for testing and want Debug tools back:

1. **Edit Scheme** → **Run** → **Info**
2. Change **Build Configuration** back to **Debug**
3. Build and run — the Debug section reappears in Settings

No code changes needed. It is purely controlled by the build configuration.

---

## Important Notes

- **God Mode bypasses StoreKit entirely.** It sets `isProUser` directly in the local database. This is independent of any real subscription state. When you are ready to test the actual StoreKit purchase flow, turn God Mode OFF and use the StoreKit configuration file instead.
- **God Mode state persists across launches.** If you toggle it on and relaunch the app, Pro will still be active. Toggle it off explicitly when you want to test the free tier.
- **The Debug section has zero impact on production.** The `#if DEBUG` compiler directive guarantees the code is not included in Release builds. There is nothing to remove, comment out, or clean up before shipping.

---

## Quick Reference

| I want to... | Do this |
|--------------|---------|
| Test Pro features quickly | Settings → Debug → God Mode ON |
| Test free-tier experience | Settings → Debug → God Mode OFF |
| Test onboarding again | Settings → Debug → Reset Onboarding → relaunch app |
| Fill app with test data | Settings → Debug → Add Sample Subscriptions |
| Start with empty state | Settings → Debug → Clear All Subscriptions |
| Test real StoreKit purchases | God Mode OFF + Edit Scheme → Options → StoreKit Configuration → `SubsumProducts.storekit` |
| Verify Debug is hidden in release | Edit Scheme → Run → Build Configuration → Release → Build and check Settings |
| Ship to App Store | Just Archive — Debug section is automatically excluded |
