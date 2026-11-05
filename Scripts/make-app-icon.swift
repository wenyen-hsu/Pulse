// Original Nokori artwork by the independent fork, licensed under Apache 2.0.
import CoreGraphics
import Foundation

func outline(_ path: CGPath, width: CGFloat) -> CGPath {
    path.copy(strokingWithWidth: width, lineCap: .round, lineJoin: .round, miterLimit: 1)
}

func svg(_ path: CGPath) -> String {
    var parts: [String] = []
    func point(_ value: CGPoint) -> String {
        String(format: "%.3f %.3f", locale: Locale(identifier: "en_US_POSIX"), value.x, value.y)
    }
    path.applyWithBlock { pointer in
        let element = pointer.pointee
        switch element.type {
        case .moveToPoint: parts.append("M" + point(element.points[0]))
        case .addLineToPoint: parts.append("L" + point(element.points[0]))
        case .addQuadCurveToPoint: parts.append("Q" + point(element.points[0]) + " " + point(element.points[1]))
        case .addCurveToPoint:
            parts.append("C" + point(element.points[0]) + " " + point(element.points[1]) + " " + point(element.points[2]))
        case .closeSubpath: parts.append("Z")
        @unknown default: preconditionFailure("Unsupported path element")
        }
    }
    return parts.joined(separator: " ")
}

func arc(radius: CGFloat, start: CGFloat = -90, end: CGFloat = 180) -> CGPath {
    let path = CGMutablePath()
    path.addArc(center: CGPoint(x: 512, y: 512), radius: radius,
                startAngle: start * .pi / 180, endAngle: end * .pi / 180,
                clockwise: false)
    return path
}

func circle(_ x: CGFloat, _ y: CGFloat, radius: CGFloat) -> CGPath {
    CGPath(ellipseIn: CGRect(x: x - radius, y: y - radius,
                            width: radius * 2, height: radius * 2), transform: nil)
}

func filled(_ path: CGPath, _ color: String, opacity: String = "1") -> String {
    "<path d=\"\(svg(path))\" fill=\"\(color)\" opacity=\"\(opacity)\"/>"
}

let ink = "#152246"
let yellow = "#FFE23E"
let ring = circle(512, 512, radius: 296)
let rays = CGMutablePath()
for index in 0..<8 {
    let angle = CGFloat(index) * .pi / 4
    let cosine: CGFloat = cos(angle)
    let sine: CGFloat = sin(angle)
    rays.move(to: CGPoint(x: 512 + 190 * cosine, y: 512 + 190 * sine))
    rays.addLine(to: CGPoint(x: 512 + 217 * cosine, y: 512 + 217 * sine))
}
let smile = CGMutablePath()
smile.move(to: CGPoint(x: 483, y: 549))
smile.addQuadCurve(to: CGPoint(x: 541, y: 549), control: CGPoint(x: 512, y: 583))

let shade = CGMutablePath()
shade.move(to: CGPoint(x: 648, y: 425))
shade.addCurve(to: CGPoint(x: 402, y: 634),
               control1: CGPoint(x: 665, y: 607), control2: CGPoint(x: 533, y: 655))
shade.addLine(to: CGPoint(x: 685, y: 694))
shade.addLine(to: CGPoint(x: 700, y: 416))
shade.closeSubpath()

let sparkle = CGMutablePath()
sparkle.move(to: CGPoint(x: 828, y: 197))
sparkle.addQuadCurve(to: CGPoint(x: 853, y: 222), control: CGPoint(x: 833, y: 217))
sparkle.addQuadCurve(to: CGPoint(x: 828, y: 247), control: CGPoint(x: 833, y: 227))
sparkle.addQuadCurve(to: CGPoint(x: 803, y: 222), control: CGPoint(x: 823, y: 227))
sparkle.addQuadCurve(to: CGPoint(x: 828, y: 197), control: CGPoint(x: 823, y: 217))
sparkle.closeSubpath()

var dots = ""
for row in 0..<9 {
    for column in 0..<(10 - row) {
        let radius = CGFloat(5) - CGFloat(row) * 0.25
        dots += filled(circle(154 + CGFloat(column) * 23, 163 + CGFloat(row) * 23,
                              radius: radius), "#8292A8", opacity: ".1") + "\n"
        dots += filled(circle(863 - CGFloat(column) * 23, 865 - CGFloat(row) * 23,
                              radius: radius), "#8292A8", opacity: ".1") + "\n"
    }
}

let definitions = """
<defs>
  <linearGradient id="background" x1=".06" y1="0" x2=".88" y2="1">
    <stop stop-color="#FFFFFF"/><stop offset=".3" stop-color="#F6F8FB"/>
    <stop offset=".72" stop-color="#E1E7EE"/><stop offset="1" stop-color="#F7F9FC"/>
  </linearGradient>
  <radialGradient id="glow" cx=".1" cy=".06" r=".8">
    <stop stop-color="#FFFFFF" stop-opacity=".85"/><stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/>
  </radialGradient>
  <clipPath id="sun-clip"><circle cx="512" cy="512" r="154"/></clipPath>
  <clipPath id="tile-clip"><rect x="64" y="64" width="896" height="896" rx="208"/></clipPath>
</defs>
"""
let mark = """
\(dots)
<g transform="translate(0 9)">\(filled(outline(ring, width: 86), "#7C8DA0", opacity: ".18"))</g>
<g id="glass-track">
\(filled(outline(ring, width: 80), "#B5C4D4", opacity: ".33"))
\(filled(outline(circle(512, 512, radius: 335), width: 2.5), "#71869D", opacity: ".5"))
\(filled(outline(circle(512, 512, radius: 257), width: 3), "#71869D", opacity: ".5"))
</g>
<g id="static-brand-arc">
\(filled(outline(arc(radius: 296), width: 51), "#B51B40"))
\(filled(outline(arc(radius: 296), width: 42), "#FF354F"))
\(filled(outline(arc(radius: 300, start: -86, end: 176), width: 6), "#FF9BB0", opacity: ".75"))
</g>
\(filled(outline(rays, width: 40), ink))
\(filled(outline(rays, width: 23), yellow))
\(filled(circle(522, 526, radius: 156), ink))
\(filled(circle(512, 512, radius: 154), yellow))
<g clip-path="url(#sun-clip)">\(filled(shade, "#FFAC29"))</g>
\(filled(outline(circle(512, 512, radius: 154), width: 13), ink))
<ellipse cx="471" cy="428" rx="42" ry="12" fill="#FFFBE8" transform="rotate(-25.714286 471 428)"/>
<g fill="#FF786C"><ellipse cx="456.5" cy="542" rx="13.5" ry="7"/><ellipse cx="567.5" cy="542" rx="13.5" ry="7"/></g>
<g fill="\(ink)"><ellipse cx="475" cy="513.5" rx="9" ry="13.5"/><ellipse cx="549" cy="513.5" rx="9" ry="13.5"/></g>
\(filled(outline(smile, width: 10), ink))
\(filled(sparkle, "#FFFBE8"))
"""

func document(background: Bool) -> String {
    let tile = background ? """
    <rect x="64" y="64" width="896" height="896" rx="208" fill="url(#background)"/>
    <rect x="64" y="64" width="896" height="896" rx="208" fill="url(#glow)"/>
    <g clip-path="url(#tile-clip)"><path d="M20 380 C310 80 690 210 1010 150 L1010 -80 L20 -80 Z" fill="#FFFFFF" opacity=".48"/></g>
    \(filled(outline(CGPath(roundedRect: CGRect(x: 64, y: 64, width: 896, height: 896), cornerWidth: 208, cornerHeight: 208, transform: nil), width: 3), "#BAC8D7", opacity: ".85"))
    \(filled(outline(CGPath(roundedRect: CGRect(x: 72, y: 72, width: 880, height: 880), cornerWidth: 202, cornerHeight: 202, transform: nil), width: 4), "#FFFFFF", opacity: ".95"))
    """ : ""
    return """
    <svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
    <!-- Original Nokori white-glass Pop sun. The red arc is a fixed brand mark, not live usage. Apache-2.0. -->
    \(definitions)
    \(tile)
    \(mark)
    </svg>

    """
}

for path in ["AppIcon/nokori-mark.svg", "AppIcon/AppIcon.icon/Assets/mark.svg"] {
    try document(background: false).write(toFile: path, atomically: true, encoding: .utf8)
}
try document(background: true).write(toFile: "AppIcon/nokori-icon.svg", atomically: true, encoding: .utf8)

let composerPath = "AppIcon/AppIcon.icon/icon.json"
let composer = try String(contentsOfFile: composerPath, encoding: .utf8)
let background = try NSRegularExpression(pattern: #""automatic-gradient"\s*:\s*"[^"]*""#)
let range = NSRange(composer.startIndex..., in: composer)
precondition(background.numberOfMatches(in: composer, range: range) == 1)
let updatedComposer = background.stringByReplacingMatches(
    in: composer, range: range,
    withTemplate: #""automatic-gradient": "srgb:0.96471,0.97255,0.98431,1.00000""#
)
try updatedComposer.write(toFile: composerPath, atomically: true, encoding: .utf8)
