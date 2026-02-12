import Foundation

/// Statistics collected during WebP encoding.
///
/// After each call to `webpData()`, the most recent statistics are available
/// via ``WebPEncodingStatistics/last``.
public struct WebPEncodingStatistics: Sendable {
    /// Raw pixel data size in bytes (width * height * 4).
    public let originalSize: Int
    /// Encoded WebP data size in bytes.
    public let encodedSize: Int
    /// Time spent encoding, in seconds.
    public let encodingDuration: TimeInterval

    /// Ratio of original size to encoded size (e.g. 10.0 means 10x smaller).
    public var compressionRatio: Double {
        guard originalSize > 0 else { return 0 }
        return Double(originalSize) / Double(encodedSize)
    }

    /// Fraction of space saved (e.g. 0.9 means 90% reduction).
    public var spaceSavings: Double {
        guard originalSize > 0 else { return 0 }
        return 1.0 - Double(encodedSize) / Double(originalSize)
    }

    /// Statistics from the most recent WebP encoding operation.
    public nonisolated(unsafe) static var last: WebPEncodingStatistics?
}
