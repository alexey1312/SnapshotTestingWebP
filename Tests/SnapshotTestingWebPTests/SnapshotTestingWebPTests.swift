import XCTest
import SnapshotTesting
import SwiftUI

@testable import SnapshotTestingWebP

final class SnapshotTestingWebPTests: XCTestCase {

#if os(iOS) || os(tvOS)
    override func setUp() {
        super.setUp()
    }

    @available(iOS 15.0, tvOS 15.0, *)
    func test_WebP() {
        let view: some SwiftUI.View = SwiftUIView()

        assertSnapshot(of: view, as: .imageWebP(precision: 0.98, layout: .device(config: .iPhone13)))
    }

    @available(iOS 15.0, tvOS 15.0, *)
    func test_WebP_landscape() {
        let view: some SwiftUI.View = SwiftUIView()

        assertSnapshot(of: view, as: .imageWebP(layout: .device(config: .iPhone13(.landscape))))
    }

    @available(iOS 15.0, tvOS 15.0, *)
    func test_WebP_custom_quality() {
        let view: some SwiftUI.View = SwiftUIView()

        assertSnapshot(
            of: view,
            as: .imageWebP(
                precision: 0.9,
                layout: .device(config: .iPhone13),
                compressionQuality: .custom(0.1)
            )
        )
    }

    @available(iOS 15.0, tvOS 15.0, *)
    func test_WebP_maximum_quality() {
        let view: some SwiftUI.View = SwiftUIView()

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
    func test_WebP_high_quality() {
        let view: some SwiftUI.View = SwiftUIView()

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
    func test_WebP_medium_quality() {
        let view: some SwiftUI.View = SwiftUIView()

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
    func test_WebP_low_quality() {
        let view: some SwiftUI.View = SwiftUIView()

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
    func test_PNG() {
        let view: some SwiftUI.View = SwiftUIView()

        assertSnapshot(of: view, as: .image(precision: 0.9, layout: .device(config: .iPhone13)))
    }

    @available(iOS 15.0, tvOS 15.0, *)
    func test_PNG_landscape() {
        let view: some SwiftUI.View = SwiftUIView()

        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13(.landscape))))
    }
#endif

#if os(macOS)
    func test_WebP_NSView() {
        let view = NSView()
        let button = NSButton()

        view.frame = CGRect(origin: .zero, size: CGSize(width: 400, height: 400))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.blue.cgColor
        view.addSubview(button)
        button.frame.origin = CGPoint(x: view.frame.origin.x + view.frame.size.width / 2.0,
                                      y: view.frame.origin.y + view.frame.size.height / 2.0)
        button.bezelStyle = .rounded
        button.title = "Push Me"
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor.red.cgColor
        button.sizeToFit()

        assertSnapshot(of: view, as: .imageWebP)
    }
#endif

}
