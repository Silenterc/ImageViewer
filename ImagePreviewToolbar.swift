import SwiftUI

struct ImagePreviewToolbar: View {
    let onDismiss: () -> Void
    let downloadAction: () -> Void
    let shareAction: () -> Void
    
    var body: some View {
        HStack {
            ImageToolbarButton(
                icon: Image(systemName: "xmark")
            ) {
                onDismiss()
            }
            
            Spacer()
            
            ImageToolbarButton(
                icon: Image(systemName: "arrow.down")
            ) {
                downloadAction()
            }
            
            ImageToolbarButton(
                icon: Image(systemName: "square.and.arrow.up")
            ) {
                shareAction()
            }
        }
        .foregroundStyle(.white)
    }
}

/// A reusable button component for the toolbar.
struct ImageToolbarButton: View {
    let icon: Image
    let action: () -> Void
    
    private let buttonWidth: CGFloat = 24
    private let buttonHeight: CGFloat = 24
    private let buttonPadding: CGFloat = 8
    
    var body: some View {
        Button(action: action) {
            icon
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: buttonWidth, height: buttonHeight)
                .padding(buttonPadding)
        }
    }
}
