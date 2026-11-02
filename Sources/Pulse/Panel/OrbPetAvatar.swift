// Copyright (c) 2026 qunqin24. Licensed under the Apache License, Version 2.0.
import SwiftUI

struct OrbPetAvatar: View {
    let pet: OrbPet
    let imageData: Data?

    var body: some View {
        Group {
            if let imageData, let image = NSImage(data: imageData) {
                Image(nsImage: image).resizable().interpolation(.high).scaledToFit()
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
}
