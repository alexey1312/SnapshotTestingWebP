import Foundation

/// WebP compression quality levels for snapshot testing.
///
/// Each level maps to a libwebp quality value (0.0–1.0 range, internally scaled to 0–100).
///
/// Recommended `precision` / `perceptualPrecision` values per level:
/// - `.lossless` (1.0): precision 0.99–1.0, perceptualPrecision 1.0
/// - `.low` (0.8): precision 0.95–0.98, perceptualPrecision 0.98
/// - `.medium` (0.5): precision 0.90–0.95, perceptualPrecision 0.95
/// - `.high` (0.2): precision 0.85–0.92, perceptualPrecision 0.90
/// - `.maximum` (0.0): precision 0.80–0.90, perceptualPrecision 0.85
///
/// Values outside 0.0–1.0 in `.custom()` are clamped automatically.
public enum CompressionQuality: Hashable, RawRepresentable {
    /// Lossless WebP encoding (rawValue: 1.0). Pixel-perfect output.
    case lossless
    /// Low compression (rawValue: 0.8). Minimal visual artifacts.
    case low
    /// Medium compression (rawValue: 0.5). Balanced quality/size trade-off.
    case medium
    /// High compression (rawValue: 0.2). Noticeable artifacts on close inspection.
    case high
    /// Maximum compression (rawValue: 0.0). Smallest file size, most artifacts.
    case maximum
    /// Custom quality value. Clamped to 0.0–1.0 range.
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
