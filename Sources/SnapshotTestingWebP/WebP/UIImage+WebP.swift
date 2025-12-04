#if os(iOS) || os(tvOS)
    import UIKit
    import libwebp

    extension UIImage {
        func webpData(compressionQuality: CGFloat) -> Data? {
            guard let cgImage = cgImage else { return nil }

            let width = cgImage.width
            let height = cgImage.height
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * width

            guard let pixelData = extractPixelData(from: cgImage) else {
                return nil
            }
            defer { pixelData.deallocate() }

            let qualityValue = Float(min(max(compressionQuality, 0), 1))

            return encodeWebP(
                pixelData: pixelData,
                width: width,
                height: height,
                bytesPerRow: bytesPerRow,
                quality: qualityValue
            )
        }

        private func extractPixelData(from cgImage: CGImage) -> UnsafeMutablePointer<UInt8>? {
            let width = cgImage.width
            let height = cgImage.height
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

            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
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
#endif
