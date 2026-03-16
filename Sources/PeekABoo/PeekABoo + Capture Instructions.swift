import SwiftUI

@available(visionOS 1.0, *)
public extension PeekABoo {
    /// The screenshot gestures image bundled with PeekABoo.
    ///
    /// This image shows the Vision Pro headset with arrows pointing to the Digital Crown and Top Button.
    static var captureGestureIcon: Image {
        if let path = Bundle.module.path(forResource: "CaptureGesture", ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            return Image(uiImage: image)
        }
        
        return Image(systemName: "visionpro")
    }
    
    /// A view that displays the instructions for taking a screenshot on Vision Pro.
    ///
    /// This view combines the instructional image with text explaining the action.
    /// Usage: `PeekABoo.CaptureInstructions()`
    struct CaptureInstructions: View {
        var description: String?
        
        /// Creates a view displaying the standard screenshot gesture instructions.
        public init() {}
        
        /// Creates a view displaying the screenshot gesture instructions with an optional additional description.
        ///
        /// - Parameter description: An optional string to display below the standard instructions.
        public init(description: String?) {
            self.description = description
        }
        
        public var body: some View {
            VStack(spacing: 24) {
                PeekABoo.captureGestureIcon
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .accessibilityHidden(true)
                
                Text(verbatim: "Press and release the top button and the Digital Crown at the same time.")
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                if let description {
                    Text(description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
    }
}

