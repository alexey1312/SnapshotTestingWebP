import Foundation
import CoreGraphics
import libwebp

extension CGImage {
    func webpData(quality: Float) -> Data? {
        guard let pixelData = extractPixelData() else { return nil }
        defer { pixelData.deallocate() }

        let bytesPerRow = 4 * width
        let originalSize = height * bytesPerRow
        let startTime = CFAbsoluteTimeGetCurrent()

        guard let data = encodeWebP(
            pixelData: pixelData,
            width: width,
            height: height,
            bytesPerRow: bytesPerRow,
            quality: quality
        ) else { return nil }

        let duration = CFAbsoluteTimeGetCurrent() - startTime
        WebPEncodingStatistics.last = WebPEncodingStatistics(
            originalSize: originalSize,
            encodedSize: data.count,
            encodingDuration: duration
        )

        return data
    }

    private func extractPixelData() -> UnsafeMutablePointer<UInt8>? {
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let pixelDataSize = height * bytesPerRow

        let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: pixelDataSize)

        guard
            let context = CGContext(
                data: pixelData,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else {
            pixelData.deallocate()
            return nil
        }

        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixelData
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
            config.method = 0
            config.thread_level = 1
        } else {
            if WebPConfigPreset(&config, WEBP_PRESET_PICTURE, quality * 100) == 0 {
                return nil
            }
            config.method = 0
            config.thread_level = 1
            config.alpha_compression = 1
            config.alpha_filtering = 1
            config.alpha_quality = Int32(quality * 100)
            config.pass = 1
            config.preprocessing = 0
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
