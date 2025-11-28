import SwiftUI
import Photos
import os.log
import Combine


class PhotoLibraryManager: NSObject, ObservableObject {
    @Published var photoAssets: PhotoAssetCollection = PhotoAssetCollection(PHFetchResult<PHAsset>())
    
    var latestPhoto: PhotoAssetCollection.Element? {
        return photoAssets.first
    }
    var assetCollection: PHAssetCollection?
    
    var identifier: String? {
        assetCollection?.localIdentifier
    }
    
    var isPhotosLoaded: Bool = false
    
    enum PhotoCollectionError: LocalizedError {
        case missingAssetCollection
        case missingAlbumName
        case missingLocalIdentifier
        case unableToFindAlbum(String)
        case unableToLoadSmartAlbum(PHAssetCollectionSubtype)
        case addImageError(Error)
        case createAlbumError(Error)
        case removeAllError(Error)
    }
    
    func loadPhotos() async {
        guard !isPhotosLoaded else { return }
        
        let authorized = await PhotoLibrary.checkAuthorization()
        guard authorized else {
//            LogManager.shared.addLog("Photo library access was not authorized.")
            return
        }
        
        Task {
            do {
                try await self.load()
//                await self.loadThumbnail()
            } catch let error {
//                LogManager.shared.addLog("Failed to load photo collection: \(error.localizedDescription)", type: .error)
            }
            self.isPhotosLoaded = true
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func removeAsset(_ asset: PhotoAsset) async throws {
        guard let assetCollection = self.assetCollection else {
            throw PhotoCollectionError.missingAssetCollection
        }
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection) {
                    albumChangeRequest.removeAssets([asset as Any] as NSArray)
                }
            }
            
            await refreshPhotoAssets()
            
        } catch let error {
            throw PhotoCollectionError.removeAllError(error)
        }
    }
    
    func load() async throws {
        PHPhotoLibrary.shared().register(self)
        
        if let assetCollection = PhotoLibraryManager.getSmartAlbum(subtype: .smartAlbumScreenshots) {
//            LogManager.shared.addLog("Loaded smart album of type: \(smartAlbumType.rawValue)")
            self.assetCollection = assetCollection
            await refreshPhotoAssets()
            return
        } else {
//            LogManager.shared.addLog("Unable to load smart album of type: : \(smartAlbumType.rawValue)")
            throw PhotoCollectionError.unableToLoadSmartAlbum(.smartAlbumScreenshots)
        }
    }
    
    private static func getSmartAlbum(subtype: PHAssetCollectionSubtype) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: fetchOptions)
        return collections.firstObject
    }
    
    private func refreshPhotoAssets(_ fetchResult: PHFetchResult<PHAsset>? = nil) async {

        var newFetchResult = fetchResult

        if newFetchResult == nil {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//            fetchOptions.predicate = NSPredicate()
            fetchOptions.fetchLimit = 5
            if let assetCollection = self.assetCollection, let fetchResult = (PHAsset.fetchAssets(in: assetCollection, options: fetchOptions) as AnyObject?) as? PHFetchResult<PHAsset> {
                newFetchResult = fetchResult
            }
        }
        
        if let newFetchResult = newFetchResult {
            await MainActor.run {
                photoAssets = PhotoAssetCollection(newFetchResult)
            }
        }
    }
}

extension PhotoLibraryManager: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor in
            guard let changes = changeInstance.changeDetails(for: self.photoAssets.fetchResult) else { return }
            await self.refreshPhotoAssets(changes.fetchResultAfterChanges)
        }
    }
}
