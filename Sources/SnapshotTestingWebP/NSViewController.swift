#if os(macOS)
    import Cocoa
    @testable import SnapshotTesting

    public extension Snapshotting where Value == NSViewController, Format == NSImage {
        static var imageWebP: Snapshotting {
            return .imageWebP()
        }

        static func imageWebP(
            precision: Float = 1,
            perceptualPrecision: Float = 1,
            size: CGSize? = nil,
            compressionQuality: CompressionQuality = .lossless
        ) -> Snapshotting {
            return SimplySnapshotting.imageWebP(
                precision: precision,
                perceptualPrecision: perceptualPrecision,
                compressionQuality: compressionQuality
            ).asyncPullback { viewController in
                let view = viewController.view
                let initialSize = view.frame.size
                if let size = size { view.frame.size = size }
                guard view.frame.width > 0, view.frame.height > 0 else {
                    fatalError("View not renderable to image at size \(view.frame.size)")
                }
                return view.snapshot
                    ?? Async { callback in
                        addImagesForRenderedViews(view).sequence().run { views in
                            let bitmapRep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
                            view.cacheDisplay(in: view.bounds, to: bitmapRep)
                            // Use pixel size from bitmapRep for consistency with WebP loading
                            let imageSize = CGSize(width: bitmapRep.pixelsWide, height: bitmapRep.pixelsHigh)
                            let image = NSImage(size: imageSize)
                            image.addRepresentation(bitmapRep)
                            callback(image)
                            views.forEach { $0.removeFromSuperview() }
                            view.frame.size = initialSize
                        }
                    }
            }
        }
    }
#endif
