// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Photos

// MARK: - Public API

public enum PeekABoo {
    /// Requests full access to the photo library.
    ///
    /// The user will be prompted to grant access if they haven't already.
    /// Returns `true` if full access is granted, `false` if access is limited or denied.
    @MainActor
    public static func requestAccess() async -> Bool {
        await PhotoLibraryManager.requestAccess()
    }

    /// Checks if full access to the photo library has been granted.
    ///
    /// This returns `true` only if the user has granted full "All Photos" access.
    /// It returns `false` if the user has granted "Limited" or "No" access.
    public static var isAccessGranted: Bool {
        PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
    }
}

public extension View {
    /// Calls the completion handler with a `UIImage` whenever a new screenshot is detected.
    ///
    /// Requires `NSPhotoLibraryUsageDescription` in your Info.plist.
    func onCapture(perform action: @escaping (UIImage) -> Void) -> some View {
        modifier(ScreenshotObserverModifier(action: action))
    }
}

// MARK: - Private Modifier

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
