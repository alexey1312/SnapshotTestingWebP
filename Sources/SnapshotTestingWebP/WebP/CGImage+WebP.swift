import Foundation
import CoreGraphics
import libwebp

extension CGImage {
    func webpData(quality: Float) -> Data? {
        let pixelStart = CFAbsoluteTimeGetCurrent()
        guard let (pixelData, extractedBytesPerRow) = extractPixelData() else { return nil }
        defer { pixelData.deallocate() }
        let pixelDuration = CFAbsoluteTimeGetCurrent() - pixelStart

        let originalSize = height * extractedBytesPerRow
        let encodeStart = CFAbsoluteTimeGetCurrent()

        guard let data = encodeWebP(
            pixelData: pixelData,
            width: width,
            height: height,
            bytesPerRow: extractedBytesPerRow,
            quality: quality
        ) else { return nil }

        let encodeDuration = CFAbsoluteTimeGetCurrent() - encodeStart
        WebPEncodingStatistics.last = WebPEncodingStatistics(
            originalSize: originalSize,
            encodedSize: data.count,
            pixelExtractionDuration: pixelDuration,
            webpEncodingDuration: encodeDuration
        )

        return data
    }

    /// Returns pixel data and the bytes-per-row used.
    /// Fast path: if the CGImage is already 32-bit RGBA, copies pixels directly from the data provider.
    /// Fallback: renders through CGContext (handles color space conversion, non-RGBA formats, etc.).
    private func extractPixelData() -> (UnsafeMutablePointer<UInt8>, Int)? {
        // Fast path: direct provider access for compatible RGBA images
        if bitsPerPixel == 32,
           bitsPerComponent == 8,
           let colorSpace = colorSpace,
           colorSpace.model == .rgb,
           alphaInfo == .premultipliedLast || alphaInfo == .last || alphaInfo == .noneSkipLast,
           let provider = dataProvider,
           let data = provider.data {
            let length = CFDataGetLength(data)
            let expectedLength = height * bytesPerRow
            if length >= expectedLength {
                let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: expectedLength)
                CFDataGetBytes(data, CFRange(location: 0, length: expectedLength), ptr)
                return (ptr, bytesPerRow)
            }
        }

        // Fallback: CGContext rendering
        let targetBytesPerRow = 4 * width
        let pixelDataSize = height * targetBytesPerRow

        let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: pixelDataSize)

        guard
            let context = CGContext(
                data: pixelData,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: targetBytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else {
            pixelData.deallocate()
            return nil
        }

        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        return (pixelData, targetBytesPerRow)
    }

    private func encodeWebP(
        pixelData: UnsafeMutablePointer<UInt8>,
        width: Int,
        height: Int,
        bytesPerRow: Int,
        quality: Float
    ) -> Data? {
        var config = WebPConfig()

        if quality >= 1.0 {
            if WebPConfigPreset(&config, WEBP_PRESET_DEFAULT, 100) == 0 {
                return nil
            }
            config.lossless = 1
            config.exact = 1
            config.method = 2
            config.thread_level = 1
        } else {
            if WebPConfigPreset(&config, WEBP_PRESET_PICTURE, quality * 100) == 0 {
                return nil
            }
            config.method = 2
            config.thread_level = 1
            config.alpha_compression = 1
            config.alpha_filtering = 1
            config.alpha_quality = Int32(quality * 100)
            config.pass = 2
            config.preprocessing = 1
            config.use_sharp_yuv = 1
            config.autofilter = 1
            config.exact = 1
        }

        if WebPValidateConfig(&config) == 0 {
            return nil
        }

        var picture = WebPPicture()
        if WebPPictureInit(&picture) == 0 {
            return nil
        }
        defer { WebPPictureFree(&picture) }

        picture.width = Int32(width)
        picture.height = Int32(height)
        picture.use_argb = 1

        if WebPPictureImportRGBA(&picture, pixelData, Int32(bytesPerRow)) == 0 {
            return nil
        }

        var writer = WebPMemoryWriter()
        WebPMemoryWriterInit(&writer)
        defer { WebPMemoryWriterClear(&writer) }

        picture.writer = WebPMemoryWrite
        picture.custom_ptr = withUnsafeMutablePointer(to: &writer) { UnsafeMutableRawPointer($0) }

        let success = WebPEncode(&config, &picture)
        guard success != 0 else {
            return nil
        }

        return Data(bytes: writer.mem, count: writer.size)
    }
}
