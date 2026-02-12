# Subsum Project Structure

## Overview

Subsum is a SwiftUI + SwiftData app targeting iOS 26+. It follows MVVM architecture with no third-party dependencies. Dark mode first, glass material styling throughout.

## Folder Layout

```
Subsum/
├── SubsumApp.swift                          — App entry point, SwiftData model container
├── ContentView.swift                        — Root routing: Onboarding → Biometric Lock → TabView
├── SubsumProducts.storekit                  — StoreKit testing configuration (monthly + yearly)
│
├── Models/
│   ├── Subscription.swift                   — @Model: primary data entity
│   ├── UserSettings.swift                   — @Model: app-level preferences
│   └── CurrencyOption.swift                 — Currency list and symbol lookup
│
├── ViewModels/
│   ├── SubscriptionViewModel.swift          — CRUD, computed totals, category breakdowns
│   └── SettingsViewModel.swift              — Settings read/write, bindable properties
│
├── Managers/
│   ├── NotificationManager.swift            — Local notification scheduling per subscription
│   ├── PurchaseManager.swift                — StoreKit 2 products, purchase, entitlement refresh
│   └── BiometricManager.swift               — Face ID / Touch ID / Optic ID authentication
│
├── UI/
│   └── DesignSystem.swift                   — Colors, GlassCard, ProBadge, Decimal formatting
│
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift             — 3-screen emotional priming flow (no paywall)
│   ├── Overview/
│   │   └── OverviewScreen.swift             — Hero monthly total, blurred yearly, upcoming charges
│   ├── Subscriptions/
│   │   ├── SubscriptionsScreen.swift        — List with swipe edit/delete
│   │   └── AddSubscriptionView.swift        — Add/Edit form (name, price, frequency, date, category)
│   ├── Insights/
│   │   └── InsightsScreen.swift             — Locked preview (free) / Swift Charts (Pro)
│   ├── Settings/
│   │   └── SettingsScreen.swift             — Currency, notifications, Pro features, debug tools
│   └── Paywall/
│       └── PaywallView.swift                — Feature list, pricing cards, 7-day trial CTA
│
└── Assets.xcassets/                         — App icon, accent color
```

## Architecture

### Data Layer

- **SwiftData** with two `@Model` classes: `Subscription` and `UserSettings`
- All derived values (monthly total, yearly projection, category totals, upcoming charges) are computed properties — never stored
- `Subscription.advanceNextChargeDate()` auto-rolls past-due dates forward

### View Layer

- **4-tab structure**: Overview / Subscriptions / Insights / Settings
- Onboarding gates the main app until completed (stored in `UserSettings.hasCompletedOnboarding`)
- Biometric lock screen shown on launch when Pro + biometric lock enabled

### Feature Gating

Free tier:
- Unlimited subscriptions
- Monthly total
- Upcoming charges
- Basic reminder (1 day before)

Pro tier (gated by `UserSettings.isProUser`):
- Yearly projection (unblurred)
- Insights screen (charts unlocked)
- Custom reminder timing (1–7 days)
- Face ID / biometric lock
- CSV export

No hard subscription limit. Monetization is clarity-gated, not restriction-gated.

### StoreKit 2 Integration

- Two auto-renewable subscriptions: monthly ($2.99) and yearly ($23.99)
- Both include a 7-day free trial
- `PurchaseManager` handles product loading, purchase flow, entitlement verification, and transaction listener
- `SubsumProducts.storekit` provides local testing configuration

### Notifications

- `NotificationManager` is a centralized singleton
- Schedules one `UNCalendarNotificationTrigger` per active subscription
- Trigger date = `nextChargeDate` minus `defaultReminderDays`
- Notifications are rescheduled when subscriptions are added/edited or reminder timing changes

## Debug Tools

In `DEBUG` builds only, the Settings screen includes:

- **God Mode (Pro)** — toggle Pro on/off instantly
- **Reset Onboarding** — re-triggers onboarding flow
- **Add Sample Subscriptions** — populates 7 realistic subscriptions
- **Clear All Subscriptions** — wipes all data

This section is compiled out of Release builds via `#if DEBUG`.

## Testing in Xcode

1. Open `Subsum.xcodeproj` in Xcode 26
2. Edit Scheme → Run → Options → StoreKit Configuration → select `SubsumProducts.storekit`
3. Build and run on any iOS 26 simulator
4. Use the Debug section in Settings to toggle Pro, add sample data, or reset onboarding
