// Copyright (c) 2026 qunqin24. Licensed under the Apache License, Version 2.0.
// Modified by wenyen-hsu: liquid pet mode and independent-fork attribution.
import SwiftUI

extension PanelMetrics {
    static var orbUnitDiameter: CGFloat { 272 }
    static var orbUnitDotDiameter: CGFloat { 38 }
    static var orbUnitOrbitRadius: CGFloat { 96 }
    static var orbUnitPetDiameter: CGFloat { 66 }
    static var orbUnitCollapsedPetDiameter: CGFloat { 28 }
    static var orbUnitMargin: CGFloat { 12 }
    static var orbUnitRingHitRadius: CGFloat { 24 }
    static var orbUnitGap: CGFloat { 8 }
    static var orbUnitPetHalo: CGFloat { 6 }
    static var orbUnitWindowHeight: CGFloat { 560 }
    static var orbLabelWidth: CGFloat { 68 * scale }
    static var orbLabelSize: CGFloat { 9 * scale }
    static var orbCaptionSize: CGFloat { 10 * scale }
    static var orbUnitPageOffset: CGFloat { 56 }
    static var orbUnitPageWidth: CGFloat { 110 }
    static var orbUnitPageHeight: CGFloat { 28 }
    static var orbTitleGap: CGFloat { 5 * scale }
    static var orbFigureGap: CGFloat { 3 * scale }
    static var orbEmptyWidth: CGFloat { 180 * scale }
    static var orbEmptyOffset: CGFloat { 62 * scale }
    static var orbPageCapacity: Int { 8 }
    static var orbUnitWettingBand: CGFloat { 80 }
    static var orbUnitLiquidMargin: CGFloat { 40 }
    static var orbUnitLiquidGap: CGFloat { 32 }
}

/// Shared top-left coordinates for drawing, pointer samples and window input.
struct PetOrbLayout {
    let size: CGSize
    let scale: CGFloat
    let cardOnLeft: Bool
    var verticalCentre: CGFloat? = nil
    var isLiquid = false
    var stretch = CGVector.zero
    var wetting = CGVector.zero

    static func preferredWidth(scale: CGFloat, isLiquid: Bool, cardWidth: CGFloat) -> CGFloat {
        let margin = isLiquid ? PanelMetrics.orbUnitLiquidMargin : PanelMetrics.orbUnitMargin
        let gap = isLiquid ? PanelMetrics.orbUnitLiquidGap : PanelMetrics.orbUnitGap
        return (PanelMetrics.orbUnitDiameter + gap + margin * 2) * scale + cardWidth
    }

    var diameter: CGFloat { PanelMetrics.orbUnitDiameter * scale }
    var dotDiameter: CGFloat { PanelMetrics.orbUnitDotDiameter * scale }
    var margin: CGFloat { (isLiquid ? PanelMetrics.orbUnitLiquidMargin : PanelMetrics.orbUnitMargin) * scale }
    var gap: CGFloat { (isLiquid ? PanelMetrics.orbUnitLiquidGap : PanelMetrics.orbUnitGap) * scale }
    var pagerFrame: CGRect {
        CGRect(x: centre.x - PanelMetrics.orbUnitPageWidth * scale / 2,
               y: centre.y + (PanelMetrics.orbUnitPageOffset - PanelMetrics.orbUnitPageHeight / 2) * scale,
               width: PanelMetrics.orbUnitPageWidth * scale, height: PanelMetrics.orbUnitPageHeight * scale)
    }
    var centre: CGPoint {
        CGPoint(x: cardOnLeft ? size.width - margin - diameter / 2 : margin + diameter / 2,
                y: verticalCentre ?? size.height / 2)
    }
    var circle: CGRect {
        CGRect(x: centre.x - diameter / 2, y: centre.y - diameter / 2,
               width: diameter, height: diameter)
    }

    func liquidLimit(expanded: Bool) -> CGFloat {
        let radius = (expanded ? diameter : dotDiameter) / 2
        return min((radius + gap * 0.9) / radius, 1.55)
    }

    func liquidFloor(expanded: Bool, petSize: Double) -> CGFloat {
        let radius = (expanded ? diameter : dotDiameter) / 2
        let covered = expanded
            ? (PanelMetrics.orbUnitOrbitRadius + PanelMetrics.orbUnitRingHitRadius) * scale
            : petFrame(expanded: false, petSize: petSize).width / 2
        return min(covered / radius + 0.02, 1)
    }

    func liquidShape(expanded: Bool, petSize: Double) -> LiquidOrbShape {
        LiquidOrbShape(stretch: stretch, wetting: wetting, phase: 0,
                       floor: liquidFloor(expanded: expanded, petSize: petSize),
                       limit: liquidLimit(expanded: expanded))
    }

    func liquidFrame(expanded: Bool) -> CGRect {
        let side = (expanded ? diameter : dotDiameter) * liquidLimit(expanded: expanded)
        return CGRect(x: centre.x - side / 2, y: centre.y - side / 2, width: side, height: side)
    }

    static func pageCount(for count: Int) -> Int {
        max(1, (max(count, 0) + PanelMetrics.orbPageCapacity - 1) / PanelMetrics.orbPageCapacity)
    }

    static func indices(count: Int, page: Int) -> Range<Int> {
        let page = min(max(page, 0), pageCount(for: count) - 1)
        let start = min(page * PanelMetrics.orbPageCapacity, max(count, 0))
        return start..<min(start + PanelMetrics.orbPageCapacity, max(count, 0))
    }

    func ringCentre(index: Int, count: Int) -> CGPoint {
        let angle = -Double.pi / 2 + Double(index) * 2 * .pi / Double(max(count, 1))
        return CGPoint(x: centre.x + cos(angle) * PanelMetrics.orbUnitOrbitRadius * scale,
                       y: centre.y + sin(angle) * PanelMetrics.orbUnitOrbitRadius * scale)
    }

    func ringIndex(at point: CGPoint, count: Int) -> Int? {
        (0..<max(count, 0)).first {
            contains(point, around: ringCentre(index: $0, count: count), radius: PanelMetrics.orbUnitRingHitRadius * scale)
        }
    }

    func petFrame(expanded: Bool, petSize: Double) -> CGRect {
        let unit = expanded ? PanelMetrics.orbUnitPetDiameter : PanelMetrics.orbUnitCollapsedPetDiameter
        let side = unit * scale * AppSettings.boundedPetSize(petSize)
        return CGRect(x: centre.x - side / 2, y: centre.y - side / 2, width: side, height: side)
    }

    func containsOrb(_ point: CGPoint, expanded: Bool, petSize: Double) -> Bool {
        let inside: Bool
        if isLiquid {
            let path = liquidShape(expanded: expanded, petSize: petSize).path(in: liquidFrame(expanded: expanded)).cgPath
            let halo = path.copy(strokingWithWidth: PanelMetrics.orbUnitPetHalo * scale * 2,
                                 lineCap: .round, lineJoin: .round, miterLimit: 1)
            inside = path.contains(point) || halo.contains(point)
        } else {
            inside = contains(point, around: centre, radius: (expanded ? diameter : dotDiameter) / 2 + gap)
        }
        return inside
            || petFrame(expanded: expanded, petSize: petSize)
                .insetBy(dx: -PanelMetrics.orbUnitPetHalo * scale, dy: -PanelMetrics.orbUnitPetHalo * scale).contains(point)
    }

    func cardFrame(height: CGFloat, width: CGFloat) -> CGRect {
        let height = min(max(height, 0), max(size.height - margin * 2, 0))
        return CGRect(x: cardOnLeft ? margin : circle.maxX + gap,
                      y: min(max(centre.y - height / 2, margin), size.height - margin - height),
                      width: width, height: height)
    }

    func containsBridge(_ point: CGPoint, card: CGRect) -> Bool {
        CGRect(x: min(centre.x, card.minX), y: card.minY - gap,
               width: max(centre.x, card.maxX) - min(centre.x, card.minX),
               height: card.height + gap * 2).contains(point)
    }

    private func contains(_ point: CGPoint, around centre: CGPoint, radius: CGFloat) -> Bool {
        pow(point.x - centre.x, 2) + pow(point.y - centre.y, 2) <= radius * radius
    }
}
