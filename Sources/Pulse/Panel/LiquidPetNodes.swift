// Copyright (c) 2026 wenyen-hsu. Licensed under the Apache License, Version 2.0.
import SwiftUI

struct LiquidPetNodes {
    let offsets: [CGPoint]
    let scale: CGFloat

    init(count: Int) {
        guard count > 0 else { offsets = []; scale = 1; return }
        var scale: CGFloat = 1
        var points = Self.candidates(scale: scale)
        while points.count < count {
            scale *= 0.9
            points = Self.candidates(scale: scale)
        }
        offsets = Array(points.prefix(count))
        self.scale = scale
    }

    private static func candidates(scale: CGFloat) -> [CGPoint] {
        let hit = PanelMetrics.liquidUnitRingHitRadius * scale
        let spacing = (PanelMetrics.liquidUnitRingHitRadius * 2 + PanelMetrics.orbUnitGap) * scale
        let outer = PanelMetrics.orbUnitOrbitRadius + PanelMetrics.orbUnitRingHitRadius - hit
        let petHalf = PanelMetrics.orbUnitPetDiameter * AppSettings.boundedPetSize(1.3) / 2
        let extent = Int(ceil(outer * 2 / spacing))
        var shells: [Int: [CGPoint]] = [:]
        for q in -extent...extent {
            for r in -extent...extent {
                let point = CGPoint(x: (CGFloat(q) + CGFloat(r) / 2) * spacing,
                                    y: CGFloat(r) * spacing * sqrt(3) / 2)
                let radius = hypot(point.x, point.y)
                let petDistance = hypot(max(abs(point.x) - petHalf, 0), max(abs(point.y) - petHalf, 0))
                if petDistance >= PanelMetrics.orbUnitGap + hit, radius <= outer {
                    shells[max(abs(q), abs(r), abs(q + r)), default: []].append(point)
                }
            }
        }
        var points: [CGPoint] = []
        for shell in shells.keys.sorted() {
            var remaining = shells[shell] ?? []
            var step = 0
            while !remaining.isEmpty {
                let angle = -.pi / 2 + Double(step) * .pi * (3 - sqrt(5))
                func distance(_ point: CGPoint) -> Double {
                    let difference = atan2(point.y, point.x) - angle
                    return abs(atan2(sin(difference), cos(difference)))
                }
                let index = remaining.indices.min { distance(remaining[$0]) < distance(remaining[$1]) }!
                points.append(remaining.remove(at: index))
                step += 1
            }
        }
        return points
    }
}
