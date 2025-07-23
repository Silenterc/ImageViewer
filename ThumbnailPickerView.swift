import SwiftUI

struct ThumbnailPickerView: View {
    let images: [UIImage]
    let imageHeight: CGFloat
    
    @Binding var currentImageIndex: Int
    private let animation: Animation = .interpolatingSpring(stiffness: 500, damping: 50)
    
    private let imageCornerRadius: CGFloat = 4
    private let deviceScreenWidth: CGFloat = UIScreen.main.bounds.width
    // Horizontal padding on both sides of the ScrollView to achieve centered anchor for all images
    // To avoid confusion, imageHeight == imageWidth of currently selected thumbnail
    private var scrollViewPadding: CGFloat { (deviceScreenWidth - imageHeight) / 2 }
    private var biggerPadding: CGFloat = 10
    private var smallerPadding: CGFloat = 4
    
    init(images: [UIImage], imageHeight: CGFloat, currentImageIndex: Binding<Int>) {
        self.images = images
        self.imageHeight = imageHeight
        self._currentImageIndex = currentImageIndex
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(images.indices, id: \.self) { index in
                        let isSelected = currentImageIndex == index
                        let imageWidth = isSelected ? imageHeight : imageHeight / 1.5
              
                        Button(action: {
                            currentImageIndex = index
                        }) {
                            Image(uiImage: images[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: imageWidth, height: imageHeight)
                                .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius))
                                .padding(
                                    .horizontal,
                                    isSelected
                                    ? biggerPadding
                                    : smallerPadding
                                )
                        }
                        .id(index)
                    }
                }
                .padding(.horizontal, scrollViewPadding)
            }
            .animation(animation, value: currentImageIndex)
            .onChange(of: currentImageIndex) { newValue in
                withAnimation(animation) {
                    scrollProxy.scrollTo(newValue, anchor: .center)
                }
            }
            .onAppear {
                // Center the anchor initially when entering this view
                scrollProxy.scrollTo(currentImageIndex, anchor: .center)
            }
        }
    }
}
