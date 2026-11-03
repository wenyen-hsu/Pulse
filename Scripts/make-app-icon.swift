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

let ring = CGMutablePath()
ring.addArc(center: CGPoint(x: 512, y: 512), radius: 180,
            startAngle: -.pi / 6, endAngle: .pi * 1.5, clockwise: false)
let shine = CGMutablePath()
shine.move(to: CGPoint(x: 248, y: 441))
shine.addCurve(to: CGPoint(x: 370, y: 335),
               control1: CGPoint(x: 259, y: 378), control2: CGPoint(x: 307, y: 346))
let highlight = CGMutablePath()
highlight.move(to: CGPoint(x: 470, y: 479))
highlight.addCurve(to: CGPoint(x: 509, y: 462),
                   control1: CGPoint(x: 481, y: 465), control2: CGPoint(x: 495, y: 461))
let smile = CGMutablePath()
smile.move(to: CGPoint(x: 499, y: 538))
smile.addQuadCurve(to: CGPoint(x: 525, y: 538), control: CGPoint(x: 512, y: 548))

let definitions = """
<defs>
  <linearGradient id="water" x1="0" y1="0" x2=".8" y2="1">
    <stop stop-color="#E6FFF4"/><stop offset=".5" stop-color="#A4E3D0"/><stop offset="1" stop-color="#58ACAA"/>
  </linearGradient>
  <linearGradient id="sun" x1=".2" y1="0" x2=".8" y2="1">
    <stop stop-color="#FFE8A4"/><stop offset="1" stop-color="#F7B75A"/>
  </linearGradient>
</defs>
"""
let mark = """
<path d="M215 472C191 379 264 317 359 304C453 292 479 266 573 303C682 345 798 353 812 454C829 566 762 701 646 730C528 760 431 695 332 713C248 728 193 641 215 472Z" fill="url(#water)"/>
<path d="\(svg(outline(shine, width: 8)))" fill="#FFFFFF" opacity=".55"/>
<path d="\(svg(outline(ring, width: 42)))" fill="#163F43"/>
<circle cx="628" cy="365" r="23" fill="#FFE2A0"/>
<circle cx="512" cy="512" r="79" fill="url(#sun)"/>
<path d="\(svg(outline(highlight, width: 9)))" fill="#FFF6D2"/>
<g fill="#543E2C"><circle cx="490" cy="515" r="5"/><circle cx="534" cy="515" r="5"/></g>
<path d="\(svg(outline(smile, width: 5)))" fill="#543E2C"/>
"""

func document(background: Bool) -> String {
    let tile = background ? "<rect x=\"64\" y=\"64\" width=\"896\" height=\"896\" rx=\"208\" fill=\"#0D2C32\"/>" : ""
    return """
    <svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
    <!-- Original Nokori liquid, remaining-quota ring and sun artwork. Apache-2.0. -->
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
