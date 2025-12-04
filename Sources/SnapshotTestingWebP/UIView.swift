#if os(iOS) || os(tvOS)
    import UIKit
    @testable import SnapshotTesting

    public extension Snapshotting where Value == UIView, Format == UIImage {
        static var imageWebP: Snapshotting {
            return .imageWebP()
        }

        static func imageWebP(
            drawHierarchyInKeyWindow: Bool = false,
            precision: Float = 1,
            perceptualPrecision: Float = 1,
            size: CGSize? = nil,
            traits: UITraitCollection = .init(),
            compressionQuality: CompressionQuality = .lossless
        )
            -> Snapshotting
        {
            return SimplySnapshotting.imageWebP(
                precision: precision,
                perceptualPrecision: perceptualPrecision,
                scale: traits.displayScale,
                compressionQuality: compressionQuality
            ).asyncPullback { view in
                snapshotView(
                    config: .init(safeArea: .zero, size: size ?? view.frame.size, traits: .init()),
                    drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
                    traits: traits,
                    view: view,
                    viewController: .init()
                )
            }
        }
    }
#endif
