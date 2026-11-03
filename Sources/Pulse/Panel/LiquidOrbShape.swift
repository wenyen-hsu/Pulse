// Copyright (c) 2026 qunqin24. Licensed under the Apache License, Version 2.0.
// Modified by wenyen-hsu: liquid pet surface.
import SwiftUI

/// Bounded outline shared by the glass surface and pointer geometry.
struct LiquidOrbShape: Shape {
    /// Points from the drop's centre toward its tail; length 0...1.
    var stretch: CGVector
    /// Points toward the nearest screen edge; length 0...1.
    var wetting: CGVector
    var phase: Double
    var floor: CGFloat
    var limit: CGFloat

    var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
        get { AnimatablePair(AnimatablePair(stretch.dx, stretch.dy), AnimatablePair(wetting.dx, wetting.dy)) }
        set {
            stretch = CGVector(dx: newValue.first.first, dy: newValue.first.second)
            wetting = CGVector(dx: newValue.second.first, dy: newValue.second.second)
        }
    }

    static let samples = 72

    /// Radius at `angle` as a multiple of the reserved circle's radius.
    func factor(at angle: Double) -> CGFloat {
        let spread = 1 / sqrt(pow(cos(angle) / 1.05, 2) + pow(sin(angle) / 0.96, 2))
        var value = spread * (1 + 0.035 * sin(3 * angle + phase) + 0.022 * sin(2 * angle - phase * 0.7 + 1.3))
        let pull = min(hypot(stretch.dx, stretch.dy), 1)
        if pull > 0 {
            let along = cos(angle - atan2(stretch.dy, stretch.dx))
            value += pull * (0.5 * pow(max(along, 0), 2) - 0.14 * pow(max(-along, 0), 2) - 0.1 * (1 - along * along))
        }
        let wet = min(hypot(wetting.dx, wetting.dy), 1)
        if wet > 0 {
            value += wet * (0.14 * pow(max(cos(angle - atan2(wetting.dy, wetting.dx)), 0), 3) - 0.03)
        }
        return min(max(value, floor), limit)
    }

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2 / limit
        let points = (0..<Self.samples).map { index -> CGPoint in
            let angle = Double(index) / Double(Self.samples) * 2 * .pi
            let length = radius * factor(at: angle)
            return CGPoint(x: rect.midX + cos(angle) * length, y: rect.midY + sin(angle) * length)
        }
        func middle(_ a: CGPoint, _ b: CGPoint) -> CGPoint { CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2) }
        var path = Path()
        path.move(to: middle(points[points.count - 1], points[0]))
        for index in points.indices {
            path.addQuadCurve(to: middle(points[index], points[(index + 1) % points.count]), control: points[index])
        }
        path.closeSubpath()
        return path
    }
}

enum LiquidMotion {
    static func rebound(initial: CGVector, elapsed: Double) -> CGVector {
        let time = max(elapsed, 0)
        let amplitude = exp(-8 * time) * (cos(13 * time) + 8.0 / 13 * sin(13 * time))
        return CGVector(dx: initial.dx * amplitude, dy: initial.dy * amplitude)
    }

    /// The pointer speed, in points per second, that stretches the drop fully.
    static let fullStretchSpeed: CGFloat = 1400

    /// The drop's tail for a drag moving at `velocity` (top-left coordinates):
    /// opposite the motion, longer the faster it goes, eased from `previous` so
    /// one jittery event does not snap the outline.
    static func stretch(previous: CGVector, velocity: CGVector) -> CGVector {
        let speed = hypot(velocity.dx, velocity.dy)
        guard speed.isFinite, speed > 0 else { return CGVector(dx: previous.dx * 0.6, dy: previous.dy * 0.6) }
        let length = min(speed / fullStretchSpeed, 1)
        let target = CGVector(dx: -velocity.dx / speed * length, dy: -velocity.dy / speed * length)
        return CGVector(dx: previous.dx * 0.6 + target.dx * 0.4, dy: previous.dy * 0.6 + target.dy * 0.4)
    }

    /// Which way the drop leans, and how strongly, given its centre and the
    /// visible screen in AppKit (bottom-left) coordinates. `closest` is the
    /// nearest the centre is allowed to an edge; strength fades out over `band`.
    /// The result is in top-left coordinates, like the panel's drawing.
    static func wetting(centre: CGPoint, room: CGRect, closest: CGFloat, band: CGFloat) -> CGVector {
        guard room.width > 0, room.height > 0, band > 0 else { return .zero }
        let edges: [(CGFloat, CGVector)] = [
            (centre.x - room.minX, CGVector(dx: -1, dy: 0)),
            (room.maxX - centre.x, CGVector(dx: 1, dy: 0)),
            (room.maxY - centre.y, CGVector(dx: 0, dy: -1)),
            (centre.y - room.minY, CGVector(dx: 0, dy: 1)),
        ]
        guard let nearest = edges.min(by: { $0.0 < $1.0 }) else { return .zero }
        let strength = min(max(1 - (nearest.0 - closest) / band, 0), 1)
        return CGVector(dx: nearest.1.dx * strength, dy: nearest.1.dy * strength)
    }
}
