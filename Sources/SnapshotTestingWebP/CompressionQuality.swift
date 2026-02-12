import Foundation

/// Defines the WebP compression quality level for snapshot encoding.
///
/// Each level maps to a `CGFloat` in the range `0.0...1.0`, where `1.0` means
/// lossless (pixel-perfect) and `0.0` means maximum lossy compression.
///
/// ## Recommended precision thresholds
///
/// When using lossy compression, pixel data changes during encoding. Use the
/// `precision` and `perceptualPrecision` parameters in snapshot strategies to
/// account for this. Recommended values per quality level:
///
/// | Quality     | rawValue | precision | perceptualPrecision | Notes                        |
/// |-------------|----------|-----------|---------------------|------------------------------|
/// | `.lossless` | 1.0      | 1.0       | 1.0                 | Pixel-perfect, no tolerance  |
/// | `.low`      | 0.8      | 0.95      | 0.98                | Minor artifacts              |
/// | `.medium`   | 0.5      | 0.90      | 0.95                | Visible compression          |
/// | `.high`     | 0.2      | 0.85      | 0.90                | Heavy compression            |
/// | `.maximum`  | 0.0      | 0.80      | 0.85                | Maximum compression          |
///
/// - `precision`: Fraction of bytes that must match exactly (0.0–1.0).
///   At 0.95, up to 5% of pixel bytes may differ.
/// - `perceptualPrecision`: Human-perceptual similarity threshold (0.0–1.0),
///   based on CIE Lab Delta E. At 0.98, colors within Delta E ~2 are accepted
///   (Delta E 2.3 is the "just noticeable difference").
public enum CompressionQuality: Hashable, RawRepresentable {
    /// Lossless encoding (rawValue: 1.0). Pixel-perfect output.
    case lossless
    /// Low compression (rawValue: 0.8). Minimal quality loss.
    case low
    /// Medium compression (rawValue: 0.5). Good size/quality balance.
    case medium
    /// High compression (rawValue: 0.2). Significant size reduction.
    case high
    /// Maximum compression (rawValue: 0.0). Smallest file size.
    case maximum
    /// Custom quality value. Clamped to 0.0...1.0 range.
    case custom(CGFloat)

    public init?(rawValue: CGFloat) {
        switch rawValue {
        case 1.0:
            self = .lossless
        case 0.8:
            self = .low
        case 0.5:
            self = .medium
        case 0.2:
            self = .high
        case 0.0:
            self = .maximum
        default:
            self = .custom(min(max(rawValue, 0), 1))
        }
    }

    public var rawValue: CGFloat {
        switch self {
        case .lossless:
            return 1.0
        case .low:
            return 0.8
        case .medium:
            return 0.5
        case .high:
            return 0.2
        case .maximum:
            return 0.0
        case let .custom(value):
            return min(max(value, 0), 1)
        }
    }
}
