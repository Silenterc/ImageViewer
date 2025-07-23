import SwiftUI
import UIKit

struct PreviewImagesView: View {
    private let images: [UIImage]
    private var initialImageIndex: Int
    private var onDismiss: () -> Void
    private var downloadAction: (UIImage) -> Void
    private var shareAction: (UIImage) -> Void
    
    @State private var currentImageIndex: Int
    @State private var showFullScreen: Bool = true
    
    private var safeAreaInsets: UIEdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets()
    }
    private var topPadding: CGFloat { safeAreaInsets.top + 4 }
    private let toolbarPadding: CGFloat = 8
    private let imageHeight: CGFloat = 40
    
    init(
        images: [UIImage],
        initialImageIndex: Int = 0,
        onDismiss: @escaping () -> Void,
        downloadAction: @escaping (UIImage) -> Void,
        shareAction: @escaping (UIImage) -> Void
    ) {
        self.images = images
        self.initialImageIndex = initialImageIndex
        self.onDismiss = onDismiss
        self.downloadAction = downloadAction
        self.shareAction = shareAction
        _currentImageIndex = State(initialValue: initialImageIndex)
    }
    
    var body: some View {
        ZStack {
            ImagePreviewToolbar(
                onDismiss: onDismiss,
                downloadAction: { downloadAction(images[currentImageIndex]) },
                shareAction: { shareAction(images[currentImageIndex]) }
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, topPadding)
            .padding(.horizontal, toolbarPadding)
            .zIndex(2)
            .opacity(showFullScreen ? 1 : 0)
            .allowsHitTesting(showFullScreen)
            
            TabView(selection: $currentImageIndex) {
                ForEach(images.indices, id: \.self) { index in
                    ZoomableImage(
                        image: images[index],
                        resetBehavior: .onPageChange(
                            currentPageIndex: $currentImageIndex,
                            pageIndex: index
                        )
                    )
                    .onZoomStarted {
                        withAnimation {
                            showFullScreen = false
                        }
                    }
                    .onZoomEnded { zoom in
                        if zoom == 1 {
                            withAnimation {
                                showFullScreen = true
                            }
                        }
                    }
                    .onSingleTap {
                        withAnimation {
                            showFullScreen.toggle()
                        }
                    }
                    .ignoresSafeArea()
                    .tag(index)
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.default, value: currentImageIndex)
            
            ThumbnailPickerView(
                images: images,
                imageHeight: imageHeight,
                currentImageIndex: $currentImageIndex
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, safeAreaInsets.bottom)
            .opacity(showFullScreen ? 1 : 0)
            .allowsHitTesting(showFullScreen)
        }
        .ignoresSafeArea()
        .background(.ultraThinMaterial)
    }
}
