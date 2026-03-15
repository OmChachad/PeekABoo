//
//  ScreenshotObserverModifier.swift
//  PeekABoo
//
//  Created by Om Chachad on 15/03/26.
//


import SwiftUI
import Photos

public extension View {
    /// Calls the completion handler with a `UIImage` whenever a new screenshot is detected.
    ///
    /// Requires `NSPhotoLibraryUsageDescription` in your Info.plist.
    func onCapture(perform action: @escaping (UIImage) -> Void) -> some View {
        modifier(ScreenshotObserverModifier(action: action))
    }
}

private struct ScreenshotObserverModifier: ViewModifier {
    let action: (UIImage) -> Void

    @StateObject private var manager = PhotoLibraryManager()

    func body(content: Content) -> some View {
        content
            .task { await manager.start() }
            .onChange(of: manager.latestScreenshot) { _, asset in
                guard let asset else { return }
                Task {
                    if let image = await manager.loadImage(from: asset, targetSize: CGSize(width: 1920, height: 1080)) {
                        action(image)
                    }
                }
            }
    }
}
