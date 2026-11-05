// Modified by wenyen-hsu: reproducible independent installer branding.
import AppKit

let identityURL = URL(fileURLWithPath: "Sources/Pulse/Resources/AppIdentity.json")
let identity = try JSONSerialization.jsonObject(with: Data(contentsOf: identityURL)) as! [String: String]
let name = identity["name"]!
let size = NSSize(width: 660, height: 420)
let drawing = NSImage(size: size, flipped: true) { _ in
    NSColor(calibratedRed: 0.985, green: 0.98, blue: 0.97, alpha: 1).setFill()
    NSRect(origin: .zero, size: size).fill()
    func line(_ text: String, y: CGFloat, size: CGFloat, bold: Bool = false, shade: CGFloat = 0.3) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        (text as NSString).draw(in: NSRect(x: 20, y: y, width: 620, height: 30), withAttributes: [
            .font: bold ? NSFont.boldSystemFont(ofSize: size) : NSFont.systemFont(ofSize: size),
            .foregroundColor: NSColor(calibratedWhite: shade, alpha: 1),
            .paragraphStyle: paragraph,
        ])
    }
    line(name, y: 44, size: 26, bold: true, shade: 0.15)
    line("Drag \(name) into Applications", y: 82, size: 13)
    let arrow = NSBezierPath()
    arrow.move(to: NSPoint(x: 270, y: 196))
    arrow.line(to: NSPoint(x: 388, y: 196))
    arrow.move(to: NSPoint(x: 376, y: 187))
    arrow.line(to: NSPoint(x: 388, y: 196))
    arrow.line(to: NSPoint(x: 376, y: 205))
    arrow.lineWidth = 3
    arrow.lineCapStyle = .round
    arrow.lineJoinStyle = .round
    NSColor(calibratedWhite: 0.7, alpha: 1).setStroke()
    arrow.stroke()
    line("Based on Pulse by qunqin24 · Apache 2.0", y: 288, size: 12)
    line("Thank you to the original author and contributors.", y: 306, size: 11, shade: 0.45)
    line("Cannot verify? Choose Done (not Move to Trash).", y: 346, size: 12)
    line("Then System Settings → Privacy & Security → Open Anyway.", y: 366, size: 12)
    line("Unnotarized trial. Trust the source first; never disable Gatekeeper.", y: 386, size: 11, shade: 0.45)
    return true
}
let representations: [NSBitmapImageRep] = [1, 2].map { scale in
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 660 * scale, pixelsHigh: 420 * scale,
                              bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                              colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    drawing.draw(in: NSRect(origin: .zero, size: size))
    NSGraphicsContext.restoreGraphicsState()
    return rep
}
let data = NSBitmapImageRep.representationOfImageReps(in: representations, using: .tiff, properties: [:])!
try data.write(to: URL(fileURLWithPath: "Scripts/dmg-background.tiff"))
