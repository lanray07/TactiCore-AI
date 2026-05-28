import SwiftUI

struct VoiceWaveformView: View {
    var levels: [CGFloat]
    var accent: Color = .tactiCoreNeon

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(Array(levels.enumerated()), id: \.offset) { _, level in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(
                        LinearGradient(colors: [accent, .white.opacity(0.82)], startPoint: .bottom, endPoint: .top)
                    )
                    .frame(width: 5, height: max(8, 74 * level))
                    .shadow(color: accent.opacity(0.45), radius: 6, x: 0, y: 0)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 104)
        .padding(.vertical, 10)
        .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct TacticalBoardView: View {
    @Binding var players: [BoardPlayer]
    var movements: [TacticalMovement]
    var showZones = true

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                FootballPitchCanvas(movements: movements, showZones: showZones)
                ForEach($players) { $player in
                    PlayerMarker(player: player)
                        .position(x: player.position.x * proxy.size.width, y: player.position.y * proxy.size.height)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    player.position = CGPoint(
                                        x: min(max(value.location.x / proxy.size.width, 0.05), 0.95),
                                        y: min(max(value.location.y / proxy.size.height, 0.05), 0.95)
                                    )
                                }
                        )
                }
            }
        }
        .aspectRatio(0.68, contentMode: .fit)
        .background(.black.opacity(0.32), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.tactiCoreNeon.opacity(0.25), lineWidth: 1)
        )
    }
}

private struct PlayerMarker: View {
    var player: BoardPlayer

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(.black.opacity(0.76))
                    .frame(width: 42, height: 42)
                    .overlay(Circle().stroke(player.accent, lineWidth: 2))
                    .shadow(color: player.accent.opacity(0.52), radius: 10, x: 0, y: 0)
                Text("\(player.number)")
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)
            }
            Text(player.role)
                .font(.caption2.weight(.black))
                .foregroundStyle(.white.opacity(0.82))
                .padding(.horizontal, 4)
                .background(.black.opacity(0.35), in: Capsule())
        }
        .accessibilityLabel("\(player.role) \(player.number)")
    }
}

struct FootballPitchCanvas: View {
    var movements: [TacticalMovement] = []
    var showZones = true

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let pitch = Path(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: 8)
            context.fill(pitch, with: .linearGradient(Gradient(colors: [.tactiCoreGreen.opacity(0.74), .tactiCoreInk]), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: size.width, y: size.height)))

            for index in 0..<8 {
                let x = CGFloat(index) * size.width / 8
                let stripe = CGRect(x: x, y: 0, width: size.width / 16, height: size.height)
                context.fill(Path(stripe), with: .color(.white.opacity(index.isMultiple(of: 2) ? 0.035 : 0.015)))
            }

            var lines = Path()
            let inset: CGFloat = 16
            let field = rect.insetBy(dx: inset, dy: inset)
            lines.addRect(field)
            lines.move(to: CGPoint(x: field.minX, y: field.midY))
            lines.addLine(to: CGPoint(x: field.maxX, y: field.midY))
            lines.addEllipse(in: CGRect(x: field.midX - 38, y: field.midY - 38, width: 76, height: 76))
            lines.addRect(CGRect(x: field.midX - 70, y: field.minY, width: 140, height: 54))
            lines.addRect(CGRect(x: field.midX - 70, y: field.maxY - 54, width: 140, height: 54))
            context.stroke(lines, with: .color(.white.opacity(0.34)), lineWidth: 1.4)

            if showZones {
                for index in 1..<3 {
                    let y = field.minY + CGFloat(index) * field.height / 3
                    var zone = Path()
                    zone.move(to: CGPoint(x: field.minX, y: y))
                    zone.addLine(to: CGPoint(x: field.maxX, y: y))
                    context.stroke(zone, with: .color(.tactiCoreNeon.opacity(0.18)), lineWidth: 1)
                }
            }

            for movement in movements {
                drawMovement(movement, context: &context, size: size)
            }
        }
    }

    private func drawMovement(_ movement: TacticalMovement, context: inout GraphicsContext, size: CGSize) {
        let start = CGPoint(x: movement.start.x * size.width, y: movement.start.y * size.height)
        let end = CGPoint(x: movement.end.x * size.width, y: movement.end.y * size.height)
        var path = Path()
        path.move(to: start)
        let control = CGPoint(x: (start.x + end.x) / 2, y: min(start.y, end.y) - 36)
        path.addQuadCurve(to: end, control: control)
        context.stroke(path, with: .color(movement.accent.opacity(0.94)), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

        let angle = atan2(end.y - control.y, end.x - control.x)
        var arrow = Path()
        arrow.move(to: end)
        arrow.addLine(to: CGPoint(x: end.x - cos(angle - 0.55) * 13, y: end.y - sin(angle - 0.55) * 13))
        arrow.move(to: end)
        arrow.addLine(to: CGPoint(x: end.x - cos(angle + 0.55) * 13, y: end.y - sin(angle + 0.55) * 13))
        context.stroke(arrow, with: .color(movement.accent), style: StrokeStyle(lineWidth: 3, lineCap: .round))
    }
}

struct DrillAnimationCard: View {
    var title: String
    var subtitle: String
    var movements: [TacticalMovement] = TacticalEnginePreset.highPress.movements

    var body: some View {
        PremiumContainer(accent: .tactiCoreBlue) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                        Text(subtitle)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.62))
                    }
                    Spacer()
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.tactiCoreNeon)
                }

                TimelineView(.animation) { timeline in
                    let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2.4) / 2.4
                    ZStack {
                        FootballPitchCanvas(movements: movements, showZones: true)
                        AnimatedDrillDots(phase: phase)
                    }
                    .aspectRatio(1.55, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }
}

private struct AnimatedDrillDots: View {
    var phase: Double

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ForEach(0..<5, id: \.self) { index in
                let offset = CGFloat((phase + Double(index) * 0.12).truncatingRemainder(dividingBy: 1))
                Circle()
                    .fill(index == 0 ? .white : Color.tactiCoreNeon)
                    .frame(width: index == 0 ? 11 : 16, height: index == 0 ? 11 : 16)
                    .shadow(color: .tactiCoreNeon.opacity(0.55), radius: 8)
                    .position(
                        x: width * (0.20 + 0.58 * offset),
                        y: height * (0.26 + CGFloat(index % 3) * 0.18 + sin(offset * .pi * 2) * 0.03)
                    )
            }
        }
    }
}

struct ShareCardPreview: View {
    var title: String
    var subtitle: String
    var accent: Color = .tactiCoreNeon
    var assetKind: HumanAssetKind = .trainingGround

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HumanAssetView(kind: assetKind, height: 290)
            VStack(alignment: .leading, spacing: 10) {
                Text("TACTICORE AI")
                    .font(.caption.weight(.black))
                    .foregroundStyle(accent)
                Text(title)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.74))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
        }
        .aspectRatio(0.80, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
