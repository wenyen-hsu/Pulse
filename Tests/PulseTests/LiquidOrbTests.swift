import AppKit
import SwiftUI
import Testing
@testable import Pulse

@Suite("Liquid pet surface")
struct LiquidOrbTests {
    private let pulls = [CGVector.zero, CGVector(dx: 1, dy: 0), CGVector(dx: -0.4, dy: 0.9), CGVector(dx: 3, dy: -3)]

    @Test("The outline stays between the covered rings or pet and the accepted orb margin")
    func bounds() {
        for scale in [0.8, 1.0, 1.2] {
            var layout = PetOrbLayout(size: CGSize(width: 760, height: 640), scale: scale, cardOnLeft: true,
                                      isLiquid: true)
            for expanded in [false, true] {
                for size in [0.7, 1, 1.3] {
                    let limit = layout.liquidLimit(expanded: expanded)
                    let floor = layout.liquidFloor(expanded: expanded, petSize: size)
                    let radius = (expanded ? layout.diameter : layout.dotDiameter) / 2
                    for stretch in pulls {
                        for wetting in pulls {
                            layout.stretch = stretch
                            layout.wetting = wetting
                            let shape = layout.liquidShape(expanded: expanded, petSize: size)
                            for step in 0..<LiquidOrbShape.samples {
                                let angle = Double(step) / Double(LiquidOrbShape.samples) * 2 * .pi
                                let length = shape.factor(at: angle) * radius
                                let point = CGPoint(x: layout.centre.x + cos(angle) * length,
                                                    y: layout.centre.y + sin(angle) * length)
                                #expect(layout.containsOrb(point, expanded: expanded, petSize: size))
                                #expect(shape.factor(at: angle) >= floor)
                            }
                            let side = radius * 2 * limit
                            let drawn = shape.path(in: CGRect(x: 0, y: 0, width: side, height: side)).boundingRect
                            #expect(drawn.minX >= -0.5 && drawn.minY >= -0.5)
                            #expect(drawn.maxX <= side + 0.5 && drawn.maxY <= side + 0.5)
                        }
                    }
                }
            }
        }
    }

    @Test("The actual liquid path and its approach halo drive pointer containment")
    func containment() {
        for left in [true, false] {
            let layout = PetOrbLayout(size: CGSize(width: 760, height: 640), scale: 1, cardOnLeft: left,
                                      isLiquid: true, stretch: CGVector(dx: 1, dy: 0))
            for expanded in [true, false] {
                let frame = layout.liquidFrame(expanded: expanded)
                let path = layout.liquidShape(expanded: expanded, petSize: 1).path(in: frame)
                for x in stride(from: frame.minX - 10, through: frame.maxX + 10, by: 4) {
                    for y in stride(from: frame.minY - 10, through: frame.maxY + 10, by: 4) {
                        let point = CGPoint(x: x, y: y)
                        if path.contains(point) {
                            #expect(layout.containsOrb(point, expanded: expanded, petSize: 1))
                        }
                    }
                }
                #expect(!layout.containsOrb(CGPoint(x: frame.maxX + 20, y: frame.midY),
                                            expanded: expanded, petSize: 1))
                #expect(frame.minX >= 0 && frame.maxX <= layout.size.width)
            }
            for index in 0..<8 {
                #expect(layout.containsOrb(layout.ringCentre(index: index, count: 8), expanded: true, petSize: 1.3))
            }
            let card = layout.cardFrame(height: 400, width: 320)
            #expect(left ? card.maxX <= layout.liquidFrame(expanded: true).minX
                         : card.minX >= layout.liquidFrame(expanded: true).maxX)
        }
    }

    @Test("Release returns through a damped overshoot and settles")
    func recoil() {
        let initial = CGVector(dx: 1, dy: -0.5)
        #expect(LiquidMotion.rebound(initial: initial, elapsed: 0) == initial)
        #expect(LiquidMotion.rebound(initial: initial, elapsed: 0.3).dx < 0)
        let settled = LiquidMotion.rebound(initial: initial, elapsed: 1)
        #expect(hypot(settled.dx, settled.dy) < 0.001)
        for tick in 0...100 {
            let vector = LiquidMotion.rebound(initial: initial, elapsed: Double(tick) / 100)
            #expect(abs(vector.dx) <= 1 && abs(vector.dy) <= 0.5)
        }
    }

    @Test("Narrow viewports keep either card and all ring targets inside shared geometry")
    @MainActor func narrowViewport() {
        for liquid in [false, true] {
            for left in [false, true] {
                for width: CGFloat in [440, 560, 574, 600, 654, 1200] {
                    let state = PetOrbState()
                    let naturalWidth = PetOrbLayout.preferredWidth(
                        scale: PanelMetrics.scale, isLiquid: liquid,
                        cardWidth: DetailCardLayout.width + DetailCardLayout.pointerWidth
                    )
                    state.isLiquid = liquid
                    state.cardOnLeft = left
                    state.size = CGSize(width: min(width, naturalWidth), height: 560)
                    state.viewportScale = min(1, state.size.width / naturalWidth)
                    let layout = state.layout
                    let drawing = state.drawingLayout
                    let card = layout.cardFrame(
                        height: 300 * state.viewportScale,
                        width: (DetailCardLayout.width + DetailCardLayout.pointerWidth) * state.viewportScale
                    )
                    let drawnCard = drawing.cardFrame(
                        height: 300, width: DetailCardLayout.width + DetailCardLayout.pointerWidth
                    )
                    #expect(card.minX >= 0 && card.maxX <= state.size.width + 0.01)
                    #expect(abs(card.midX / state.viewportScale - drawnCard.midX) < 0.01)
                    #expect(abs(card.midY / state.viewportScale - drawnCard.midY) < 0.01)
                    let envelope = liquid ? layout.liquidFrame(expanded: true) : layout.circle
                    #expect(envelope.minX >= 0 && envelope.maxX <= state.size.width + 0.01)
                    #expect(!card.intersects(envelope))
                    for index in 0..<8 {
                        let ring = layout.ringCentre(index: index, count: 8)
                        let radius = PanelMetrics.orbUnitRingHitRadius * layout.scale
                        #expect(!card.intersects(CGRect(x: ring.x - radius, y: ring.y - radius,
                                                       width: radius * 2, height: radius * 2)))
                        #expect(layout.ringIndex(at: ring, count: 8) == index)
                        #expect(drawing.ringIndex(at: state.drawingPoint(ring), count: 8) == index)
                        #expect(layout.containsOrb(ring, expanded: true, petSize: 1))
                    }
                }
            }
        }
    }

    @Test("At rest the drop is spread and uneven, not a circle")
    func restingShape() {
        let shape = LiquidOrbShape(stretch: .zero, wetting: .zero, phase: 0, floor: 0.5, limit: 1.5)
        let factors = (0..<LiquidOrbShape.samples).map { shape.factor(at: Double($0) / 72 * 2 * .pi) }
        #expect(factors.max()! - factors.min()! > 0.05)
        #expect(shape.factor(at: 0) > shape.factor(at: .pi / 2))
    }

    @Test("A drag pulls a tail behind the motion and the tail eases rather than snaps")
    func dragStretch() {
        let first = LiquidMotion.stretch(previous: .zero, velocity: CGVector(dx: 2800, dy: 0))
        #expect(first.dx < 0 && abs(first.dy) < 0.0001)
        #expect(abs(first.dx) < 1)
        var pull = first
        for _ in 0..<40 { pull = LiquidMotion.stretch(previous: pull, velocity: CGVector(dx: 2800, dy: 0)) }
        #expect(abs(pull.dx + 1) < 0.001)
        let shape = LiquidOrbShape(stretch: pull, wetting: .zero, phase: 0, floor: 0.5, limit: 1.6)
        #expect(shape.factor(at: .pi) > shape.factor(at: 0) + 0.3)
        let still = LiquidMotion.stretch(previous: pull, velocity: .zero)
        #expect(abs(still.dx) < abs(pull.dx))
        #expect(LiquidMotion.stretch(previous: .zero, velocity: CGVector(dx: CGFloat.nan, dy: 0)) == .zero)
    }

    @Test("The drop leans toward the nearest screen edge, fading with distance")
    func wetting() {
        let room = CGRect(x: 0, y: 0, width: 1440, height: 900)
        let right = LiquidMotion.wetting(centre: CGPoint(x: 1292, y: 450), room: room, closest: 148, band: 80)
        #expect(right == CGVector(dx: 1, dy: 0))
        let top = LiquidMotion.wetting(centre: CGPoint(x: 720, y: 712), room: room, closest: 148, band: 80)
        #expect(abs(top.dx) < 0.0001 && top.dy < -0.4 && top.dy > -0.6)
        #expect(LiquidMotion.wetting(centre: CGPoint(x: 720, y: 450), room: room, closest: 148, band: 80) == .zero)
        #expect(LiquidMotion.wetting(centre: .zero, room: .zero, closest: 148, band: 80) == .zero)
        let shape = LiquidOrbShape(stretch: .zero, wetting: right, phase: 0, floor: 0.5, limit: 1.6)
        #expect(shape.factor(at: 0) > LiquidOrbShape(stretch: .zero, wetting: .zero, phase: 0, floor: 0.5, limit: 1.6)
            .factor(at: 0))
    }
}
