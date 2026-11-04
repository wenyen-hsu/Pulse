// Copyright (c) 2026 qunqin24. Licensed under the Apache License, Version 2.0.
import SwiftUI

struct OrbPetAvatar: View {
    let pet: OrbPet
    let imageData: Data?
    var isAnimating = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if let imageData, let image = NSImage(data: imageData) {
                Image(nsImage: image).resizable().interpolation(.high).scaledToFit()
            } else if pet == .sun {
                sun
            } else if pet.isWeatherShape {
                WeatherPetAvatar(pet: pet, isAnimating: isAnimating)
            } else {
                Canvas { context, size in
                    let unit = min(size.width, size.height)
                    context.scaleBy(x: unit / 100, y: unit / 100)
                    let ink: Color = pet == .fox ? Color(red: 0.94, green: 0.48, blue: 0.21)
                        : pet == .rabbit ? Color(red: 0.9, green: 0.84, blue: 0.96)
                        : Color(red: 0.48, green: 0.68, blue: 0.89)
                    let earTop: CGFloat = pet == .rabbit ? 2 : 14
                    let earBottom: CGFloat = pet == .rabbit ? 59 : 56
                    for x: CGFloat in [22, 58] {
                        let ear = CGRect(x: x, y: earTop, width: 20, height: earBottom - earTop)
                        context.fill(Path(roundedRect: ear, cornerRadius: pet == .rabbit ? 10 : 3), with: .color(ink))
                        context.fill(Path(ellipseIn: ear.insetBy(dx: 6, dy: 7)), with: .color(.pink.opacity(0.55)))
                    }
                    context.fill(Path(ellipseIn: CGRect(x: 14, y: 34, width: 72, height: 57)), with: .color(ink))
                    context.fill(Path(ellipseIn: CGRect(x: 30, y: 60, width: 40, height: 27)), with: .color(.white.opacity(0.8)))
                    for x: CGFloat in [32, 60] {
                        context.fill(Path(ellipseIn: CGRect(x: x, y: 53, width: 8, height: 11)), with: .color(Color(white: 0.14)))
                        context.fill(Path(ellipseIn: CGRect(x: x + 2, y: 54, width: 3, height: 3)), with: .color(.white))
                    }
                    context.fill(Path(ellipseIn: CGRect(x: 46, y: 67, width: 8, height: 6)), with: .color(.pink))
                    var mouth = Path()
                    mouth.move(to: CGPoint(x: 42, y: 76))
                    mouth.addQuadCurve(to: CGPoint(x: 58, y: 76), control: CGPoint(x: 50, y: 84))
                    context.stroke(mouth, with: .color(Color(white: 0.25)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }
            }
        }
        .accessibilityLabel(pet.title)
    }

    private var sun: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24, paused: !isAnimating || reduceMotion)) { timeline in
            let pose = SunPetPose(time: timeline.date.timeIntervalSinceReferenceDate,
                                  isAnimated: isAnimating && !reduceMotion)
            Canvas { context, size in
                let unit = min(size.width, size.height)
                context.scaleBy(x: unit / 100, y: unit / 100)
                let gold = Color(red: 1, green: 0.67, blue: 0.13)
                context.fill(Path(ellipseIn: CGRect(x: 3, y: 3, width: 94, height: 94)),
                             with: .color(gold.opacity(pose.glowOpacity)))
                for index in 0..<12 {
                    let angle = Double(index) * .pi / 6 + pose.rayAngle
                    var ray = Path()
                    ray.move(to: CGPoint(x: 50 + cos(angle) * 35, y: 50 + sin(angle) * 35))
                    ray.addLine(to: CGPoint(x: 50 + cos(angle) * 43, y: 50 + sin(angle) * 43))
                    context.stroke(ray, with: .color(gold), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                }
                context.fill(Path(ellipseIn: CGRect(x: 22, y: 22, width: 56, height: 56)),
                             with: .linearGradient(Gradient(colors: [.init(red: 1, green: 0.91, blue: 0.35), gold]),
                                                   startPoint: CGPoint(x: 35, y: 25), endPoint: CGPoint(x: 65, y: 78)))
                let ink = Color(red: 0.38, green: 0.22, blue: 0.08)
                for x: CGFloat in [38, 58] {
                    context.fill(Path(ellipseIn: CGRect(x: x, y: 47 - pose.eyeHeight / 2,
                                                        width: 4, height: pose.eyeHeight)), with: .color(ink))
                }
                for x: CGFloat in [29, 62] {
                    context.fill(Path(ellipseIn: CGRect(x: x, y: 54, width: 9, height: 5)),
                                 with: .color(.pink.opacity(0.5)))
                }
                var smile = Path()
                smile.move(to: CGPoint(x: 43, y: 57))
                smile.addQuadCurve(to: CGPoint(x: 57, y: 57), control: CGPoint(x: 50, y: 65))
                context.stroke(smile, with: .color(ink), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            }
        }
    }
}

struct SunPetPose {
    let time: TimeInterval
    let isAnimated: Bool

    var glowOpacity: Double { isAnimated ? 0.14 + 0.05 * sin(time * 2 * .pi / 3.4) : 0.14 }
    var rayAngle: Double { isAnimated ? time.truncatingRemainder(dividingBy: 24) * 2 * .pi / 24 : 0 }
    var eyeHeight: CGFloat { isAnimated && time.truncatingRemainder(dividingBy: 4.8) > 4.6 ? 1 : 7 }
}
