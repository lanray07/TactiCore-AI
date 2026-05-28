import SwiftUI

extension Color {
    static let tactiCoreBlack = Color(red: 0.015, green: 0.025, blue: 0.023)
    static let tactiCoreInk = Color(red: 0.035, green: 0.065, blue: 0.055)
    static let tactiCorePanel = Color(red: 0.055, green: 0.090, blue: 0.075)
    static let tactiCoreGreen = Color(red: 0.060, green: 0.250, blue: 0.150)
    static let tactiCoreNeon = Color(red: 0.560, green: 1.000, blue: 0.320)
    static let tactiCoreMint = Color(red: 0.420, green: 0.980, blue: 0.720)
    static let tactiCoreGold = Color(red: 1.000, green: 0.760, blue: 0.300)
    static let tactiCoreBlue = Color(red: 0.220, green: 0.630, blue: 1.000)
    static let tactiCorePurple = Color(red: 0.540, green: 0.450, blue: 1.000)
    static let tactiCoreRed = Color(red: 1.000, green: 0.320, blue: 0.280)
    static let tactiCoreTeal = Color(red: 0.180, green: 0.820, blue: 0.780)
    static let tactiCoreAmber = Color(red: 1.000, green: 0.560, blue: 0.120)
}

enum TactiCoreGradient {
    static let stadium = LinearGradient(
        colors: [.tactiCoreBlack, .tactiCoreInk, .tactiCoreGreen.opacity(0.72)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let neon = LinearGradient(
        colors: [.tactiCoreNeon, .tactiCoreMint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let broadcast = LinearGradient(
        colors: [.white.opacity(0.16), .tactiCoreNeon.opacity(0.08), .clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct CinematicBackground: View {
    var assetKind: HumanAssetKind = .stadiumTunnel
    var showPitchLines = true

    var body: some View {
        ZStack {
            TactiCoreGradient.stadium.ignoresSafeArea()

            Image(assetKind.imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .saturation(0.92)
                .contrast(1.10)
                .brightness(-0.10)
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.18), .black.opacity(0.74), .black.opacity(0.92)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.78), .clear, .black.opacity(0.72)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .accessibilityHidden(true)

            RadialGradient(
                colors: [assetKind.accent.opacity(0.30), .clear],
                center: .topTrailing,
                startRadius: 16,
                endRadius: 420
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [.tactiCoreBlue.opacity(0.16), .clear],
                center: .bottomLeading,
                startRadius: 30,
                endRadius: 380
            )
            .ignoresSafeArea()

            if showPitchLines {
                PitchTexture()
                    .opacity(0.23)
                    .ignoresSafeArea()
            }

            LinearGradient(
                colors: [.black.opacity(0.72), .clear, .black.opacity(0.52)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

private struct PitchTexture: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            let stripeWidth = max(size.width / 9, 44)
            for index in 0..<12 {
                let x = CGFloat(index) * stripeWidth
                path.addRect(CGRect(x: x, y: 0, width: stripeWidth * 0.45, height: size.height))
            }
            context.fill(path, with: .color(.white.opacity(0.10)))

            var linePath = Path()
            for index in 0..<9 {
                let y = CGFloat(index) * size.height / 8
                linePath.move(to: CGPoint(x: 0, y: y))
                linePath.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(linePath, with: .color(.white.opacity(0.12)), lineWidth: 0.8)
        }
    }
}

struct PremiumContainer<Content: View>: View {
    var cornerRadius: CGFloat = 8
    var accent: Color = .tactiCoreNeon
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(TactiCoreGradient.broadcast)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(accent.opacity(0.22), lineWidth: 1)
                    )
            )
    }
}

struct PremiumButton: View {
    var title: String
    var systemImage: String
    var isLoading = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.black)
                } else {
                    Image(systemName: systemImage)
                        .font(.headline.weight(.bold))
                }
                Text(title)
                    .font(.headline.weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(TactiCoreGradient.neon, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .tactiCoreNeon.opacity(0.35), radius: 22, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct IconActionButton: View {
    var title: String
    var systemImage: String
    var accent: Color = .tactiCoreNeon
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(accent.opacity(0.16), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(accent.opacity(0.28), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct ScreenHeader: View {
    var eyebrow: String
    var title: String
    var subtitle: String
    var assetKind: HumanAssetKind

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HumanAssetView(kind: assetKind, height: 156)
            VStack(alignment: .leading, spacing: 8) {
                Text(eyebrow.uppercased())
                    .font(.caption.weight(.black))
                    .foregroundStyle(assetKind.accent)
                Text(title)
                    .font(.system(.largeTitle, design: .rounded).weight(.black))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct Chip: View {
    var title: String
    var isSelected: Bool
    var accent: Color = .tactiCoreNeon

    var body: some View {
        Text(title)
            .font(.caption.weight(.bold))
            .foregroundStyle(isSelected ? .black : .white)
            .lineLimit(1)
            .minimumScaleFactor(0.74)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? accent : Color.white.opacity(0.08), in: Capsule())
            .overlay(Capsule().stroke(accent.opacity(isSelected ? 0 : 0.25), lineWidth: 1))
    }
}

struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    init(_ data: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: spacing)], spacing: spacing) {
            ForEach(data) { item in
                content(item)
            }
        }
    }
}

struct LoadingStateView: View {
    var title: String = "Building elite coaching detail"

    var body: some View {
        PremiumContainer(accent: .tactiCoreNeon) {
            HStack(spacing: 14) {
                ProgressView()
                    .tint(Color.tactiCoreNeon)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
                Spacer()
            }
        }
    }
}

struct EmptyStateView: View {
    var title: String
    var message: String
    var systemImage: String

    var body: some View {
        PremiumContainer(accent: .white.opacity(0.24)) {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color.tactiCoreNeon)
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.68))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ErrorStateView: View {
    var message: String

    var body: some View {
        PremiumContainer(accent: .tactiCoreRed) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.tactiCoreRed)
                Text(message)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
                Spacer()
            }
        }
    }
}
