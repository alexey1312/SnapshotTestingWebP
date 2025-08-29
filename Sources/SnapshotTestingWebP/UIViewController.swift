#if os(iOS) || os(tvOS)
import UIKit
@testable import SnapshotTesting

public extension Snapshotting where Value == UIViewController, Format == UIImage {
    static var imageWebP: Snapshotting {
        return .imageWebP()
    }

    static func imageWebP(
        on config: ViewImageConfig,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        size: CGSize? = nil,
        traits: UITraitCollection = .init(),
        compressionQuality: CompressionQuality = .lossless
    )
    -> Snapshotting {
        return SimplySnapshotting.imageWebP(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            scale: traits.displayScale,
            compressionQuality: compressionQuality
        ).asyncPullback { viewController in
            snapshotView(
                config: size.map { .init(safeArea: config.safeArea, size: $0, traits: config.traits) } ?? config,
                drawHierarchyInKeyWindow: false,
                traits: traits,
                view: viewController.view,
                viewController: viewController
            )
        }
    }

    static func imageWebP(
        drawHierarchyInKeyWindow: Bool = false,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        size: CGSize? = nil,
        traits: UITraitCollection = .init(),
        compressionQuality: CompressionQuality = .lossless
    )
    -> Snapshotting {
        return SimplySnapshotting.imageWebP(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            scale: traits.displayScale,
            compressionQuality: compressionQuality
        ).asyncPullback { viewController in
            snapshotView(
                config: .init(safeArea: .zero, size: size, traits: traits),
                drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
                traits: traits,
                view: viewController.view,
                viewController: viewController
            )
        }
    }
}
#endif
