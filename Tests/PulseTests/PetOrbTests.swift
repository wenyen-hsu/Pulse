import AppKit
import Testing
@testable import Pulse

@Suite("Pet orb geometry")
struct PetOrbLayoutTests {
    @Test("Every visible ring uses the same centre for drawing and input")
    func ringTargets() {
        for scale in [0.8, 1.0, 1.2] {
            for left in [false, true] {
                let layout = PetOrbLayout(size: CGSize(width: 760, height: 640), scale: scale, cardOnLeft: left)
                for count in 1...8 {
                    for index in 0..<count {
                        let point = layout.ringCentre(index: index, count: count)
                        #expect(layout.ringIndex(at: point, count: count) == index)
                        #expect(layout.containsOrb(point, expanded: true, petSize: 1.3))
                        #expect(!layout.containsOrb(point, expanded: false, petSize: 0.7))
                    }
                }
                #expect(layout.ringIndex(at: layout.centre, count: 8) == nil)
                #expect(layout.ringIndex(at: layout.centre, count: 0) == nil)
                #expect(!layout.containsOrb(.zero, expanded: true, petSize: 1))
            }
        }
    }

    @Test("Paging covers every slot once, including empty and shrinking lists")
    func pages() {
        for count in [0, 1, 8, 9, 16, 17, 200] {
            let pages = PetOrbLayout.pageCount(for: count)
            let indices = (0..<pages).flatMap { Array(PetOrbLayout.indices(count: count, page: $0)) }
            #expect(indices == Array(0..<count))
            #expect((0..<pages).allSatisfy { PetOrbLayout.indices(count: count, page: $0).count <= 8 })
            #expect(PetOrbLayout.indices(count: count, page: 999) == PetOrbLayout.indices(count: count, page: pages - 1))
        }
        #expect(PetOrbLayout.indices(count: -1, page: -1).isEmpty)
        #expect(PetOrbLayout.indices(count: 9, page: -1) == 0..<8)
    }

    @Test("Pet stays inside and centred in both the collapsed dot and expanded circle")
    func petPlacement() {
        for scale in [0.8, 1, 1.2] {
            for left in [false, true] {
                let layout = PetOrbLayout(size: CGSize(width: 760, height: 640), scale: scale, cardOnLeft: left)
                for size in [0.7, 1, 1.3] {
                    for expanded in [false, true] {
                        let pet = layout.petFrame(expanded: expanded, petSize: size)
                        let diameter = expanded ? layout.diameter : layout.dotDiameter
                        #expect(abs(pet.midX - layout.centre.x) < 0.001)
                        #expect(abs(pet.midY - layout.centre.y) < 0.001)
                        #expect(pet.width <= diameter)
                        #expect(pet.height <= diameter)
                        #expect(layout.containsOrb(layout.centre, expanded: expanded, petSize: size))
                    }
                }
            }
        }
    }

    @Test("Sun animation moves its rays, pulses and blinks, but is neutral when paused")
    func sunMotion() {
        let start = SunPetPose(time: 0, isAnimated: true)
        let moving = SunPetPose(time: 0.85, isAnimated: true)
        #expect(moving.rayAngle != start.rayAngle)
        #expect(moving.glowOpacity > start.glowOpacity)
        #expect(SunPetPose(time: 4.7, isAnimated: true).eyeHeight < start.eyeHeight)
        for time in [0.0, 0.85, 4.7, 24, 1000] {
            let paused = SunPetPose(time: time, isAnimated: false)
            #expect(paused.rayAngle == 0)
            #expect(paused.glowOpacity == 0.14)
            #expect(paused.eyeHeight == 7)
        }
    }

    @Test("Cards and their bridge remain reachable on either side without changing the window")
    func cards() {
        for scale in [0.8, 1.0, 1.2] {
            for left in [true, false] {
                for y: CGFloat in [160, 280, 400] {
                    let width: CGFloat = 240 * scale
                    let size = CGSize(width: (272 + 8 + 24) * scale + width, height: 560 * scale)
                    let layout = PetOrbLayout(size: size, scale: scale, cardOnLeft: left, verticalCentre: y * scale)
                    for height: CGFloat in [80, 300, 2000] {
                        let card = layout.cardFrame(height: height * scale, width: width)
                        #expect(card.minY >= layout.margin - 0.001)
                        #expect(card.maxY <= size.height - layout.margin + 0.001)
                        #expect(card.minX >= 0 && card.maxX <= size.width)
                        #expect(left ? card.maxX < layout.circle.minX : card.minX > layout.circle.maxX)
                        #expect(layout.containsBridge(CGPoint(x: card.midX, y: card.midY), card: card))
                        let bridgeX = left ? (card.maxX + layout.circle.minX) / 2 : (layout.circle.maxX + card.minX) / 2
                        #expect(layout.containsBridge(CGPoint(x: bridgeX, y: card.midY), card: card))
                        #expect(layout.size == size)
                    }
                }
            }
        }
    }
}

@Suite("Pet orb settings")
@MainActor
struct PetOrbSettingsTests {
    @Test("Sun is the default without replacing saved pet choices")
    func defaultPet() {
        let (defaults, cleanup) = TestDefaults.make("PetOrbDefault")
        defer { cleanup() }
        let fresh = AppSettings(defaults: defaults)
        #expect(fresh.orbPet == .sun)
        fresh.restorePetOrb(from: defaults)
        #expect(fresh.orbPet == .sun)
        for pet in OrbPet.allCases {
            defaults.set(pet.rawValue, forKey: "settings.orbPet")
            fresh.restorePetOrb(from: defaults)
            #expect(fresh.orbPet == pet)
        }
    }

    @Test("Pet settings persist locally without refreshing providers")
    func persistence() {
        let (defaults, cleanup) = TestDefaults.make("PetOrb")
        defer { cleanup() }
        let settings = AppSettings(defaults: defaults)
        var layouts = 0
        var refreshes = 0
        settings.onLayoutChange = { layouts += 1 }
        settings.onChange = { refreshes += 1 }
        #expect(settings.panelPresentation == .petOrb)
        settings.panelPresentation = .rail
        settings.orbPet = .fox
        settings.orbPetSize = 1.2
        settings.orbPetImage = Data([1, 2, 3])
        #expect(layouts == 4)
        #expect(refreshes == 0)
        #expect(defaults.string(forKey: "settings.panelPresentation") == "rail")
        #expect(defaults.string(forKey: "settings.orbPet") == "fox")
        #expect(defaults.double(forKey: "settings.orbPetSize") == 1.2)
        #expect(defaults.data(forKey: "settings.orbPetImage") == Data([1, 2, 3]))
        let restored = AppSettings.restoredSettings(from: defaults, detected: [], scan: ExtensionCatalog.Scan())
        #expect(restored.panelPresentation == .rail)
        #expect(restored.orbPet == .fox)
        #expect(restored.orbPetSize == 1.2)
        #expect(restored.orbPetImage == settings.orbPetImage)
        settings.orbPetImage = nil
        #expect(defaults.object(forKey: "settings.orbPetImage") == nil)
        settings.panelPresentation = .liquidPet
        #expect(AppSettings.restoredSettings(from: defaults, detected: [], scan: ExtensionCatalog.Scan())
            .panelPresentation == .liquidPet)
        #expect(PanelPresentation.petOrb.usesOrb && PanelPresentation.liquidPet.usesOrb)
        #expect(!PanelPresentation.rail.usesOrb)
    }

    @Test("Invalid choices and sizes fall back to safe defaults")
    func invalidSettings() {
        let (defaults, cleanup) = TestDefaults.make("PetOrbInvalid")
        defer { cleanup() }
        defaults.set("unknown", forKey: "settings.panelPresentation")
        defaults.set("unknown", forKey: "settings.orbPet")
        defaults.set(100, forKey: "settings.orbPetSize")
        let restored = AppSettings(defaults: defaults)
        restored.restorePetOrb(from: defaults)
        #expect(restored.panelPresentation == .petOrb)
        #expect(restored.orbPet == .sun)
        #expect(restored.orbPetSize == 1.3)
        restored.orbPetSize = .nan
        #expect(restored.orbPetSize == 1)
        restored.orbPetSize = -1
        #expect(restored.orbPetSize == 0.7)
    }

    @Test("PNG import bounds the stored image and preserves transparency")
    func imageImport() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("PulsePet-\(UUID()).png")
        defer { try? FileManager.default.removeItem(at: url) }
        let bitmap = try #require(NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 256,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        ))
        bitmap.bitmapData?.initialize(repeating: 0, count: bitmap.bytesPerRow * bitmap.pixelsHigh)
        try #require(bitmap.representation(using: .png, properties: [:])).write(to: url)
        let result = try PetImageImport.png(from: url)
        let imported = try #require(NSBitmapImageRep(data: result))
        #expect(imported.pixelsWide == 512)
        #expect(imported.pixelsHigh == 128)
        #expect(imported.hasAlpha)
        #expect(imported.colorAt(x: 0, y: 0)?.alphaComponent == 0)
        #expect(result.count <= 4_000_000)
        try Data("not an image".utf8).write(to: url)
        #expect(throws: PetImageImport.ImportError.self) { try PetImageImport.png(from: url) }
        try Data(repeating: 0, count: 20_000_001).write(to: url)
        #expect(throws: PetImageImport.ImportError.self) { try PetImageImport.png(from: url) }
    }
}
