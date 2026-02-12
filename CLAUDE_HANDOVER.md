# Subsum — Claude Code Handover Document

> **Last updated:** February 2026
> **Last commit:** `0eda3b1` — "Implement full Subsum app: MVVM + SwiftData, all screens, StoreKit 2, notifications"
> **Branch:** `main`

---

## What Is Subsum?

Subsum is a subscription tracking iOS app. It is NOT a budgeting app or finance platform — it is a "clarity tool" that helps young professionals (22–35) see their real monthly subscription spending without connecting a bank account. All data is local, manual entry only, no backend, no third-party SDKs.

The single source of truth for product requirements is `Subsum_Product_Document.md` in the project root.

---

## Current State: What Has Been Implemented

The app is **fully implemented end-to-end** per the v1 spec. It builds and runs successfully on Xcode 26.x targeting iOS 26.2.

### Completed Features

| Feature | Status | File(s) |
|---------|--------|---------|
| SwiftData models (Subscription + UserSettings) | Done | `Models/Subscription.swift`, `Models/UserSettings.swift` |
| Currency support (10 currencies) | Done | `Models/CurrencyOption.swift` |
| App shell with onboarding routing | Done | `SubsumApp.swift`, `ContentView.swift` |
| 3-screen onboarding (no paywall) | Done | `Views/Onboarding/OnboardingView.swift` |
| Overview screen (hero total, blurred yearly, upcoming charges) | Done | `Views/Overview/OverviewScreen.swift` |
| Add/Edit subscription form | Done | `Views/Subscriptions/AddSubscriptionView.swift` |
| Subscriptions list (swipe edit/delete) | Done | `Views/Subscriptions/SubscriptionsScreen.swift` |
| Insights screen (locked free / charts Pro) | Done | `Views/Insights/InsightsScreen.swift` |
| Settings screen | Done | `Views/Settings/SettingsScreen.swift` |
| Paywall (monthly + yearly, 7-day trial) | Done | `Views/Paywall/PaywallView.swift` |
| NotificationManager (centralized) | Done | `Managers/NotificationManager.swift` |
| PurchaseManager (StoreKit 2) | Done | `Managers/PurchaseManager.swift` |
| BiometricManager (Face ID/Touch ID/Optic ID) | Done | `Managers/BiometricManager.swift` |
| Design system (glass cards, colors, ProBadge) | Done | `UI/DesignSystem.swift` |
| Feature gating (clarity-gated, no hard sub limit) | Done | Wired across Overview, Insights, Settings |
| StoreKit config for testing | Done | `SubsumProducts.storekit` |
| Debug/God Mode (DEBUG-only) | Done | `Views/Settings/SettingsScreen.swift` (#if DEBUG section) |
| CSV export | Done | `Views/Settings/SettingsScreen.swift` |
| Biometric lock screen | Done | `ContentView.swift` (LockScreenView) |

### What Has NOT Been Implemented

- **Widgets** — mentioned in spec under Pro features but not built for v1
- **Advanced filters** — mentioned in spec under Pro features but not built for v1
- **iCloud sync** — spec explicitly says no cloud for v1
- **Analytics** — spec explicitly says no analytics SDK for v1
- **Privacy Policy page** — the button exists in Settings but has no action (needs a URL or webview)

---

## Architecture Overview

### Pattern
MVVM with SwiftData. No Combine, no third-party dependencies.

### Key Technical Decisions

1. **iOS 26.2 deployment target** — project was created in Xcode 26.x. Uses Swift 6 concurrency features with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
2. **`@Observable` macro** — all ViewModels and Managers use `@Observable` (not `ObservableObject`). They are passed via `.environment()` not `@EnvironmentObject`
3. **SwiftData `@Model`** — `Subscription` and `UserSettings` are `@Model` classes. Enums (`BillingFrequency`, `SubscriptionCategory`) are stored as raw String values because SwiftData doesn't natively support enums with associated values
4. **Computed properties for all derived data** — monthly total, yearly projection, category breakdowns, upcoming charges are never stored
5. **Singleton managers** — `NotificationManager.shared`, `PurchaseManager.shared`, `BiometricManager.shared`
6. **`PBXFileSystemSynchronizedRootGroup`** — the Xcode project auto-discovers files on disk. No need to manually add files to the `.pbxproj`

### File Organization

```
Subsum/
├── SubsumApp.swift              — @main, SwiftData modelContainer
├── ContentView.swift            — Root routing (onboarding → lock → tabs), LockScreenView, MainTabView
├── Models/                      — Data layer
├── ViewModels/                  — Business logic
├── Managers/                    — NotificationManager, PurchaseManager, BiometricManager
├── UI/                          — Design system, reusable components
├── Views/
│   ├── Onboarding/
│   ├── Overview/
│   ├── Subscriptions/
│   ├── Insights/
│   ├── Settings/
│   └── Paywall/
├── SubsumProducts.storekit      — StoreKit test config
└── Assets.xcassets/
```

### Data Flow

1. `SubsumApp` creates the SwiftData `modelContainer` for `[Subscription.self, UserSettings.self]`
2. `ContentView` receives `modelContext` from environment, creates `SubscriptionViewModel` and `SettingsViewModel` as `@State`, injects them via `.environment()`
3. All screens read from these ViewModels. The ViewModels hold a reference to `modelContext` and perform CRUD operations
4. `PurchaseManager` syncs Pro state with `SettingsViewModel.isProUser` on launch and after purchases

### Feature Gating Logic

```
if settingsVM.isProUser == false:
  - Yearly projection → blurred with lock overlay
  - Insights screen → locked preview with blurred charts
  - Custom reminder timing → hidden, shows ProBadge
  - Biometric lock → not shown
  - CSV export → not shown
  - Upgrade tease card → visible on Overview
```

The upgrade trigger fires when user has 3+ subscriptions and taps the blurred yearly projection → opens PaywallView.

### StoreKit Product IDs

- Monthly: `com.hasoo.subsum.pro.monthly` — $2.99/month + 7-day trial
- Yearly: `com.hasoo.subsum.pro.yearly` — $23.99/year + 7-day trial

### Bundle ID

`com.hasoo.Subsum` — Development Team: `84A7MKHC83`

---

## How To Build and Test

1. Open `Subsum.xcodeproj` in Xcode 26
2. **Edit Scheme → Run → Options → StoreKit Configuration** → select `SubsumProducts.storekit`
3. Build and run on any iOS 26 simulator (e.g. iPhone 17 Pro)
4. In Settings, scroll to bottom for **Debug** section:
   - **God Mode (Pro)** — toggle Pro on/off instantly
   - **Add Sample Subscriptions** — adds 7 realistic entries
   - **Reset Onboarding** — re-triggers onboarding on relaunch
   - **Clear All Subscriptions** — wipes data

The Debug section is wrapped in `#if DEBUG` and does not exist in Release builds.

---

## Known Issues / Technical Debt

1. **Privacy Policy button** in Settings has no action — needs a URL or embedded webview
2. **No unit tests** — ViewModels and Managers are testable but no tests have been written yet
3. **No localization** — all strings are hardcoded in English
4. **Subscription.advanceNextChargeDate()** is called on every fetch — works but could be optimized to only run when needed
5. **StoreKit config file** (`SubsumProducts.storekit`) is for local testing only — real product IDs must be configured in App Store Connect before release
6. **Widgets** and **Advanced filters** from the spec are not yet implemented

---

## Documentation Files

| File | Purpose |
|------|---------|
| `Subsum_Product_Document.md` | Product spec — single source of truth for features and behavior |
| `Subsum_Project_Structure.md` | Folder layout, architecture, and testing guide |
| `Subsum_Debug_Mode_Guide.md` | Detailed instructions for using Debug/God Mode and disabling it for release |
| `CLAUDE_HANDOVER.md` | This file — context for continuing development in a new session |

---

## Conventions To Follow

- **Spec compliance** — do not add features not in the product document unless explicitly discussed
- **Lowest-scope interpretation** — if anything is ambiguous, choose the simplest approach that preserves the spec's intent
- **Dark mode first** — `.preferredColorScheme(.dark)` is set at the root
- **Glass styling** — use `.ultraThinMaterial` backgrounds with `RoundedRectangle(cornerRadius: 16)` for cards
- **No third-party SDKs** — everything is built with Apple frameworks only
- **Keep it compiling** — every change should leave the project in a buildable state
- **`#if DEBUG`** — any developer-only tooling must be wrapped in compiler directives
