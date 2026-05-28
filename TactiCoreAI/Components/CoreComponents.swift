import SwiftUI
import Charts

struct HumanAssetView: View {
    var kind: HumanAssetKind
    var height: CGFloat = 180

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.black, .tactiCoreGreen.opacity(0.62), kind.accent.opacity(0.32)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(StadiumLightRays(accent: kind.accent).opacity(0.85))
                .overlay(PitchHorizon(accent: kind.accent).opacity(0.70))
                .overlay(HumanSilhouetteGroup(kind: kind).padding(.horizontal, 18).padding(.bottom, 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(kind.accent.opacity(0.28), lineWidth: 1)
                )
                .overlay(
                    LinearGradient(colors: [.clear, .black.opacity(0.82)], startPoint: .center, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(kind.title)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                Text(kind.subtitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.66))
                    .lineLimit(2)
            }
            .padding(14)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct StadiumLightRays: View {
    var accent: Color

    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                for index in 0..<5 {
                    var path = Path()
                    let startX = size.width * (0.08 + CGFloat(index) * 0.21)
                    path.move(to: CGPoint(x: startX, y: 0))
                    path.addLine(to: CGPoint(x: startX + size.width * 0.22, y: size.height))
                    path.addLine(to: CGPoint(x: startX - size.width * 0.04, y: size.height))
                    path.closeSubpath()
                    context.fill(path, with: .color(accent.opacity(0.08)))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

private struct PitchHorizon: View {
    var accent: Color

    var body: some View {
        Canvas { context, size in
            let horizonY = size.height * 0.68
            var pitch = Path()
            pitch.move(to: CGPoint(x: 0, y: horizonY))
            pitch.addLine(to: CGPoint(x: size.width, y: horizonY))
            pitch.addLine(to: CGPoint(x: size.width, y: size.height))
            pitch.addLine(to: CGPoint(x: 0, y: size.height))
            pitch.closeSubpath()
            context.fill(pitch, with: .linearGradient(Gradient(colors: [.tactiCoreGreen.opacity(0.25), .black.opacity(0.55)]), startPoint: CGPoint(x: 0, y: horizonY), endPoint: CGPoint(x: 0, y: size.height)))

            var lines = Path()
            for index in 0..<6 {
                let y = horizonY + CGFloat(index) * (size.height - horizonY) / 5
                lines.move(to: CGPoint(x: 0, y: y))
                lines.addLine(to: CGPoint(x: size.width, y: y))
            }
            lines.move(to: CGPoint(x: size.width * 0.5, y: horizonY))
            lines.addLine(to: CGPoint(x: size.width * 0.08, y: size.height))
            lines.move(to: CGPoint(x: size.width * 0.5, y: horizonY))
            lines.addLine(to: CGPoint(x: size.width * 0.92, y: size.height))
            context.stroke(lines, with: .color(accent.opacity(0.22)), lineWidth: 1)
        }
    }
}

private struct HumanSilhouetteGroup: View {
    var kind: HumanAssetKind

    var body: some View {
        HStack(alignment: .bottom, spacing: 14) {
            if kind == .eliteCoach || kind == .matchAnalysis {
                CoachSilhouette(accent: kind.accent)
                    .frame(width: 78, height: 118)
                PlayerSilhouette(accent: .white.opacity(0.60), isKicking: false)
                    .frame(width: 52, height: 92)
            } else {
                PlayerSilhouette(accent: kind.accent, isKicking: true)
                    .frame(width: 72, height: 120)
                PlayerSilhouette(accent: .white.opacity(0.62), isKicking: false)
                    .frame(width: 58, height: 100)
                PlayerSilhouette(accent: kind.accent.opacity(0.82), isKicking: false)
                    .frame(width: 48, height: 86)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct PlayerSilhouette: View {
    var accent: Color
    var isKicking: Bool

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ZStack {
                Circle()
                    .fill(accent)
                    .frame(width: width * 0.28, height: width * 0.28)
                    .position(x: width * 0.50, y: height * 0.13)
                Capsule()
                    .fill(accent.opacity(0.92))
                    .frame(width: width * 0.34, height: height * 0.34)
                    .rotationEffect(.degrees(isKicking ? -10 : 5))
                    .position(x: width * 0.50, y: height * 0.38)
                Capsule()
                    .fill(accent.opacity(0.86))
                    .frame(width: width * 0.14, height: height * 0.36)
                    .rotationEffect(.degrees(isKicking ? -32 : 12))
                    .position(x: width * 0.39, y: height * 0.72)
                Capsule()
                    .fill(accent.opacity(0.78))
                    .frame(width: width * 0.14, height: height * 0.38)
                    .rotationEffect(.degrees(isKicking ? 46 : -8))
                    .position(x: width * 0.61, y: height * 0.72)
                if isKicking {
                    Circle()
                        .stroke(.white.opacity(0.78), lineWidth: 2)
                        .frame(width: width * 0.22, height: width * 0.22)
                        .position(x: width * 0.86, y: height * 0.86)
                }
            }
        }
        .shadow(color: accent.opacity(0.42), radius: 18, x: 0, y: 0)
    }
}

private struct CoachSilhouette: View {
    var accent: Color

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ZStack {
                Circle()
                    .fill(.white.opacity(0.82))
                    .frame(width: width * 0.24)
                    .position(x: width * 0.48, y: height * 0.11)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(accent.opacity(0.86))
                    .frame(width: width * 0.42, height: height * 0.52)
                    .position(x: width * 0.48, y: height * 0.43)
                Capsule()
                    .fill(.white.opacity(0.72))
                    .frame(width: width * 0.12, height: height * 0.42)
                    .rotationEffect(.degrees(10))
                    .position(x: width * 0.34, y: height * 0.78)
                Capsule()
                    .fill(.white.opacity(0.72))
                    .frame(width: width * 0.12, height: height * 0.42)
                    .rotationEffect(.degrees(-8))
                    .position(x: width * 0.62, y: height * 0.78)
            }
        }
        .shadow(color: accent.opacity(0.38), radius: 20, x: 0, y: 0)
    }
}

struct PremiumCoachCard: View {
    var title: String
    var subtitle: String
    var metric: String
    var assetKind: HumanAssetKind

    var body: some View {
        PremiumContainer(accent: assetKind.accent) {
            HStack(spacing: 14) {
                HumanAssetView(kind: assetKind, height: 116)
                    .frame(width: 132)
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.68))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(metric.uppercased())
                        .font(.caption.weight(.black))
                        .foregroundStyle(assetKind.accent)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

struct SessionCard: View {
    var session: TrainingSession

    var body: some View {
        PremiumContainer(accent: session.isFavorite ? .tactiCoreGold : .tactiCoreNeon) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(session.title)
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("\(session.tacticalFocus) | \(session.formation)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tactiCoreNeon)
                    }
                    Spacer()
                    Text("\(session.duration)m")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.tactiCoreNeon, in: Capsule())
                }
                Text(session.generatedContent)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.68))
                    .lineLimit(4)
                HStack {
                    Label(session.intensity, systemImage: "bolt.fill")
                    Spacer()
                    Label(session.isCompleted ? "Complete" : "Planned", systemImage: session.isCompleted ? "checkmark.seal.fill" : "calendar")
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.68))
            }
        }
    }
}

struct TacticalInsightCard: View {
    var insight: CoachingInsight
    var accent: Color = .tactiCoreNeon

    var body: some View {
        PremiumContainer(accent: accent) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(insight.tag.uppercased())
                        .font(.caption2.weight(.black))
                        .foregroundStyle(accent)
                    Spacer()
                    Image(systemName: "sparkles")
                        .foregroundStyle(accent)
                }
                Text(insight.title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                Text(insight.detail)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.70))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct AnalyticsChartCard: View {
    struct DataPoint: Identifiable {
        var id = UUID()
        var label: String
        var value: Double
        var color: Color
    }

    var title: String
    var subtitle: String
    var data: [DataPoint]

    var body: some View {
        PremiumContainer(accent: .tactiCoreBlue) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.62))
                }

                Chart(data) { point in
                    BarMark(
                        x: .value("Focus", point.label),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(point.color.gradient)
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }
                }
                .chartYAxis(.hidden)
                .frame(height: 170)
            }
        }
    }
}

struct UpgradeBanner: View {
    var title = "Unlock Pro Coach"
    var subtitle = "Voice, tactical board, premium exports, animated drills, and advanced analytics."

    var body: some View {
        PremiumContainer(accent: .tactiCoreGold) {
            HStack(spacing: 14) {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundStyle(.tactiCoreGold)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.68))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
    }
}
