#if os(macOS)
import Cocoa
import XCTest
@testable import SnapshotTesting

public extension Diffing where Value == NSImage {
    static let imageWebP = Diffing.imageWebP(precision: 1, compressionQuality: .lossless)

    static func imageWebP(precision: Float, compressionQuality: CompressionQuality = .lossless) -> Diffing {
        return .init(
            toData: { NSImageWebPRepresentation($0, compressionQuality: compressionQuality) ?? Data() },
            fromData: { NSImage(data: $0) ?? NSImage() }
        ) { old, new in
            guard !compareWebP(old, new, precision: precision, compressionQuality: compressionQuality)
            else { return nil }
            let difference = diffNSImage(old, new)
            let message = new.size == old.size
            ? "Newly-taken snapshot does not match reference."
            : "Newly-taken snapshot@\(new.size) does not match reference@\(old.size)."
            return (
                message,
                [XCTAttachment(image: old), XCTAttachment(image: new), XCTAttachment(image: difference)]
            )
        }
    }
}

public extension Snapshotting where Value == NSImage, Format == NSImage {
    static var imageWebP: Snapshotting {
        return .imageWebP(precision: 1)
    }

    static func imageWebP(precision: Float) -> Snapshotting {
        return .init(pathExtension: "webp", diffing: .imageWebP(precision: precision))
    }
}

private func NSImageWebPRepresentation(_ image: NSImage, compressionQuality: CompressionQuality) -> Data? {
    return image.webpData(compressionQuality: compressionQuality.rawValue)
}

private func compareWebP(
    _ old: NSImage,
    _ new: NSImage,
    precision: Float,
    compressionQuality: CompressionQuality
) -> Bool {
    guard let oldCgImage = old.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
    guard let newCgImage = new.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
    guard oldCgImage.width != 0 else { return false }
    guard newCgImage.width != 0 else { return false }
    guard oldCgImage.width == newCgImage.width else { return false }
    guard oldCgImage.height != 0 else { return false }
    guard newCgImage.height != 0 else { return false }
    guard oldCgImage.height == newCgImage.height else { return false }
    guard let oldContext = context(for: oldCgImage) else { return false }
    guard let newContext = context(for: newCgImage) else { return false }
    guard let oldData = oldContext.data else { return false }
    guard let newData = newContext.data else { return false }
    let byteCount = oldContext.height * oldContext.bytesPerRow
    if memcmp(oldData, newData, byteCount) == 0 { return true }
    guard let webpData = NSImageWebPRepresentation(new, compressionQuality: compressionQuality),
          let newer = NSImage(data: webpData) else { return false }
    guard let newerCgImage = newer.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
    guard let newerContext = context(for: newerCgImage) else { return false }
    guard let newerData = newerContext.data else { return false }
    if memcmp(oldData, newerData, byteCount) == 0 { return true }
    if precision >= 1 { return false }
    let oldRep = NSBitmapImageRep(cgImage: oldCgImage)
    let newRep = NSBitmapImageRep(cgImage: newerCgImage)
    var differentPixelCount = 0
    let pixelCount = oldRep.pixelsWide * oldRep.pixelsHigh
    let threshold = (1 - precision) * Float(pixelCount)
    let p1: UnsafeMutablePointer<UInt8> = oldRep.bitmapData!
    let p2: UnsafeMutablePointer<UInt8> = newRep.bitmapData!
    for offset in 0 ..< pixelCount * 4 {
        if p1[offset] != p2[offset] {
            differentPixelCount += 1
        }
        if Float(differentPixelCount) > threshold { return false }
    }
    return true
}

private func context(for cgImage: CGImage) -> CGContext? {
    guard
        let space = cgImage.colorSpace,
        let context = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: cgImage.bytesPerRow,
            space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    else { return nil }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
    return context
}

private func diffNSImage(_ old: NSImage, _ new: NSImage) -> NSImage {
    let oldCiImage = CIImage(cgImage: old.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
    let newCiImage = CIImage(cgImage: new.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
    let differenceFilter = CIFilter(name: "CIDifferenceBlendMode")!
    differenceFilter.setValue(oldCiImage, forKey: kCIInputImageKey)
    differenceFilter.setValue(newCiImage, forKey: kCIInputBackgroundImageKey)
    let maxSize = CGSize(
        width: max(old.size.width, new.size.width),
        height: max(old.size.height, new.size.height)
    )
    let rep = NSCIImageRep(ciImage: differenceFilter.outputImage!)
    let difference = NSImage(size: maxSize)
    difference.addRepresentation(rep)
    return difference
}
#endif
