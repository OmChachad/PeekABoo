//
//  DataModel.swift
//  PeekABoo
//
//  Created by Om Chachad on 27/11/25.
//


import AVFoundation
import SwiftUI

final class DataModel {
    static let instance = DataModel()
    let photoCollection = PhotoLibraryManager()
    
//    @Published var thumbnailImage: Image?
    
    var isPhotosLoaded = false
    
    init() { }
    
    
    
//    func loadThumbnail() async {
//        guard let asset = photoCollection.photoAssets.first  else { return }
//        await photoCollection.cache.requestImage(for: asset, targetSize: CGSize(width: 256, height: 256))  { result in
//            if let result = result {
//                Task { @MainActor in
//                    self.thumbnailImage = result.image
//                }
//            }
//        }
//    }
}

fileprivate struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}
