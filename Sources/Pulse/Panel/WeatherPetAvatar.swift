// Copyright (c) 2026 wenyen-hsu. Licensed under the Apache License, Version 2.0.
import SwiftUI

struct WeatherPetPose {
    let time: TimeInterval
    let isAnimated: Bool
    var bob: Double { isAnimated ? sin(time * 1.5) * 1.5 : 0 }
    var fall: Double { isAnimated ? time.truncatingRemainder(dividingBy: 1.8) / 1.8 : 0.4 }
    var glow: Double { isAnimated ? 0.65 + 0.2 * sin(time * 2) : 0.8 }
}

struct WeatherPetAvatar: View {
    let pet: OrbPet
    var isAnimating = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24, paused: !isAnimating || reduceMotion)) { timeline in
            let pose = WeatherPetPose(time: timeline.date.timeIntervalSinceReferenceDate,
                                      isAnimated: isAnimating && !reduceMotion)
            Canvas { context, size in
                let unit = min(size.width, size.height)
                context.translateBy(x: (size.width - unit) / 2, y: (size.height - unit) / 2)
                context.scaleBy(x: unit / 100, y: unit / 100)
                context.translateBy(x: 0, y: pose.bob)
                if pet == .moon || pet == .cloudMoon {
                    let standalone = pet == .moon
                    let box = standalone ? CGRect(x: 23, y: 15, width: 58, height: 65)
                        : CGRect(x: 49, y: 6, width: 36, height: 41)
                    var crescent = Path()
                    crescent.addEllipse(in: box)
                    crescent.addEllipse(in: box.offsetBy(dx: box.width * 0.45, dy: -box.height * 0.15))
                    context.clip(to: Path(CGRect(x: 0, y: 0, width: 100, height: 100)))
                    var moonContext = context
                    moonContext.clip(to: Path(ellipseIn: box))
                    moonContext.fill(crescent, with: .linearGradient(
                        Gradient(colors: [.init(red: 1, green: 0.96, blue: 0.74), .init(red: 0.72, green: 0.83, blue: 1)]),
                        startPoint: box.origin, endPoint: CGPoint(x: box.maxX, y: box.maxY)),
                        style: FillStyle(eoFill: true))
                    for point in [CGPoint(x: 18, y: 22), CGPoint(x: 81, y: 72), CGPoint(x: 13, y: 65)] {
                        var star = Path()
                        star.move(to: CGPoint(x: point.x - 3, y: point.y))
                        star.addLine(to: CGPoint(x: point.x + 3, y: point.y))
                        star.move(to: CGPoint(x: point.x, y: point.y - 3))
                        star.addLine(to: CGPoint(x: point.x, y: point.y + 3))
                        context.stroke(star, with: .color(.init(white: 0.97).opacity(pose.glow)), lineWidth: 2)
                    }
                    if standalone { face(&context, x: 40, y: 58) }
                }
                if pet == .cloudSun {
                    let gold = Color(red: 1, green: 0.75, blue: 0.22)
                    context.fill(Path(ellipseIn: CGRect(x: 52, y: 9, width: 33, height: 33)), with: .color(gold))
                    for index in 0..<8 {
                        let angle = Double(index) * .pi / 4
                        var ray = Path()
                        ray.move(to: CGPoint(x: 68.5 + cos(angle) * 20, y: 25.5 + sin(angle) * 20))
                        ray.addLine(to: CGPoint(x: 68.5 + cos(angle) * 24, y: 25.5 + sin(angle) * 24))
                        context.stroke(ray, with: .color(gold), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    }
                }
                if pet != .moon {
                    var cloud = Path()
                    cloud.move(to: CGPoint(x: 25, y: 70))
                    cloud.addCurve(to: CGPoint(x: 21, y: 41), control1: CGPoint(x: 2, y: 70), control2: CGPoint(x: 5, y: 44))
                    cloud.addCurve(to: CGPoint(x: 58, y: 32), control1: CGPoint(x: 21, y: 13), control2: CGPoint(x: 50, y: 12))
                    cloud.addCurve(to: CGPoint(x: 81, y: 46), control1: CGPoint(x: 73, y: 25), control2: CGPoint(x: 85, y: 33))
                    cloud.addCurve(to: CGPoint(x: 78, y: 70), control1: CGPoint(x: 103, y: 51), control2: CGPoint(x: 94, y: 72))
                    cloud.closeSubpath()
                    let dark = pet == .thunderstorm
                    context.fill(cloud, with: .linearGradient(Gradient(colors: [
                        dark ? .init(red: 0.72, green: 0.77, blue: 0.94) : .init(red: 0.96, green: 0.99, blue: 1),
                        dark ? .init(red: 0.38, green: 0.45, blue: 0.69) : .init(red: 0.52, green: 0.77, blue: 0.97)
                    ]), startPoint: CGPoint(x: 38, y: 25), endPoint: CGPoint(x: 65, y: 76)))
                    face(&context, x: 50, y: 52)
                }
                if pet == .rain || pet == .snow {
                    for index in 0..<3 {
                        let x = 29.0 + Double(index) * 21
                        let y = 78 + (pose.fall + Double(index) * 0.3).truncatingRemainder(dividingBy: 1) * 12
                        var mark = Path()
                        if pet == .rain {
                            mark.move(to: CGPoint(x: x + 2, y: y - 3))
                            mark.addLine(to: CGPoint(x: x - 1, y: y + 3))
                        } else {
                            for angle in [0.0, Double.pi / 3, Double.pi * 2 / 3] {
                                mark.move(to: CGPoint(x: x - cos(angle) * 4, y: y - sin(angle) * 4))
                                mark.addLine(to: CGPoint(x: x + cos(angle) * 4, y: y + sin(angle) * 4))
                            }
                        }
                        context.stroke(mark, with: .color(pet == .rain ? .cyan : .init(white: 0.96)),
                                       style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    }
                }
                if pet == .thunderstorm {
                    var bolt = Path()
                    bolt.move(to: CGPoint(x: 52, y: 73))
                    for point in [CGPoint(x: 42, y: 85), CGPoint(x: 51, y: 85), CGPoint(x: 47, y: 96),
                                  CGPoint(x: 63, y: 80), CGPoint(x: 54, y: 80)] { bolt.addLine(to: point) }
                    bolt.closeSubpath()
                    context.fill(bolt, with: .color(.yellow.opacity(pose.glow)))
                }
                if pet == .fog {
                    for index in 0..<3 {
                        let y = 76.0 + Double(index) * 7
                        var line = Path()
                        line.move(to: CGPoint(x: 22 + Double(index % 2) * 8, y: y))
                        line.addLine(to: CGPoint(x: 79 - Double(index % 2) * 8, y: y))
                        context.stroke(line, with: .color(.init(white: 0.9)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    }
                }
            }
        }
    }

    private func face(_ context: inout GraphicsContext, x: Double, y: Double) {
        let ink = Color(red: 0.16, green: 0.24, blue: 0.4)
        for offset in [-10.0, 10.0] {
            context.fill(Path(ellipseIn: CGRect(x: x + offset - 2, y: y - 4, width: 4, height: 6)), with: .color(ink))
        }
        var smile = Path()
        smile.move(to: CGPoint(x: x - 5, y: y + 5))
        smile.addQuadCurve(to: CGPoint(x: x + 5, y: y + 5), control: CGPoint(x: x, y: y + 10))
        context.stroke(smile, with: .color(ink), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }
}
