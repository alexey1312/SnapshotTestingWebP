#if os(macOS)
    import Cocoa
    import XCTest
    @testable import SnapshotTesting

    public extension Diffing where Value == NSImage {
        static let imageWebP = Diffing.imageWebP(precision: 1, perceptualPrecision: 1, compressionQuality: .lossless)

        static func imageWebP(
            precision: Float,
            perceptualPrecision: Float = 1,
            compressionQuality: CompressionQuality = .lossless
        ) -> Diffing {
            return .init(
                toData: { $0.webpData(compressionQuality: compressionQuality.rawValue) ?? Data() },
                fromData: { NSImage(data: $0) ?? NSImage() }
            ) { old, new in
                guard
                    let message = compareWebP(
                        old,
                        new,
                        precision: precision,
                        perceptualPrecision: perceptualPrecision,
                        compressionQuality: compressionQuality
                    )
                else { return nil }
                let difference = diffNSImage(old, new)
                return (
                    message,
                    [XCTAttachment(image: old), XCTAttachment(image: new), XCTAttachment(image: difference)]
                )
            }
        }
    }

    public extension Snapshotting where Value == NSImage, Format == NSImage {
        static var imageWebP: Snapshotting {
            return .imageWebP(precision: 1, perceptualPrecision: 1)
        }

        static func imageWebP(
            precision: Float,
            perceptualPrecision: Float = 1,
            compressionQuality: CompressionQuality = .lossless
        ) -> Snapshotting {
            return .init(
                pathExtension: "webp",
                diffing: .imageWebP(
                    precision: precision,
                    perceptualPrecision: perceptualPrecision,
                    compressionQuality: compressionQuality
                )
            )
        }
    }

    /// Compares two NSImages for WebP snapshot testing.
    ///
    /// Returns `nil` if the images match within the given thresholds,
    /// or a descriptive error message explaining the mismatch.
    private func compareWebP(
        _ old: NSImage,
        _ new: NSImage,
        precision: Float,
        perceptualPrecision: Float,
        compressionQuality: CompressionQuality
    ) -> String? {
        guard let oldCgImage = old.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return "Reference image could not be loaded."
        }
        guard let newCgImage = new.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return "Newly-taken snapshot could not be loaded."
        }
        guard newCgImage.width != 0, newCgImage.height != 0 else {
            return "Newly-taken snapshot is empty."
        }
        guard oldCgImage.width == newCgImage.width, oldCgImage.height == newCgImage.height else {
            return "Newly-taken snapshot@\(new.size) does not match reference@\(old.size)."
        }

        guard let oldContext = context(for: oldCgImage),
            let newContext = context(for: newCgImage),
            let oldData = oldContext.data,
            let newData = newContext.data
        else {
            return "Reference image's data could not be loaded."
        }

        let byteCount = oldContext.height * oldContext.bytesPerRow

        // Fast path: exact match
        if memcmp(oldData, newData, byteCount) == 0 { return nil }

        // Re-encode and compare to account for WebP codec differences
        guard let webpData = new.webpData(compressionQuality: compressionQuality.rawValue),
            let reencoded = NSImage(data: webpData),
            let reencodedCgImage = reencoded.cgImage(forProposedRect: nil, context: nil, hints: nil),
            let reencodedContext = context(for: reencodedCgImage),
            let reencodedData = reencodedContext.data
        else {
            return "Newly-taken snapshot's data could not be loaded."
        }

        if memcmp(oldData, reencodedData, byteCount) == 0 { return nil }

        let compareContext = reencodedContext

        if precision >= 1, perceptualPrecision >= 1 {
            return "Newly-taken snapshot does not match reference."
        }

        // Perceptual comparison using CILabDeltaE
        if perceptualPrecision < 1 {
            let oldCiImage = CIImage(cgImage: oldCgImage)
            let compareCgImage = compareContext.makeImage()!
            let newCiImage = CIImage(cgImage: compareCgImage)

            if let labDeltaE = CIFilter(name: "CILabDeltaE"),
                let areaAverage = CIFilter(name: "CIAreaAverage")
            {
                labDeltaE.setValue(oldCiImage, forKey: kCIInputImageKey)
                labDeltaE.setValue(newCiImage, forKey: "inputImage2")

                if let deltaOutput = labDeltaE.outputImage {
                    let extent = deltaOutput.extent
                    areaAverage.setValue(deltaOutput, forKey: kCIInputImageKey)
                    areaAverage.setValue(CIVector(cgRect: extent), forKey: "inputExtent")

                    if let avgOutput = areaAverage.outputImage {
                        let ciContext = CIContext(options: [.workingColorSpace: NSNull()])
                        var pixel = [Float](repeating: 0, count: 4)
                        ciContext.render(
                            avgOutput,
                            toBitmap: &pixel,
                            rowBytes: 16,
                            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                            format: .RGBAf,
                            colorSpace: nil
                        )
                        let averageDeltaE = pixel[0]
                        let maxAcceptableDeltaE = (1 - perceptualPrecision) * 100
                        if averageDeltaE <= maxAcceptableDeltaE { return nil }

                        let actualPerceptualPrecision = 1 - averageDeltaE / 100
                        return
                            "Actual perceptual precision \(actualPerceptualPrecision) is less than required \(perceptualPrecision)"
                    }
                }
            }
        }

        // Pixel precision comparison with early exit
        let oldRep = NSBitmapImageRep(cgImage: oldCgImage)
        let compareCgImage = compareContext.makeImage()!
        let newRep = NSBitmapImageRep(cgImage: compareCgImage)

        guard let p1 = oldRep.bitmapData, let p2 = newRep.bitmapData else {
            return "Image bitmap data could not be accessed."
        }

        let pixelCount = oldRep.pixelsWide * oldRep.pixelsHigh
        let totalBytes = pixelCount * 4
        let threshold = Int((1 - precision) * Float(totalBytes))
        var differentByteCount = 0

        for offset in 0 ..< totalBytes {
            if p1[offset] != p2[offset] {
                differentByteCount += 1
                if differentByteCount > threshold {
                    let actualPrecision = 1 - Float(differentByteCount) / Float(totalBytes)
                    return "Actual image precision \(actualPrecision) is less than required \(precision)"
                }
            }
        }

        return nil
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
