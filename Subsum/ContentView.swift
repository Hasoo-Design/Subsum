import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var settingsVM = SettingsViewModel()
    @State private var subscriptionVM = SubscriptionViewModel()
    @State private var showOnboarding = true
    @State private var isLocked = false

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(onComplete: completeOnboarding)
            } else if isLocked {
                LockScreenView(onUnlock: { isLocked = false })
            } else {
                MainTabView()
            }
        }
        .environment(settingsVM)
        .environment(subscriptionVM)
        .preferredColorScheme(.dark)
        .onAppear {
            settingsVM.modelContext = modelContext
            subscriptionVM.modelContext = modelContext
            settingsVM.fetchSettings()
            subscriptionVM.fetchSubscriptions()
            showOnboarding = !settingsVM.hasCompletedOnboarding

            if settingsVM.biometricLockEnabled && settingsVM.isProUser {
                isLocked = true
            }

            Task {
                await PurchaseManager.shared.refreshEntitlementStatus()
                if PurchaseManager.shared.isPro {
                    settingsVM.isProUser = true
                }
            }
        }
    }

    private func completeOnboarding() {
        settingsVM.hasCompletedOnboarding = true
        withAnimation(.easeInOut(duration: 0.4)) {
            showOnboarding = false
        }
    }
}

struct LockScreenView: View {
    var onUnlock: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Subsum is Locked")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Authenticate to continue")
                .foregroundStyle(.secondary)
            Button("Unlock") {
                Task {
                    let success = await BiometricManager.shared.authenticate()
                    if success { onUnlock() }
                }
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .task {
            let success = await BiometricManager.shared.authenticate()
            if success { onUnlock() }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Overview", systemImage: "square.grid.2x2") {
                OverviewScreen()
            }
            Tab("Subscriptions", systemImage: "list.bullet") {
                SubscriptionsScreen()
            }
            Tab("Insights", systemImage: "chart.pie") {
                InsightsScreen()
            }
            Tab("Settings", systemImage: "gearshape") {
                SettingsScreen()
            }
        }
        .tint(.white)
    }
}
