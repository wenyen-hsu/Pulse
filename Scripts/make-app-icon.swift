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

func arc(radius: CGFloat, start: CGFloat = -.pi / 6, end: CGFloat = .pi * 1.5) -> CGPath {
    let path = CGMutablePath()
    path.addArc(center: CGPoint(x: 512, y: 512), radius: radius,
                startAngle: start, endAngle: end, clockwise: false)
    return path
}

let ring = arc(radius: 274)
let rays = CGMutablePath()
for index in 0..<8 {
    let angle = CGFloat(index) * .pi / 4
    rays.move(to: CGPoint(x: 512 + 174 * cos(angle), y: 512 + 174 * sin(angle)))
    rays.addLine(to: CGPoint(x: 512 + 198 * cos(angle), y: 512 + 198 * sin(angle)))
}
let smile = CGMutablePath()
smile.move(to: CGPoint(x: 487, y: 550))
smile.addQuadCurve(to: CGPoint(x: 537, y: 550), control: CGPoint(x: 512, y: 575))

let definitions = """
<defs>
  <linearGradient id="background" x1=".15" y1="0" x2=".85" y2="1">
    <stop stop-color="#183956"/><stop offset=".52" stop-color="#103E66"/><stop offset="1" stop-color="#176E9D"/>
  </linearGradient>
  <radialGradient id="glow" cx=".12" cy=".16" r=".9">
    <stop stop-color="#91DCFF" stop-opacity=".35"/><stop offset="1" stop-color="#67D2FF" stop-opacity="0"/>
  </radialGradient>
  <linearGradient id="edge" x1="0" y1="0" x2="1" y2="1">
    <stop stop-color="#E7F8FF" stop-opacity=".8"/><stop offset=".5" stop-color="#6AC6FF" stop-opacity=".13"/><stop offset="1" stop-color="#D6F2FF" stop-opacity=".6"/>
  </linearGradient>
  <linearGradient id="glass" x1=".08" y1="0" x2=".85" y2="1">
    <stop stop-color="#F0FCFF" stop-opacity=".96"/><stop offset=".35" stop-color="#A6DEFA" stop-opacity=".87"/>
    <stop offset=".67" stop-color="#65B8EE" stop-opacity=".62"/><stop offset="1" stop-color="#B6EBFF" stop-opacity=".93"/>
  </linearGradient>
  <linearGradient id="sun" x1=".2" y1="0" x2=".8" y2="1">
    <stop stop-color="#FFF2BC"/><stop offset=".45" stop-color="#FFDA7F"/><stop offset="1" stop-color="#F4B452"/>
  </linearGradient>
</defs>
"""
let mark = """
<path d="\(svg(outline(ring, width: 66)))" fill="url(#edge)"/>
<path d="\(svg(outline(ring, width: 60)))" fill="url(#glass)"/>
<path d="\(svg(outline(arc(radius: 303), width: 2.5)))" fill="#E2F6FF" opacity=".55"/>
<path d="\(svg(outline(arc(radius: 246), width: 2)))" fill="#1A6295" opacity=".6"/>
<path d="\(svg(outline(arc(radius: 275, start: .pi * 195 / 180, end: .pi * 259 / 180), width: 5)))" fill="#F3FCFF" opacity=".8"/>
<circle cx="649" cy="275" r="28" fill="#D7F5FF"/>
<circle cx="649" cy="275" r="26" fill="url(#glass)"/>
<ellipse cx="641" cy="267" rx="10" ry="5" fill="#FFFFFF" opacity=".6" transform="rotate(-35 641 267)"/>
<path d="\(svg(outline(rays, width: 15)))" fill="#FFDA87"/>
<circle cx="512" cy="512" r="132" fill="url(#sun)"/>
<ellipse cx="481" cy="450" rx="64" ry="25" fill="#FFFFFF" opacity=".19" transform="rotate(-24 481 450)"/>
<g fill="#604524"><ellipse cx="474" cy="510" rx="8" ry="11"/><ellipse cx="550" cy="510" rx="8" ry="11"/></g>
<path d="\(svg(outline(smile, width: 9)))" fill="#604524"/>
"""

func document(background: Bool) -> String {
    let tile = background ? """
    <rect x="64" y="64" width="896" height="896" rx="208" fill="url(#background)"/>
    <rect x="64" y="64" width="896" height="896" rx="208" fill="url(#glow)"/>
    """ : ""
    return """
    <svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
    <!-- Original Nokori blue-glass remaining-quota ring and sun artwork. Apache-2.0. -->
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
    withTemplate: #""automatic-gradient": "srgb:0.06275,0.24314,0.40000,1.00000""#
)
try updatedComposer.write(toFile: composerPath, atomically: true, encoding: .utf8)
