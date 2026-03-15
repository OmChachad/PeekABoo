import SwiftUI
import Photos

// MARK: - Public API

public enum PeekABoo {
    /// Requests full access to the photo library.
    ///
    /// The user will be prompted to grant access if they haven't already.
    /// Returns `true` if full access is granted, `false` if access is limited or deniedccess is limited or denied.
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
