import AppKit
import Testing
@testable import Pulse

@Suite("Liquid pet account packing")
struct LiquidPetNodesTests {
    @Test("Liquid includes every slot without a pager", arguments: [0, 1, 8, 9, 17, 40, 77, 200])
    func allAccounts(_ count: Int) {
        let nodes = LiquidPetNodes(count: count)
        let layout = PetOrbLayout(size: CGSize(width: 760, height: 640), scale: 1, cardOnLeft: false,
                                  isLiquid: true, liquidNodes: nodes)
        #expect(nodes.offsets.count == count)
        #expect(layout.visibleIndices(count: count, page: 999) == 0..<count)
        #expect(!layout.showsPager(count: count))
        #expect(nodes.scale > 0 && nodes.scale <= 1)
        let repeated = LiquidPetNodes(count: count)
        #expect(repeated.offsets == nodes.offsets)
        #expect(repeated.scale == nodes.scale)
    }

    @Test("Targets never overlap each other or the largest pet", arguments: [1, 8, 9, 17, 40, 77, 200])
    func targets(_ count: Int) {
        let nodes = LiquidPetNodes(count: count)
        let radius = PanelMetrics.liquidUnitRingHitRadius * nodes.scale
        let petHalf = PanelMetrics.orbUnitPetDiameter * 1.3 / 2
        for (index, point) in nodes.offsets.enumerated() {
            #expect(hypot(point.x, point.y) + radius
                <= PanelMetrics.orbUnitOrbitRadius + PanelMetrics.orbUnitRingHitRadius + 0.001)
            let petDistance = hypot(max(abs(point.x) - petHalf, 0), max(abs(point.y) - petHalf, 0))
            #expect(petDistance >= radius + PanelMetrics.orbUnitGap - 0.001)
            for other in nodes.offsets.dropFirst(index + 1) {
                #expect(hypot(point.x - other.x, point.y - other.y) > radius * 2)
            }
        }
    }

    @Test("Drawing and pointer input agree at every density and fitted scale", arguments: [1, 9, 17, 77, 200])
    func pointerGeometry(_ count: Int) {
        let nodes = LiquidPetNodes(count: count)
        for scale in [0.55, 0.8, 1, 1.2] {
            for left in [true, false] {
                let layout = PetOrbLayout(size: CGSize(width: 760, height: 640), scale: scale, cardOnLeft: left,
                                          isLiquid: true, liquidNodes: nodes)
                for index in 0..<count {
                    let point = layout.ringCentre(index: index, count: count)
                    #expect(layout.ringIndex(at: point, count: count) == index)
                    #expect(layout.containsOrb(point, expanded: true, petSize: 1.3))
                    #expect(!layout.containsOrb(point, expanded: false, petSize: 1.3))
                }
                #expect(layout.ringIndex(at: layout.centre, count: count) == nil)
            }
        }
    }

    @Test("Circular paging and dimensions remain unchanged")
    func classic() {
        let circle = PetOrbLayout(size: CGSize(width: 760, height: 640), scale: 1, cardOnLeft: true)
        #expect(circle.visibleIndices(count: 17, page: 1) == 8..<16)
        #expect(circle.showsPager(count: 17))
        #expect(!circle.showsPager(count: 8))
        #expect(circle.nodeScale(count: 200) == 1)
        var liquid = circle
        liquid.isLiquid = true
        let empty = liquid
        liquid.liquidNodes = LiquidPetNodes(count: 77)
        #expect(liquid.size == empty.size)
        #expect(liquid.circle == empty.circle)
        #expect(liquid.cardFrame(height: 300, width: 240) == empty.cardFrame(height: 300, width: 240))
        #expect(liquid.visibleIndices(count: -1, page: -1).isEmpty)
        #expect(liquid.ringIndex(at: liquid.centre, count: 0) == nil)
    }

    @Test("The entire target stays inside the deformed glass", arguments: [9, 40, 77])
    func deformedSurface(_ count: Int) {
        let nodes = LiquidPetNodes(count: count)
        for pull in [CGVector.zero, CGVector(dx: 1, dy: 0), CGVector(dx: -1, dy: 0.6)] {
            let layout = PetOrbLayout(size: CGSize(width: 760, height: 640), scale: 1, cardOnLeft: false,
                                      isLiquid: true, stretch: pull, wetting: CGVector(dx: 0, dy: -1), liquidNodes: nodes)
            let path = layout.liquidShape(expanded: true, petSize: 1.3).path(in: layout.liquidFrame(expanded: true)).cgPath
            let radius = PanelMetrics.liquidUnitRingHitRadius * nodes.scale
            for index in 0..<count {
                let centre = layout.ringCentre(index: index, count: count)
                for direction in 0..<8 {
                    let angle = Double(direction) * .pi / 4
                    #expect(path.contains(CGPoint(x: centre.x + cos(angle) * radius,
                                                  y: centre.y + sin(angle) * radius)))
                }
            }
        }
    }

    @Test("List changes replace the cached packing without changing the viewport")
    @MainActor
    func cachedPacking() {
        let state = PetOrbState()
        state.isLiquid = true
        state.size = CGSize(width: 760, height: 640)
        state.viewportScale = 0.8
        state.page = 2
        let size = state.size
        for count in [17, 77, 3, 0] {
            state.updateAccounts(count: count)
            #expect(state.accountCount == count)
            #expect(state.liquidNodes.offsets.count == count)
            #expect(state.layout.visibleIndices(count: count, page: state.page) == 0..<count)
            #expect(state.size == size)
            #expect(state.viewportScale == 0.8)
        }
    }

    @Test("Drag-release reselection shows details without a new hover refresh")
    @MainActor
    func dragSelection() {
        let state = PetOrbState()
        var looks = 0
        state.selectAccount("first") { looks += 1 }
        state.selectAccount("first") { looks += 1 }
        #expect(looks == 1)
        state.beginDrag()
        #expect(state.selectedID == nil)
        state.selectAccount("first") { looks += 1 }
        state.selectAccount("second") { looks += 1 }
        #expect(state.selectedID == "second")
        #expect(looks == 1)
        state.pointerDeparted()
        state.selectAccount("third") { looks += 1 }
        #expect(looks == 2)
    }

    @Test("Blank-origin dragging also defers hover refresh, while a new presentation clears it")
    @MainActor
    func blankDragSelection() {
        let state = PetOrbState()
        var looks = 0
        state.beginDrag()
        state.selectAccount("after blank drag") { looks += 1 }
        #expect(looks == 0)
        state.collapse()
        state.expand()
        state.selectAccount("next visit") { looks += 1 }
        #expect(looks == 1)
    }
}
