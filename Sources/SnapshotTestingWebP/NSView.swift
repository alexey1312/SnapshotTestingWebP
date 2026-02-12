#if os(macOS)
    import Cocoa
    @testable import SnapshotTesting

    public extension Snapshotting where Value == NSView, Format == NSImage {
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
            ).asyncPullback { view in
                let initialSize = view.frame.size
                if let size = size { view.frame.size = size }
                guard view.frame.width > 0, view.frame.height > 0 else {
                    fatalError("View not renderable to image at size \(view.frame.size)")
                }
                return view.snapshot
                    ?? Async { callback in
                        addImagesForRenderedViews(view).sequence().run { views in
                            // Use explicit 1x scale for consistent rendering across different displays
                            let width = Int(view.bounds.width)
                            let height = Int(view.bounds.height)
                            let bitmapRep = NSBitmapImageRep(
                                bitmapDataPlanes: nil,
                                pixelsWide: width,
                                pixelsHigh: height,
                                bitsPerSample: 8,
                                samplesPerPixel: 4,
                                hasAlpha: true,
                                isPlanar: false,
                                colorSpaceName: .calibratedRGB,
                                bytesPerRow: width * 4,
                                bitsPerPixel: 32
                            )!
                            bitmapRep.size = view.bounds.size

                            NSGraphicsContext.saveGraphicsState()
                            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
                            view.displayIgnoringOpacity(view.bounds, in: NSGraphicsContext.current!)
                            NSGraphicsContext.restoreGraphicsState()

                            let image = NSImage(size: view.bounds.size)
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
