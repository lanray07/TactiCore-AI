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
            name: "Pro Coach Monthly",
            productID: "tacticore.pro.monthly",
            displayPrice: "£14.99",
            billingPeriod: "1 month",
            unitPrice: "£14.99 per month",
            subtitle: "Unlimited AI sessions, voice input, tactical board, animated drills, premium exports and advanced analytics.",
            accent: .tactiCoreNeon
        ),
        PaywallTier(
            name: "Pro Coach Yearly",
            productID: "tacticore.pro.yearly",
            displayPrice: "£119.99",
            billingPeriod: "1 year",
            unitPrice: "£119.99 per year, equivalent to £10.00 per month",
            subtitle: "The full Pro Coach workflow with annual billing for coaches who plan every week.",
            accent: .tactiCoreBlue
        ),
        PaywallTier(
            name: "Elite Club Monthly",
            productID: "tacticore.elite.monthly",
            displayPrice: "£49.99",
            billingPeriod: "1 month",
            unitPrice: "£49.99 per month",
            subtitle: "Club-level coaching OS access with academy management placeholders, advanced tactical analysis, premium branding and player tracking.",
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
                        subtitle: "Choose a TactiCore AI auto-renewable subscription to train like a professional club.",
                        assetKind: .recoveryCircle
                    )

                    PremiumContainer(accent: .white.opacity(0.30)) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Free plan")
                                .font(.headline.weight(.black))
                                .foregroundStyle(.white)
                            Text("Limited AI sessions, basic drill cards, starter library access and coaching disclaimers remain available without a subscription.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.70))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    ForEach(tiers) { tier in
                        tierCard(tier)
                    }

#if os(visionOS)
                    visionOSStorePanel
#else
                    purchasePanel
#endif

                    subscriptionDisclosure
                    legalLinks

                    Text(CoachingDisclaimer.full)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.56))
                }
                .padding(20)
            }
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await store.loadProducts()
        }
    }

    private func tierCard(_ tier: PaywallTier) -> some View {
        PremiumContainer(accent: tier.accent) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(tier.name)
                            .font(.title2.weight(.black))
                            .foregroundStyle(.white)
                        Text("\(tier.displayPrice) / \(tier.billingPeriod)")
                            .font(.headline.weight(.black))
                            .foregroundStyle(tier.accent)
                        Text(tier.unitPrice)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.70))
                        Text(tier.subtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.64))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    if currentProductID == tier.productID {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title2)
                            .foregroundStyle(tier.accent)
                    }
                }

                Label("Subscription renews automatically until cancelled.", systemImage: "arrow.clockwise.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.74))
            }
        }
    }

    private var currentProductID: String? {
        switch store.currentPlan {
        case .free:
            return nil
        case .proCoach:
            return "tacticore.pro.monthly"
        case .eliteClub:
            return "tacticore.elite.monthly"
        }
    }

    private var purchasePanel: some View {
        PremiumContainer(accent: .tactiCoreNeon) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Subscribe with Apple")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)

                if store.isLoading && store.products.isEmpty {
                    HStack(spacing: 12) {
                        ProgressView()
                            .tint(Color.tactiCoreNeon)
                        Text("Loading App Store subscriptions")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.76))
                    }
                } else {
                    ForEach(tiers) { tier in
                        if let product = store.product(for: tier.productID) {
                            purchaseButton(product: product, tier: tier)
                        } else {
                            unavailableRow(tier)
                        }
                    }
                }

                IconActionButton(title: "Restore Purchases", systemImage: "arrow.uturn.backward.circle.fill", accent: .tactiCoreGold) {
                    Task { await store.restorePurchases() }
                }

                if let error = store.errorMessage {
                    ErrorStateView(message: error)
                }
            }
        }
    }

    private func purchaseButton(product: Product, tier: PaywallTier) -> some View {
        Button {
            Task { await store.purchase(product) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "creditcard.fill")
                    .foregroundStyle(tier.accent)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Subscribe to \(product.displayName)")
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(.white)
                    Text("\(product.displayPrice) / \(tier.billingPeriod)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.68))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white.opacity(0.56))
            }
            .padding(14)
            .background(tier.accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(tier.accent.opacity(0.28), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(store.isLoading)
    }

    private func unavailableRow(_ tier: PaywallTier) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .foregroundStyle(tier.accent)
            VStack(alignment: .leading, spacing: 3) {
                Text(tier.name)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)
                Text("Awaiting App Store product availability")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.58))
            }
            Spacer()
        }
        .padding(14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

#if os(visionOS)
    private var visionOSStorePanel: some View {
        PremiumContainer(accent: .tactiCoreNeon) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Subscribe with Apple")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                StoreView(ids: SubscriptionStore.productIDs)
                    .frame(minHeight: 220)
                IconActionButton(title: "Restore Purchases", systemImage: "arrow.uturn.backward.circle.fill", accent: .tactiCoreGold) {
                    Task { await store.restorePurchases() }
                }
            }
        }
    }
#endif

    private var subscriptionDisclosure: some View {
        PremiumContainer(accent: .tactiCoreGold) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Subscription terms")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                disclosureLine("Payment is charged to your Apple ID at confirmation of purchase.")
                disclosureLine("Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.")
                disclosureLine("Your Apple ID is charged for renewal within 24 hours before the end of the current period.")
                disclosureLine("You can manage or cancel subscriptions in App Store account settings after purchase.")
                disclosureLine("Prices shown are UK placeholders; App Store pricing may vary by country or region.")
            }
        }
    }

    private func disclosureLine(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.72))
            .fixedSize(horizontal: false, vertical: true)
    }

    private var legalLinks: some View {
        PremiumContainer(accent: .tactiCoreBlue) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Legal")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                Text("Review the privacy policy and terms before subscribing.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.64))
                HStack(spacing: 10) {
                    policyLink(title: "Privacy Policy", systemImage: "lock.shield.fill", url: TactiCoreLegal.privacyPolicyURL)
                    policyLink(title: "Terms of Use", systemImage: "doc.text.fill", url: TactiCoreLegal.termsOfUseURL)
                }
            }
        }
    }

    private func policyLink(title: String, systemImage: String, url: URL) -> some View {
        Link(destination: url) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(Color.tactiCoreBlue.opacity(0.18), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(Color.tactiCoreBlue.opacity(0.30), lineWidth: 1))
        }
    }
}

private struct PaywallTier: Identifiable {
    var id: String { productID }
    var name: String
    var productID: String
    var displayPrice: String
    var billingPeriod: String
    var unitPrice: String
    var subtitle: String
    var accent: Color
}

private enum TactiCoreLegal {
    static let privacyPolicyURL = URL(string: "https://github.com/lanray07/TactiCore-AI/blob/main/AppStoreConnect/PRIVACY_POLICY.md")!
    static let termsOfUseURL = URL(string: "https://github.com/lanray07/TactiCore-AI/blob/main/AppStoreConnect/TERMS_OF_USE.md")!
}
