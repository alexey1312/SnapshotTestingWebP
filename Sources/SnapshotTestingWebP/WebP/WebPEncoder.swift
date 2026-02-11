#if os(iOS) || os(tvOS) || os(macOS)
    import CoreGraphics
    import Foundation
    import libwebp

    /// Statistics collected during a WebP encoding operation.
    public struct WebPEncodingStatistics: Sendable {
        /// Raw pixel data size in bytes (width * height * 4).
        public let originalSize: Int
        /// Encoded WebP data size in bytes.
        public let encodedSize: Int
        /// Time spent encoding, in seconds.
        public let encodingDuration: TimeInterval
        /// Compression ratio (originalSize / encodedSize). Higher means more compression.
        public var compressionRatio: Double {
            guard encodedSize > 0 else { return 0 }
            return Double(originalSize) / Double(encodedSize)
        }
        /// Space savings as a percentage (0.0–1.0). E.g., 0.82 means 82% smaller.
        public var spaceSavings: Double {
            guard originalSize > 0 else { return 0 }
            return 1.0 - Double(encodedSize) / Double(originalSize)
        }
    }

    enum WebPEncoder {
        /// The statistics from the most recent encoding operation.
        /// Thread-safe via `NSLock`.
        static var lastStatistics: WebPEncodingStatistics? {
            get { lock.lock(); defer { lock.unlock() }; return _lastStatistics }
            set { lock.lock(); defer { lock.unlock() }; _lastStatistics = newValue }
        }

        private static var _lastStatistics: WebPEncodingStatistics?
        private static let lock = NSLock()

        /// Encodes a `CGImage` to WebP data at the given compression quality.
        ///
        /// - Parameters:
        ///   - cgImage: The source image.
        ///   - compressionQuality: Value in 0.0...1.0 (clamped). 1.0 = lossless.
        /// - Returns: Encoded WebP `Data`, or `nil` on failure.
        static func encode(_ cgImage: CGImage, compressionQuality: CGFloat) -> Data? {
            let width = cgImage.width
            let height = cgImage.height
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * width

            guard let pixelData = extractPixelData(from: cgImage) else {
                return nil
            }
            defer { pixelData.deallocate() }

            let qualityValue = Float(min(max(compressionQuality, 0), 1))
            let originalSize = width * height * bytesPerPixel
            let start = CFAbsoluteTimeGetCurrent()

            guard let data = encodeWebP(
                pixelData: pixelData,
                width: width,
                height: height,
                bytesPerRow: bytesPerRow,
                quality: qualityValue
            ) else {
                return nil
            }

            let duration = CFAbsoluteTimeGetCurrent() - start
            lastStatistics = WebPEncodingStatistics(
                originalSize: originalSize,
                encodedSize: data.count,
                encodingDuration: duration
            )

            return data
        }

        // MARK: - Private

        private static func extractPixelData(from cgImage: CGImage) -> UnsafeMutablePointer<UInt8>? {
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

        private static func encodeWebP(
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
