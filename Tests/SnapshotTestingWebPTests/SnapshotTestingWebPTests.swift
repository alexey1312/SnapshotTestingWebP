import XCTest
import SnapshotTesting

@testable import SnapshotTestingWebP

// MARK: - CompressionQuality Tests

final class CompressionQualityTests: XCTestCase {

    func test_CompressionQuality_rawValues() {
        XCTAssertEqual(CompressionQuality.lossless.rawValue, 1.0)
        XCTAssertEqual(CompressionQuality.low.rawValue, 0.8)
        XCTAssertEqual(CompressionQuality.medium.rawValue, 0.5)
        XCTAssertEqual(CompressionQuality.high.rawValue, 0.2)
        XCTAssertEqual(CompressionQuality.maximum.rawValue, 0.0)
        XCTAssertEqual(CompressionQuality.custom(0.75).rawValue, 0.75)
    }

    func test_CompressionQuality_initFromRawValue() {
        XCTAssertEqual(CompressionQuality(rawValue: 1.0), .lossless)
        XCTAssertEqual(CompressionQuality(rawValue: 0.8), .low)
        XCTAssertEqual(CompressionQuality(rawValue: 0.5), .medium)
        XCTAssertEqual(CompressionQuality(rawValue: 0.2), .high)
        XCTAssertEqual(CompressionQuality(rawValue: 0.0), .maximum)
        XCTAssertEqual(CompressionQuality(rawValue: 0.75), .custom(0.75))
    }

    func test_CompressionQuality_hashable() {
        let qualities: Set<CompressionQuality> = [
            .lossless,
            .low,
            .medium,
            .high,
            .maximum,
            .custom(0.75),
        ]
        XCTAssertEqual(qualities.count, 6)
        XCTAssertTrue(qualities.contains(.lossless))
        XCTAssertTrue(qualities.contains(.custom(0.75)))
    }

    func test_CompressionQuality_equality() {
        XCTAssertEqual(CompressionQuality.lossless, CompressionQuality.lossless)
        XCTAssertEqual(CompressionQuality.custom(0.5), CompressionQuality.medium)
        XCTAssertNotEqual(CompressionQuality.low, CompressionQuality.high)
    }
}

// MARK: - iOS/tvOS Snapshot Tests

#if os(iOS) || os(tvOS)
    import SwiftUI

    final class SnapshotTestingWebPTests: XCTestCase {

        // MARK: - SwiftUI PNG Baseline Tests

        @available(iOS 15.0, tvOS 15.0, *)
        func test_SwiftUI_PNG() {
            let view = SwiftUIView()
            assertSnapshot(
                of: view,
                as: .image(precision: 0.9, layout: .device(config: .iPhone13))
            )
        }

        @available(iOS 15.0, tvOS 15.0, *)
        func test_SwiftUI_PNG_landscape() {
            let view = SwiftUIView()
            assertSnapshot(
                of: view,
                as: .image(layout: .device(config: .iPhone13(.landscape)))
            )
        }

        // MARK: - SwiftUI WebP Lossless Tests

        @available(iOS 15.0, tvOS 15.0, *)
        func test_SwiftUI_WebP_lossless() {
            let view = SwiftUIView()
            assertSnapshot(
                of: view,
                as: .imageWebP(
                    precision: 0.98,
                    layout: .device(config: .iPhone13),
                    compressionQuality: .lossless
                )
            )
        }

        @available(iOS 15.0, tvOS 15.0, *)
        func test_SwiftUI_WebP_lossless_landscape() {
            let view = SwiftUIView()
            assertSnapshot(
                of: view,
                as: .imageWebP(
                    layout: .device(config: .iPhone13(.landscape)),
                    compressionQuality: .lossless
                )
            )
        }

        // MARK: - SwiftUI WebP Compression Quality Tests

        @available(iOS 15.0, tvOS 15.0, *)
        func test_SwiftUI_WebP_low() {
            let view = SwiftUIView()
            assertSnapshot(
                of: view,
                as: .imageWebP(
                    precision: 0.9,
                    layout: .device(config: .iPhone13),
                    compressionQuality: .low
                )
            )
        }

        @available(iOS 15.0, tvOS 15.0, *)
        func test_SwiftUI_WebP_medium() {
            let view = SwiftUIView()
            assertSnapshot(
                of: view,
                as: .imageWebP(
                    precision: 0.9,
                    layout: .device(config: .iPhone13),
                    compressionQuality: .medium
                )
            )
        }

        @available(iOS 15.0, tvOS 15.0, *)
        func test_SwiftUI_WebP_high() {
            let view = SwiftUIView()
            assertSnapshot(
                of: view,
                as: .imageWebP(
                    precision: 0.9,
                    layout: .device(config: .iPhone13),
                    compressionQuality: .high
                )
            )
        }

        @available(iOS 15.0, tvOS 15.0, *)
        func test_SwiftUI_WebP_maximum() {
            let view = SwiftUIView()
            assertSnapshot(
                of: view,
                as: .imageWebP(
                    precision: 0.9,
                    layout: .device(config: .iPhone13),
                    compressionQuality: .maximum
                )
            )
        }

        @available(iOS 15.0, tvOS 15.0, *)
        func test_SwiftUI_WebP_custom() {
            let view = SwiftUIView()
            assertSnapshot(
                of: view,
                as: .imageWebP(
                    precision: 0.88,
                    layout: .device(config: .iPhone13),
                    compressionQuality: .custom(0.1)
                )
            )
        }
    }
#endif

// MARK: - macOS Snapshot Tests

#if os(macOS)
    import AppKit

    final class SnapshotTestingWebPTests: XCTestCase {

        // MARK: - NSView WebP Lossless Tests

        func test_NSView_WebP_lossless() {
            let view = createTestNSView()
            assertSnapshot(
                of: view,
                as: .imageWebP(
                    precision: 0.98,
                    compressionQuality: .lossless
                )
            )
        }

        // MARK: - NSView WebP Compression Quality Tests

        func test_NSView_WebP_low() {
            let view = createTestNSView()
            assertSnapshot(
                of: view,
                as: .imageWebP(
                    precision: 0.9,
                    compressionQuality: .low
                )
            )
        }

        func test_NSView_WebP_medium() {
            let view = createTestNSView()
            assertSnapshot(
                of: view,
                as: .imageWebP(
                    precision: 0.9,
                    compressionQuality: .medium
                )
            )
        }

        func test_NSView_WebP_high() {
            let view = createTestNSView()
            assertSnapshot(
                of: view,
                as: .imageWebP(
                    precision: 0.9,
                    compressionQuality: .high
                )
            )
        }

        func test_NSView_WebP_maximum() {
            let view = createTestNSView()
            assertSnapshot(
                of: view,
                as: .imageWebP(
                    precision: 0.9,
                    compressionQuality: .maximum
                )
            )
        }
    }
#endif
