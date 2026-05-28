import StoreKit
import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var services: AppServices

    var body: some View {
        PaywallContent(store: services.subscriptionStore)
    }
}

private struct PaywallContent: View {
    @ObservedObject var store: SubscriptionStore

    private let tiers: [PaywallTier] = [
        PaywallTier(
            name: "Free",
            price: "\u{00A3}0",
            subtitle: "Limited sessions, basic drills, limited exports",
            features: ["Limited AI sessions", "Basic drill cards", "Starter library", "Coaching disclaimer"],
            plan: .free,
            accent: .white
        ),
        PaywallTier(
            name: "Pro Coach",
            price: "\u{00A3}14.99 / month",
            subtitle: "For private coaches, schools, grassroots and academy staff",
            features: ["Unlimited AI sessions", "Voice input", "Tactical board", "Animated drills", "Premium PDF exports", "Advanced analytics"],
            plan: .proCoach,
            accent: .tactiCoreNeon
        ),
        PaywallTier(
            name: "Elite Club",
            price: "\u{00A3}49.99 / month",
            subtitle: "For clubs building a complete coaching operating system",
            features: ["Academy management placeholder", "Advanced tactical analysis", "Team collaboration placeholder", "Premium branding", "Advanced player tracking"],
            plan: .eliteClub,
            accent: .tactiCoreGold
        )
    ]

    var body: some View {
        ZStack {
            CinematicBackground(assetKind: .recoveryCircle)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(
                        eyebrow: "Subscription",
                        title: "Unlock the full coaching OS",
                        subtitle: "Premium plans are scaffolded with StoreKit 2 and placeholder product identifiers for App Store Connect.",
                        assetKind: .recoveryCircle
                    )

                    ForEach(tiers) { tier in
                        tierCard(tier)
                    }

                    PremiumContainer(accent: .tactiCoreBlue) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Pro Coach Yearly")
                                .font(.headline.weight(.black))
                                .foregroundStyle(.white)
                            Text("\u{00A3}119.99 / year")
                                .font(.title3.weight(.black))
                                .foregroundStyle(.tactiCoreNeon)
                            Text("Annual placeholder product: tacticore.pro.yearly")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.62))
                        }
                    }

                    HStack(spacing: 10) {
                        IconActionButton(title: "Load Products", systemImage: "arrow.clockwise", accent: .tactiCoreBlue) {
                            Task { await store.loadProducts() }
                        }
                        IconActionButton(title: "Restore", systemImage: "arrow.uturn.backward.circle.fill", accent: .tactiCoreGold) {
                            Task { await store.restorePurchases() }
                        }
                    }

                    if !store.products.isEmpty {
                        PremiumContainer(accent: .tactiCoreNeon) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("StoreKit products")
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(.white)
                                ForEach(store.products, id: \.id) { product in
                                    IconActionButton(title: "Purchase \(product.displayName) \(product.displayPrice)", systemImage: "creditcard.fill", accent: .tactiCoreNeon) {
                                        Task { await store.purchase(product) }
                                    }
                                }
                            }
                        }
                    }

                    if let error = store.errorMessage {
                        TacticalInsightCard(insight: CoachingInsight(title: "StoreKit Placeholder", detail: error, tag: "StoreKit 2"), accent: .tactiCoreGold)
                    }

                    Text(CoachingDisclaimer.full)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.56))
                }
                .padding(20)
            }
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func tierCard(_ tier: PaywallTier) -> some View {
        PremiumContainer(accent: tier.accent) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(tier.name)
                            .font(.title2.weight(.black))
                            .foregroundStyle(.white)
                        Text(tier.price)
                            .font(.headline.weight(.black))
                            .foregroundStyle(tier.accent)
                        Text(tier.subtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.64))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    if store.currentPlan == tier.plan {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title2)
                            .foregroundStyle(tier.accent)
                    }
                }

                ForEach(tier.features, id: \.self) { feature in
                    Label(feature, systemImage: "checkmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))
                }

                IconActionButton(title: tier.plan == .free ? "Use Free" : "Activate Mock \(tier.name)", systemImage: tier.plan == .free ? "circle" : "crown.fill", accent: tier.accent) {
                    store.activateMockPlan(tier.plan)
                }
            }
        }
    }
}

private struct PaywallTier: Identifiable {
    let id = UUID()
    var name: String
    var price: String
    var subtitle: String
    var features: [String]
    var plan: SubscriptionPlan
    var accent: Color
}
