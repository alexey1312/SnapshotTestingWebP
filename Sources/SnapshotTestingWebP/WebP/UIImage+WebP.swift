#if os(iOS) || os(tvOS)
    import UIKit

    extension UIImage {
        func webpData(compressionQuality: CGFloat) -> Data? {
            guard let cgImage = cgImage else { return nil }
            return WebPEncoder.encode(cgImage, compressionQuality: compressionQuality)
        }
    }
#endif
