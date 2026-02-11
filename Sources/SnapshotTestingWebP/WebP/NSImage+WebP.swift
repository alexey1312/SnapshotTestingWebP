#if os(macOS)
    import AppKit

    extension NSImage {
        func webpData(compressionQuality: CGFloat) -> Data? {
            guard let tiffData = self.tiffRepresentation,
                let bitmapImageRep = NSBitmapImageRep(data: tiffData),
                let cgImage = bitmapImageRep.cgImage
            else { return nil }

            return WebPEncoder.encode(cgImage, compressionQuality: compressionQuality)
        }
    }
#endif
