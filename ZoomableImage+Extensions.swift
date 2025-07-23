import SwiftUI
import UIKit

/// A behavior that determines when the zoom level of the `ZoomableView` should be reset.
enum ZoomResetBehavior {
    /// The zoom level is reset automatically when needed
    case automatic
    /// The zoom level is reset automatically and also when the view is no longer the active page in a `TabView`.
    /// - Parameter currentPageIndex: A binding to the current page index to allow for zoom reset when outside.
    /// - Parameter pageIndex: Used for comparison if this view is still the active page.
    case onPageChange(
        currentPageIndex: Binding<Int>,
        pageIndex: Int
    )
}

/// A `UIImage` wrapper which makes it zoomable by pinching & double tapping
struct ZoomableImage: UIViewRepresentable {
    let image: UIImage
    var resetBehavior: ZoomResetBehavior = .automatic
    
    var onZoomStarted: (() -> Void)?
    var onZoomEnded: ((CGFloat) -> Void)?
    var onSingleTap: (() -> Void)?
    
    func makeUIView(context: Context) -> UIScrollView {
        
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 1
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])
        
        // Add double-tap-to-zoom gesture
        let doubleTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(
                Coordinator.handleDoubleTap
            )
        )
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        // Add single-tap to do custom behaviour
        let singleTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(
                Coordinator.handleSingleTap
            )
        )
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.require(toFail: doubleTapGesture)
        scrollView.addGestureRecognizer(singleTapGesture)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.onZoomStarted = onZoomStarted
        context.coordinator.onZoomEnded = onZoomEnded
        context.coordinator.onSingleTap = onSingleTap
        
        switch resetBehavior {
        case let .onPageChange(currentPageIndex, pageIndex):
            if currentPageIndex.wrappedValue != pageIndex {
                DispatchQueue.main.async {
                    uiView.setZoomScale(uiView.minimumZoomScale, animated: true)
                }
            }
        case .automatic:
            // Do nothing if the behavior is automatic.
            break
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var onZoomStarted: (() -> Void)?
        var onZoomEnded: ((CGFloat) -> Void)?
        var onSingleTap: (() -> Void)?
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.viewWithTag(1)
        }
        
        func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            onZoomStarted?()
        }
        
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            onZoomEnded?(scale)
        }
        
        @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
            guard let scrollView = recognizer.view as? UIScrollView else { return }
            
            if scrollView.zoomScale > scrollView.minimumZoomScale {
                // If currently zoomed in, zoom out to the minimum scale.
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            } else {
                // If currently zoomed out, zoom in to a fixed scale (e.g., 2.0).
                scrollView.setZoomScale(2.0, animated: true)
            }
        }
        
        @objc func handleSingleTap(recognizer: UITapGestureRecognizer) {
            onSingleTap?()
        }
    }
}

extension ZoomableImage {
    func onZoomStarted(perform action: @escaping () -> Void) -> Self {
        var newView = self
        newView.onZoomStarted = action
        return newView
    }
    
    func onZoomEnded(perform action: @escaping (CGFloat) -> Void) -> Self {
        var newView = self
        newView.onZoomEnded = action
        return newView
    }
    
    func onSingleTap(perform action: @escaping () -> Void) -> Self {
        var newView = self
        newView.onSingleTap = action
        return newView
    }
}
