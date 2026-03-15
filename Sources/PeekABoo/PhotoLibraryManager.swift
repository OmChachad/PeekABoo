import Photos
import UIKit

@MainActor
final class PhotoLibraryManager: NSObject, ObservableObject {
    @Published var latestScreenshot: PHAsset?

    private var fetchResult: PHFetchResult<PHAsset>?
    private var monitoringStartDate: Date?

    func start() async {
        monitoringStartDate = Date()
        guard await Self.requestAccess() else { return }

        PHPhotoLibrary.shared().register(self)

        let collections = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil
        )
        guard let album = collections.firstObject else { return }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 1

        let result = PHAsset.fetchAssets(in: album, options: options)
        fetchResult = result
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    // MARK: - Image Loading

    func loadImage(from asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    // MARK: - Authorization

    static func requestAccess() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .authorized { return true }
        if status == .notDetermined {
            return await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
        }
        return false
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension PhotoLibraryManager: PHPhotoLibraryChangeObserver {
    nonisolated func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor in
            guard let current = fetchResult,
                  let changes = changeInstance.changeDetails(for: current) else { return }
            let updated = changes.fetchResultAfterChanges
            self.fetchResult = updated

            // Only update if the new screenshot was taken after monitoring started
            if let asset = updated.firstObject,
               let startDate = self.monitoringStartDate,
               let creationDate = asset.creationDate,
               creationDate > startDate {
                self.latestScreenshot = asset
            }
        }
    }
}
