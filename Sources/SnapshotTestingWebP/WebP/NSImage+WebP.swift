#if os(macOS)
import AppKit
import libwebp
import Accelerate

extension NSImage {
    func webpData(compressionQuality: CGFloat) -> Data? {
        guard let tiffData = self.tiffRepresentation,
              let bitmapImageRep = NSBitmapImageRep(data: tiffData),
              let cgImage = bitmapImageRep.cgImage else { return nil }

        let processedImage = preprocessImageForWebP(cgImage)
        let width = processedImage.width
        let height = processedImage.height

        guard let pixelData = extractPixelDataWithVImage(from: processedImage) else {
            return nil
        }
        defer { pixelData.deallocate() }

        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width

        let qualityValue = Float(min(max(compressionQuality, 0), 1))

        return encodeWebPWithAdvancedAPI(
            pixelData: pixelData,
            width: width,
            height: height,
            bytesPerRow: bytesPerRow,
            quality: qualityValue
        )
    }

    private func preprocessImageForWebP(_ cgImage: CGImage) -> CGImage {
        let width = cgImage.width
        let height = cgImage.height

        return scaleImageWithVImage(cgImage, newWidth: width, newHeight: height) ?? cgImage
    }

    private func scaleImageWithVImage(_ cgImage: CGImage, newWidth: Int, newHeight: Int) -> CGImage? {
        let bytesPerPixel = 4
        let originalBytesPerRow = cgImage.width * bytesPerPixel
        let scaledBytesPerRow = newWidth * bytesPerPixel

        let originalData = UnsafeMutablePointer<UInt8>.allocate(capacity: cgImage.height * originalBytesPerRow)
        defer { originalData.deallocate() }

        let scaledData = UnsafeMutablePointer<UInt8>.allocate(capacity: newHeight * scaledBytesPerRow)
        defer { scaledData.deallocate() }

        guard let context = CGContext(
            data: originalData,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: 8,
            bytesPerRow: originalBytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))

        var sourceBuffer = vImage_Buffer(
            data: originalData,
            height: vImagePixelCount(cgImage.height),
            width: vImagePixelCount(cgImage.width),
            rowBytes: originalBytesPerRow
        )

        var destBuffer = vImage_Buffer(
            data: scaledData,
            height: vImagePixelCount(newHeight),
            width: vImagePixelCount(newWidth),
            rowBytes: scaledBytesPerRow
        )

        let error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, vImage_Flags(kvImageHighQualityResampling))
        guard error == kvImageNoError else {
            return nil
        }

        return CGContext(
            data: scaledData,
            width: newWidth,
            height: newHeight,
            bitsPerComponent: 8,
            bytesPerRow: scaledBytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )?.makeImage()
    }

    private func extractPixelDataWithVImage(from cgImage: CGImage) -> UnsafeMutablePointer<UInt8>? {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let pixelDataSize = height * bytesPerRow

        let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: pixelDataSize)

        guard let context = CGContext(
            data: pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            pixelData.deallocate()
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixelData
    }

    private func encodeWebPWithAdvancedAPI(
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
        } else {
            if WebPConfigPreset(&config, WEBP_PRESET_PICTURE, quality * 100) == 0 {
                return nil
            }
            config.method = 0
            config.target_size = 0
            config.target_PSNR = 0
            config.segments = 1
            config.sns_strength = 25
            config.filter_strength = 20
            config.filter_sharpness = 3
            config.filter_type = 0
            config.autofilter = 0
            config.alpha_compression = 1
            config.alpha_filtering = 2
            config.alpha_quality = Int32(quality * 100)
            config.pass = 1
            config.show_compressed = 0
            config.preprocessing = 0
            config.partitions = 0
            config.partition_limit = 0
            config.emulate_jpeg_size = 0
            config.thread_level = 0
            config.low_memory = 0
            config.near_lossless = 100
            config.exact = 1
            config.use_delta_palette = 0
            config.use_sharp_yuv = 0
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
