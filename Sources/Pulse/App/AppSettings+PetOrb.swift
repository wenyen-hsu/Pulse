// Copyright (c) 2026 qunqin24. Licensed under the Apache License, Version 2.0.
import AppKit
import ImageIO

enum PanelPresentation: String, CaseIterable, Identifiable {
    case petOrb, rail
    var id: String { rawValue }
    var title: String {
        switch self {
        case .petOrb: .localized("Pet orb")
        case .rail: .localized("Classic rail")
        }
    }
}

enum OrbPet: String, CaseIterable, Identifiable {
    case sun, cat, fox, rabbit
    var id: String { rawValue }
    var title: String {
        switch self {
        case .sun: .localized("Little sun")
        case .cat: .localized("Cat")
        case .fox: .localized("Fox")
        case .rabbit: .localized("Rabbit")
        }
    }
}

extension AppSettings.Key {
    static let panelPresentation = "settings.panelPresentation"
    static let orbPet = "settings.orbPet"
    static let orbPetSize = "settings.orbPetSize"
    static let orbPetImage = "settings.orbPetImage"
    static let orbPosition = "settings.orbPosition"
}

extension AppSettings {
    static func boundedPetSize(_ size: Double) -> Double {
        size.isFinite ? min(max(size, 0.7), 1.3) : 1
    }

    func restorePetOrb(from defaults: UserDefaults) {
        panelPresentation = defaults.string(forKey: Key.panelPresentation)
            .flatMap(PanelPresentation.init(rawValue:)) ?? .petOrb
        orbPet = defaults.string(forKey: Key.orbPet).flatMap(OrbPet.init(rawValue:)) ?? .sun
        orbPetSize = Self.boundedPetSize(defaults.object(forKey: Key.orbPetSize) as? Double ?? 1)
        orbPetImage = defaults.data(forKey: Key.orbPetImage)
    }
}

enum PetImageImport {
    /// Bound both the input and the stored image; no external file is needed after import.
    static func png(from url: URL) throws -> Data {
        let bytes = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard bytes > 0, bytes <= 20_000_000,
              let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: 512,
                kCGImageSourceCreateThumbnailWithTransform: true
              ] as CFDictionary)
        else { throw ImportError.invalidImage }
        let bitmap = NSBitmapImageRep(cgImage: image)
        guard let data = bitmap.representation(using: .png, properties: [:]), data.count <= 4_000_000
        else { throw ImportError.invalidImage }
        return data
    }

    enum ImportError: Error { case invalidImage }
}
