#if os(iOS) || os(tvOS)
    import UIKit
    import XCTest
    import SnapshotTesting

    public extension Diffing where Value == UIImage {
        static let imageWebP = Diffing.imageWebP()

        static func imageWebP(
            precision: Float = 1,
            perceptualPrecision: Float = 1,
            scale: CGFloat? = nil,
            compressionQuality: CompressionQuality = .lossless
        ) -> Diffing {
            let imageScale: CGFloat
            if let scale = scale, scale != 0.0 {
                imageScale = scale
            } else {
                imageScale = UIScreen.main.scale
            }

            let emptyWebPData = emptyImage().webpData(compressionQuality: compressionQuality.rawValue) ?? Data()

            return Diffing(
                toData: { $0.webpData(compressionQuality: compressionQuality.rawValue) ?? emptyWebPData },
                fromData: { UIImage(data: $0, scale: imageScale) ?? emptyImage() },
                diff: { old, new in
                    guard
                        let message = compareWebP(
                            old,
                            new,
                            precision: precision,
                            perceptualPrecision: perceptualPrecision,
                            compressionQuality: compressionQuality
                        )
                    else { return nil }

                    let difference = diffImage(old, new)
                    let oldAttachment = XCTAttachment(image: old)
                    oldAttachment.name = "reference"
                    let isEmptyImage = new.size == .zero
                    let newAttachment = XCTAttachment(image: isEmptyImage ? emptyImage() : new)
                    newAttachment.name = "failure"
                    let differenceAttachment = XCTAttachment(image: difference)
                    differenceAttachment.name = "difference"
                    return (
                        message,
                        [oldAttachment, newAttachment, differenceAttachment]
                    )
                }
            )
        }

        private static func emptyImage() -> UIImage {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 80))
            label.backgroundColor = .red
            label.text = """
                Error: No image could be generated for this view as its size was zero.
                Please set an explicit size in the test.
                """
            label.textAlignment = .center
            label.numberOfLines = 3
            return label.asImage()
        }
    }

    public extension Snapshotting where Value == UIImage, Format == UIImage {
        static var imageWebP: Snapshotting {
            return .imageWebP()
        }

        static func imageWebP(
            precision: Float = 1,
            perceptualPrecision: Float = 1,
            scale: CGFloat? = nil,
            compressionQuality: CompressionQuality = .lossless
        ) -> Snapshotting {
            return Snapshotting(
                pathExtension: "webp",
                diffing: Diffing<UIImage>
                    .imageWebP(
                        precision: precision,
                        perceptualPrecision: perceptualPrecision,
                        scale: scale,
                        compressionQuality: compressionQuality
                    )
            )
        }
    }

    private let imageContextColorSpace = CGColorSpace(name: CGColorSpace.sRGB)
    private let imageContextBitsPerComponent = 8
    private let imageContextBytesPerPixel = 4

    private func compareWebP(
        _ old: UIImage,
        _ new: UIImage,
        precision: Float,
        perceptualPrecision: Float,
        compressionQuality: CompressionQuality
    ) -> String? {
        guard let oldCgImage = old.cgImage else {
            return "Reference image could not be loaded."
        }
        guard let newCgImage = new.cgImage else {
            return "Newly-taken snapshot could not be loaded."
        }
        guard newCgImage.width != 0, newCgImage.height != 0 else {
            return "Newly-taken snapshot is empty."
        }
        guard oldCgImage.width == newCgImage.width, oldCgImage.height == newCgImage.height else {
            return "Newly-taken snapshot@\(new.size) does not match reference@\(old.size)."
        }

        let pixelCount = oldCgImage.width * oldCgImage.height
        let byteCount = imageContextBytesPerPixel * pixelCount

        var oldBytes = [UInt8](repeating: 0, count: byteCount)
        guard let oldContext = context(for: oldCgImage, data: &oldBytes),
            let oldData = oldContext.data
        else {
            return "Reference image's data could not be loaded."
        }

        var newBytes = [UInt8](repeating: 0, count: byteCount)
        guard let newContext = context(for: newCgImage, data: &newBytes),
            let newData = newContext.data
        else {
            return "Newly-taken snapshot's data could not be loaded."
        }

        // Fast path: exact match
        if memcmp(oldData, newData, byteCount) == 0 { return nil }

        // For lossy compression, compare with re-encoded image
        let sourceBytes: [UInt8]
        let compareCgImage: CGImage

        if compressionQuality.rawValue < 1.0 {
            // Lossy: need to re-encode to account for compression artifacts
            guard let webpData = new.webpData(compressionQuality: compressionQuality.rawValue),
                let reencoded = UIImage(data: webpData)?.cgImage
            else {
                return "Newly-taken snapshot's data could not be loaded."
            }
            var reencodedBytes = [UInt8](repeating: 0, count: byteCount)
            guard let reencodedContext = context(for: reencoded, data: &reencodedBytes),
                let reencodedData = reencodedContext.data
            else {
                return "Newly-taken snapshot's data could not be loaded."
            }
            if memcmp(oldData, reencodedData, byteCount) == 0 { return nil }
            sourceBytes = reencodedBytes
            compareCgImage = reencoded
        } else {
            // Lossless: compare directly
            sourceBytes = newBytes
            compareCgImage = newCgImage
        }

        if precision >= 1, perceptualPrecision >= 1 {
            return "Newly-taken snapshot does not match reference."
        }

        // Perceptual comparison using Metal
        if perceptualPrecision < 1, #available(iOS 11.0, tvOS 11.0, *) {
            return perceptuallyCompare(
                CIImage(cgImage: oldCgImage),
                CIImage(cgImage: compareCgImage),
                pixelPrecision: precision,
                perceptualPrecision: perceptualPrecision
            )
        }

        // Pixel precision comparison with early exit
        let byteCountThreshold = Int((1 - precision) * Float(byteCount))
        var differentByteCount = 0

        for offset in 0 ..< byteCount {
            if oldBytes[offset] != sourceBytes[offset] {
                differentByteCount += 1
                if differentByteCount > byteCountThreshold {
                    let actualPrecision = 1 - Float(differentByteCount) / Float(byteCount)
                    return "Actual image precision \(actualPrecision) is less than required \(precision)"
                }
            }
        }

        return nil
    }

    private func context(for cgImage: CGImage, data: UnsafeMutableRawPointer? = nil) -> CGContext? {
        let bytesPerRow = cgImage.width * imageContextBytesPerPixel
        guard
            let colorSpace = imageContextColorSpace,
            let context = CGContext(
                data: data,
                width: cgImage.width,
                height: cgImage.height,
                bitsPerComponent: imageContextBitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        return context
    }

    private func diffImage(_ old: UIImage, _ new: UIImage) -> UIImage {
        let width = max(old.size.width, new.size.width)
        let height = max(old.size.height, new.size.height)
        let scale = max(old.scale, new.scale)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, scale)
        new.draw(at: .zero)
        old.draw(at: .zero, blendMode: .difference, alpha: 1)
        let differenceImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return differenceImage
    }
#endif

#if os(iOS) || os(tvOS) || os(macOS)
    import CoreImage.CIKernel
    import MetalPerformanceShaders

    @available(iOS 10.0, tvOS 10.0, macOS 10.13, *)
    func perceptuallyCompare(_ old: CIImage, _ new: CIImage, pixelPrecision: Float, perceptualPrecision: Float)
        -> String?
    {
        let deltaOutputImage = old.applyingFilter("CILabDeltaE", parameters: ["inputImage2": new])
        let thresholdOutputImage: CIImage
        do {
            thresholdOutputImage = try ThresholdImageProcessorKernel.apply(
                withExtent: new.extent,
                inputs: [deltaOutputImage],
                arguments: [ThresholdImageProcessorKernel.inputThresholdKey: (1 - perceptualPrecision) * 100]
            )
        } catch {
            return "Newly-taken snapshot's data could not be loaded. \(error)"
        }
        var averagePixel: Float = 0
        let context = CIContext(options: [.workingColorSpace: NSNull(), .outputColorSpace: NSNull()])
        context.render(
            thresholdOutputImage.applyingFilter("CIAreaAverage", parameters: [kCIInputExtentKey: new.extent]),
            toBitmap: &averagePixel,
            rowBytes: MemoryLayout<Float>.size,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .Rf,
            colorSpace: nil
        )
        let actualPixelPrecision = 1 - averagePixel
        guard actualPixelPrecision < pixelPrecision else { return nil }
        var maximumDeltaE: Float = 0
        context.render(
            deltaOutputImage.applyingFilter("CIAreaMaximum", parameters: [kCIInputExtentKey: new.extent]),
            toBitmap: &maximumDeltaE,
            rowBytes: MemoryLayout<Float>.size,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .Rf,
            colorSpace: nil
        )
        let actualPerceptualPrecision = 1 - maximumDeltaE / 100
        if pixelPrecision < 1 {
            return """
                Actual image precision \(actualPixelPrecision) is less than required \(pixelPrecision)
                Actual perceptual precision \(actualPerceptualPrecision) is less than required \(perceptualPrecision)
                """
        } else {
            return
                "Actual perceptual precision \(actualPerceptualPrecision) is less than required \(perceptualPrecision)"
        }
    }

    @available(iOS 10.0, tvOS 10.0, macOS 10.13, *)
    final class ThresholdImageProcessorKernel: CIImageProcessorKernel {
        static let inputThresholdKey = "thresholdValue"
        static let device = MTLCreateSystemDefaultDevice()

        override class func process(
            with inputs: [CIImageProcessorInput]?,
            arguments: [String: Any]?,
            output: CIImageProcessorOutput
        ) throws {
            guard
                let device = device,
                let commandBuffer = output.metalCommandBuffer,
                let input = inputs?.first,
                let sourceTexture = input.metalTexture,
                let destinationTexture = output.metalTexture,
                let thresholdValue = arguments?[inputThresholdKey] as? Float
            else {
                return
            }

            let threshold = MPSImageThresholdBinary(
                device: device,
                thresholdValue: thresholdValue,
                maximumValue: 1.0,
                linearGrayColorTransform: nil
            )

            threshold.encode(
                commandBuffer: commandBuffer,
                sourceTexture: sourceTexture,
                destinationTexture: destinationTexture
            )
        }
    }
#endif

#if os(macOS)
    import AppKit
    typealias Image = NSImage
    typealias View = NSView
#elseif os(iOS) || os(tvOS)
    typealias Image = UIImage
    typealias View = UIView
#endif

#if os(iOS) || os(tvOS)
    extension View {
        func asImage() -> Image {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        }
    }
#endif
