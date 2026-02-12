#if os(iOS) || os(tvOS)
    import UIKit

    extension UIImage {
        func webpData(compressionQuality: CGFloat) -> Data? {
            guard let cgImage = cgImage else { return nil }
            let quality = Float(min(max(compressionQuality, 0), 1))
            return cgImage.webpData(quality: quality)
        }
    }
#endif
