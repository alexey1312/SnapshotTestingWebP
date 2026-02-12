# SnapshotTestingWebP

[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Falexey1312%2FSnapshotTestingWebP%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/alexey1312/SnapshotTestingWebP)
[![Swift-versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Falexey1312%2FSnapshotTestingWebP%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/alexey1312/SnapshotTestingWebP)
[![CI](https://github.com/alexey1312/SnapshotTestingWebP/actions/workflows/ci.yml/badge.svg)](https://github.com/alexey1312/SnapshotTestingWebP/actions/workflows/ci.yml)
[![Release](https://github.com/alexey1312/SnapshotTestingWebP/actions/workflows/release.yml/badge.svg)](https://github.com/alexey1312/SnapshotTestingWebP/actions/workflows/release.yml)
[![License](https://img.shields.io/github/license/alexey1312/SnapshotTestingWebP.svg)](LICENSE)

> ⚠️ **Experimental**: This library is currently in experimental development stage. API may change.

A Swift Package Manager library that extends [PointFree's SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) framework to support **WebP** image format for snapshot tests.

WebP provides excellent compression with high image quality, resulting in significantly smaller snapshot files while maintaining the same testing capabilities as PNG snapshots.

## File Size Comparison

Real-world comparison using a complex SwiftUI dashboard (iPhone 13, portrait) with gradients, shadows, cards, and text:

| Format | Size | Reduction |
|--------|------|-----------|
| PNG | 224 KB | baseline |
| WebP Lossless | 212 KB | **5% smaller** |
| WebP Medium | 66 KB | **71% smaller** |
| WebP Maximum | 27 KB | **88% smaller** |

> Lossless WebP savings depend heavily on image content — gradient-heavy UIs compress similarly to PNG.
> Lossy WebP consistently delivers **70–90% savings** with acceptable visual quality.
> These results can be verified in the package's test snapshots directory.

## Features

- **WebP Snapshot Testing** - Full support for WebP format in snapshot tests
- **Advanced Compression** - Multiple compression quality levels from lossless to maximum compression
- **Hardware-Accelerated** - Optimized encoding with vImage framework (~75-80% faster)
- **Cross-Platform** - iOS 13+, macOS 10.15+, tvOS 13+ support
- **Drop-in Replacement** - Easy migration from PNG snapshots
- **Complete UI Coverage** - UIView, UIViewController, NSView, NSViewController, SwiftUI support
- **Perceptual Comparison** - Hardware-accelerated diffing with Metal Performance Shaders

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/alexey1312/SnapshotTestingWebP.git", from: "1.0.0")
]
```

Or add it through Xcode: **File > Add Packages...** and enter the repository URL.

## Quick Start

```swift
import XCTest
import SnapshotTesting
import SnapshotTestingWebP

class MyViewTests: XCTestCase {
    func testMyView() {
        let view = MyView()

        // WebP snapshot with lossless compression (default)
        assertSnapshot(of: view, as: .imageWebP)

        // WebP with custom compression quality
        assertSnapshot(of: view, as: .imageWebP(compressionQuality: .medium))
    }
}
```

## Compression Quality Options

The library provides several compression quality presets:

| Quality | Raw Value | Description |
|---------|-----------|-------------|
| `.lossless` | 1.0 | Perfect quality, larger file size |
| `.low` | 0.8 | 80% quality, good balance |
| `.medium` | 0.5 | 50% quality, recommended for most cases |
| `.high` | 0.2 | 20% quality, smaller files |
| `.maximum` | 0.0 | Smallest file size |
| `.custom(CGFloat)` | 0.0 - 1.0 | Custom quality value |

### Usage Examples

```swift
// Lossless compression (default) - pixel-perfect accuracy
assertSnapshot(of: view, as: .imageWebP(compressionQuality: .lossless))

// Medium compression - balanced size/quality
assertSnapshot(of: view, as: .imageWebP(compressionQuality: .medium))

// Custom compression level
assertSnapshot(of: view, as: .imageWebP(compressionQuality: .custom(0.75)))
```

## Supported Types

### UIKit (iOS/tvOS)

```swift
// UIView snapshots
assertSnapshot(of: myView, as: .imageWebP)
assertSnapshot(of: myView, as: .imageWebP(compressionQuality: .medium))

// UIViewController snapshots with device configuration
assertSnapshot(of: myViewController, as: .imageWebP(on: .iPhone13))
assertSnapshot(of: myViewController, as: .imageWebP(on: .iPadPro11))
```

### AppKit (macOS)

```swift
// NSView snapshots
assertSnapshot(of: myNSView, as: .imageWebP)

// NSViewController snapshots
assertSnapshot(of: myNSViewController, as: .imageWebP)
```

### SwiftUI

```swift
// Size that fits content
assertSnapshot(of: MySwiftUIView(), as: .imageWebP(layout: .sizeThatFits))

// Device-specific layout
assertSnapshot(of: MySwiftUIView(), as: .imageWebP(layout: .device(config: .iPhone13)))

// Fixed size layout
assertSnapshot(of: MySwiftUIView(), as: .imageWebP(layout: .fixed(width: 300, height: 200)))
```

## Advanced Configuration

### Precision Control

For lossy compression, you may need to adjust precision thresholds:

```swift
assertSnapshot(
    of: view,
    as: .imageWebP(
        precision: 0.98,           // 98% pixel match required
        perceptualPrecision: 0.99, // 99% perceptual precision
        compressionQuality: .medium
    )
)
```

### Scale Configuration

```swift
// Custom scale factor
assertSnapshot(
    of: view,
    as: .imageWebP(scale: 2.0, compressionQuality: .lossless)
)
```

## Performance

WebP encoding in this library is highly optimized:

- **Hardware-accelerated preprocessing** using vImage framework
- **Advanced libwebp configuration** with optimized presets
- **Multi-threaded encoding** for improved performance
- **Smart image scaling** with optimal dimension limits

**Benchmark Results:**

| Metric | Basic libwebp | SnapshotTestingWebP |
|--------|---------------|---------------------|
| Encoding time (400x300) | ~0.3s | ~0.08s |
| Performance improvement | baseline | **~75-80% faster** |

## Migration from PNG

Replace your existing PNG snapshots with a simple change:

```swift
// Before (PNG)
assertSnapshot(of: view, as: .image)

// After (WebP)
assertSnapshot(of: view, as: .imageWebP)
```

The API is designed to be a drop-in replacement for existing snapshot strategies.

## Requirements

- **iOS 13.0+** / **macOS 10.15+** / **tvOS 13.0+**
- **Swift 5.2+**
- **Xcode 11.0+**

## Dependencies

- [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) (1.18.6+)
- [libwebp](https://github.com/the-swift-collective/libwebp) (1.4.1+)

## Related Projects

- [SnapshotTestingHEIC](https://github.com/alexey1312/SnapshotTestingHEIC) - HEIC format support for snapshot testing
- [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) - The original snapshot testing framework

## License

This library is released under the MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
