#!/usr/bin/env swift

import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconsetURL = root.appending(path: ".build/release-assets/GitPulse.iconset")
let outputURL = root.appending(path: "Assets/GitPulse.icns")

try? FileManager.default.removeItem(at: iconsetURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)
try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)

let requiredIcons: [(name: String, pixels: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for icon in requiredIcons {
    let image = drawIcon(pixels: icon.pixels)
    let destination = iconsetURL.appending(path: icon.name)
    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:])
    else {
        fatalError("Unable to render \(icon.name)")
    }
    try png.write(to: destination)
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", outputURL.path]
try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    fatalError("iconutil failed with status \(process.terminationStatus)")
}

print("Generated \(outputURL.path)")

private func drawIcon(pixels: Int) -> NSImage {
    let size = NSSize(width: pixels, height: pixels)
    let image = NSImage(size: size)

    image.lockFocus()
    defer { image.unlockFocus() }

    guard let context = NSGraphicsContext.current?.cgContext else {
        fatalError("Unable to create drawing context")
    }

    context.saveGState()
    context.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)
    drawBase()
    drawBranch()
    drawPulse()
    context.restoreGState()

    return image
}

private func drawBase() {
    let bg = roundedRect(x: 0, y: 0, width: 1024, height: 1024, radius: 228)
    NSColor(red: 0.04, green: 0.07, blue: 0.11, alpha: 1).setFill()
    bg.fill()

    let panel = roundedRect(x: 244, y: 210, width: 536, height: 604, radius: 60)
    NSColor(red: 0.06, green: 0.08, blue: 0.11, alpha: 1).setFill()
    panel.fill()
    NSColor(red: 0.19, green: 0.22, blue: 0.26, alpha: 1).setStroke()
    panel.lineWidth = 8
    panel.stroke()
}

private func drawBranch() {
    NSColor(red: 0.55, green: 0.58, blue: 0.62, alpha: 1).setStroke()

    let trunk = NSBezierPath()
    trunk.lineWidth = 46
    trunk.lineCapStyle = .round
    trunk.move(to: NSPoint(x: 344, y: 334))
    trunk.line(to: NSPoint(x: 344, y: 676))
    trunk.stroke()

    let branch = NSBezierPath()
    branch.lineWidth = 46
    branch.lineCapStyle = .round
    branch.lineJoinStyle = .round
    branch.move(to: NSPoint(x: 344, y: 496))
    branch.line(to: NSPoint(x: 438, y: 496))
    branch.curve(
        to: NSPoint(x: 493, y: 440),
        controlPoint1: NSPoint(x: 472, y: 496),
        controlPoint2: NSPoint(x: 493, y: 474)
    )
    branch.line(to: NSPoint(x: 493, y: 382))
    branch.stroke()

    drawNode(center: NSPoint(x: 344, y: 334), radius: 62, color: statusGreen(), stroke: 42)
    drawNode(center: NSPoint(x: 344, y: 676), radius: 62, color: statusBlue(), stroke: 42)
    drawNode(center: NSPoint(x: 493, y: 382), radius: 58, color: statusPurple(), stroke: 40)
}

private func drawPulse() {
    let pulse = NSBezierPath()
    pulse.lineWidth = 56
    pulse.lineCapStyle = .round
    pulse.lineJoinStyle = .round
    pulse.move(to: NSPoint(x: 244, y: 548))
    pulse.line(to: NSPoint(x: 360, y: 548))
    pulse.line(to: NSPoint(x: 414, y: 452))
    pulse.line(to: NSPoint(x: 486, y: 646))
    pulse.line(to: NSPoint(x: 548, y: 548))
    pulse.line(to: NSPoint(x: 780, y: 548))
    statusBlue().setStroke()
    pulse.stroke()

    let highlight = pulse.copy() as! NSBezierPath
    highlight.lineWidth = 16
    NSColor.white.withAlphaComponent(0.18).setStroke()
    highlight.stroke()

    drawNode(center: NSPoint(x: 780, y: 548), radius: 50, color: statusGreen(), stroke: 34)
    statusGreen().setFill()
    NSBezierPath(ovalIn: NSRect(x: 762, y: 530, width: 36, height: 36)).fill()
}

private func drawNode(center: NSPoint, radius: CGFloat, color: NSColor, stroke: CGFloat) {
    let rect = NSRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    )
    NSColor(red: 0.05, green: 0.07, blue: 0.09, alpha: 1).setFill()
    NSBezierPath(ovalIn: rect).fill()
    color.setStroke()
    let ring = NSBezierPath(ovalIn: rect)
    ring.lineWidth = stroke
    ring.stroke()
}

private func roundedRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(
        roundedRect: NSRect(x: x, y: y, width: width, height: height),
        xRadius: radius,
        yRadius: radius
    )
}

private func statusGreen() -> NSColor {
    NSColor(red: 0.25, green: 0.73, blue: 0.31, alpha: 1)
}

private func statusBlue() -> NSColor {
    NSColor(red: 0.47, green: 0.72, blue: 1.0, alpha: 1)
}

private func statusPurple() -> NSColor {
    NSColor(red: 0.64, green: 0.44, blue: 0.97, alpha: 1)
}
