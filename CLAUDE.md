# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SnapshotTestingWebP is a Swift Package Manager library that extends PointFree's SnapshotTesting framework to support WebP image format for snapshot tests. It provides hardware-accelerated WebP encoding with compression options for cross-platform iOS/macOS/tvOS testing.

## Development Commands

### Building

```bash
# Build for iOS Simulator (via build script)
Scripts/build.sh

# Standard Swift Package Manager build
swift build

# Build for specific platform
swift build -Xswiftc -sdk -Xswiftc "$(xcrun --sdk iphonesimulator --show-sdk-path)" -Xswiftc -target -Xswiftc "x86_64-apple-ios13.0-simulator"
```

### Testing

```bash
# Run all tests
swift test

# Run specific test
swift test --filter SnapshotTestingWebPTests.test_WebP_compressionQuality_lossless

# Run tests with test plan
swift test --testplan Tests/SnapshotTestingWebPTests/SnapshotTestingWebPTests.xctestplan
```

### Snapshot Management

- Snapshot files are stored in `Tests/SnapshotTestingWebPTests/__Snapshots__/`
- WebP snapshots use `.webp` file extension
- To regenerate snapshots, delete the existing files and run tests

## Architecture Overview

### Core Components

**CompressionQuality Enum** (`CompressionQuality.swift`)

- Defines WebP compression levels: `.lossless`, `.low`, `.medium`, `.high`, `.maximum`, `.custom(CGFloat)`
- Maps to libwebp quality values (0.0-1.0 range)

**WebP Encoding Engine** (`WebP/UIImage+WebP.swift`, `WebP/NSImage+WebP.swift`)

- Hardware-accelerated preprocessing using vImage framework
- Advanced libwebp API integration with optimized presets
- Multi-threaded encoding for ~75-80% performance improvement
- Smart image scaling with optimal dimension limits

**Snapshotting Strategy Extensions**

- `UIView.swift` - UIView snapshots for iOS/tvOS
- `UIViewController.swift` - UIViewController snapshots with device configurations
- `SwiftUIView.swift` - SwiftUI view snapshots with layout options
- `NSView.swift` - NSView snapshots for macOS
- `NSViewController.swift` - NSViewController snapshots for macOS

**Diffing & Comparison** (`UIImage.swift`)

- Pixel-perfect comparison for lossless snapshots
- Perceptual comparison using CILabDeltaE for compressed snapshots
- Hardware-accelerated diffing with Metal Performance Shaders
- Support for precision and perceptualPrecision thresholds

### Platform Architecture

**Conditional Compilation Strategy**

- `#if os(iOS) || os(tvOS)` - UIKit-based implementations
- `#if os(macOS)` - AppKit-based implementations
- `#if canImport(SwiftUI)` - SwiftUI support across platforms

**Integration Pattern**
The library extends SnapshotTesting's `Snapshotting` and `Diffing` types using the `SimplySnapshotting` pattern:

1. `.imageWebP` creates a `Snapshotting<Value, UIImage>` with `.webp` file extension
2. Uses custom `Diffing<UIImage>.imageWebP()` for WebP-aware comparison
3. Leverages existing SnapshotTesting infrastructure for view rendering

### Performance Optimizations

**vImage Integration**

- Hardware-accelerated image preprocessing
- Efficient pixel buffer management with proper memory cleanup
- Optimized color space conversions (premultiplied RGBA)

**libwebp Advanced API**

- Custom WebPConfig optimization per compression level
- Lossless mode with `exact=1` for pixel-perfect accuracy
- Lossy mode with optimized presets and advanced parameters
- Memory-managed encoding with WebPMemoryWriter

## Key Testing Patterns

### Compression Quality Testing

```swift
// Test different compression levels
assertSnapshot(of: view, as: .imageWebP(compressionQuality: .lossless))
assertSnapshot(of: view, as: .imageWebP(compressionQuality: .medium))
assertSnapshot(of: view, as: .imageWebP(compressionQuality: .custom(0.75)))
```

### SwiftUI Layout Testing

```swift
// Device-specific layouts
.imageWebP(layout: .device(config: .iPhone13))

// Fixed dimensions
.imageWebP(layout: .fixed(width: 300, height: 200))

// Content-sized
.imageWebP(layout: .sizeThatFits)
```

### Precision Control

```swift
// Custom precision thresholds
.imageWebP(precision: 0.98, perceptualPrecision: 0.99)
```

## Dependencies

- **swift-snapshot-testing** (1.18.6+): Core snapshot testing framework
- **libwebp** (1.4.1+): WebP encoding/decoding via swift-collective implementation

## Platform Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+
- Swift 5.2+
- Hardware acceleration via vImage (Accelerate framework)
- Metal Performance Shaders for perceptual comparison (iOS 10.0+/macOS 10.13+)