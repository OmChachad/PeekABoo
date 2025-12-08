//
//  CameraCapture.swift
//  PeekABoo
//

import SwiftUI
import Photos

// MARK: - View Extension

extension View {
    /// Monitors for camera captures and calls the completion handler with the captured image
    /// - Parameter completionHandler: Closure that receives the captured Image
    func onCapture(completionHandler: @escaping (UIImage) -> Void) -> some View {
        self.modifier(CameraCaptureModifier(completionHandler: completionHandler))
    }
}

// MARK: - View Modifier

private struct CameraCaptureModifier: ViewModifier {
    let completionHandler: (UIImage) -> Void
    @StateObject private var photoCollection = PhotoLibraryManager()
    
    func body(content: Content) -> some View {
        content
            .task {
                await photoCollection.loadPhotos()
            }
            .onChange(of: photoCollection.latestPhoto) { oldValue, newValue in
                newValue?.requestImage(targetSize: CGSize(width: 1920, height: 1080)) { result in
                    if let image = result?.image {
                        completionHandler(image)
                    }
                }
            }
    }
}

// MARK: - Usage Example

struct ContentView: View {
    @State private var capturedImage: Image?
    @State private var capturedUIImage: UIImage?
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.pushWindow) private var pushWindow
    
    var body: some View {
        VStack {
            if let capturedImage {
                capturedImage
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Waiting for capture...")
            }
            
//            Button("Ask AI") {
//                if let imageData = capturedUIImage?.pngData() {
//                    openWindow(id: "AskAI", value: imageData)
//                }
//            }
        }
//        .frame(width: 10, height: 10)
        .onCapture { image in
            capturedImage = Image(uiImage: image)
            capturedUIImage = image
            if let imageData = image.pngData() {
//                dismissWindow(id: "main")
                openWindow(id: "AskAI", value: imageData)
//                pushWindow(id: "AskAI", value: imageData)
            }
        }
    }
}
