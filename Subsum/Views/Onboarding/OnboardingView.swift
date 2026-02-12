import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            TabView(selection: $currentPage) {
                OnboardingPage1()
                    .tag(0)
                OnboardingPage2()
                    .tag(1)
                OnboardingPage3(onComplete: onComplete)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            if currentPage < 2 {
                VStack {
                    Spacer()
                    Button {
                        withAnimation { currentPage += 1 }
                    } label: {
                        Text(currentPage == 0 ? "Continue" : "Start Tracking")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 60)
                }
            }
        }
    }
}

struct OnboardingPage1: View {
    @State private var animateStack = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(width: 200, height: 50)
                        .overlay {
                            HStack {
                                Circle()
                                    .fill(colors[index])
                                    .frame(width: 24, height: 24)
                                Text(labels[index])
                                    .font(.subheadline)
                                Spacer()
                                Text(prices[index])
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                        }
                        .offset(y: animateStack ? CGFloat(index) * 12 - 24 : CGFloat(index) * 58 - 116)
                        .opacity(animateStack ? (1.0 - Double(index) * 0.15) : 1.0)
                        .scaleEffect(animateStack ? (1.0 - Double(index) * 0.03) : 1.0)
                }
            }
            .frame(height: 180)

            Text("Subscriptions add up.")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            Text("Streaming, apps, cloud storage, tools —\nsmall payments become big monthly totals.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
                animateStack = true
            }
        }
    }

    private let labels = ["Netflix", "Spotify", "iCloud", "ChatGPT", "YouTube"]
    private let prices = ["$15.49", "$9.99", "$2.99", "$20.00", "$13.99"]
    private let colors: [Color] = [.red, .green, .blue, .purple, .red.opacity(0.8)]
}

struct OnboardingPage2: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 8) {
                Text("$184")
                    .font(.system(size: 64, weight: .bold, design: .rounded))

                Text("/month")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))

            Text("Most people underestimate\ntheir subscriptions.")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 12)

            Text("See your real monthly total.\nStay ahead of upcoming charges.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

struct OnboardingPage3: View {
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "lock.shield")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No bank connection\nrequired.")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Subsum works manually.\nYour data stays on your device.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button {
                onComplete()
            } label: {
                Text("Add Your First Subscription")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
    }
}
