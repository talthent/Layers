//
//  Photo.swift
//  Continuously
//
//  Created by Tal Cohen on 27/02/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Foundation
import Photos

class Photo {
    var asset : PHAsset
    var image : UIImage?
    var thumbnail : UIImage?
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    func getImage(completionBlock: ((UIImage?)->())?) {
        if let image = self.image {
            completionBlock?(image)
            return
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        PHImageManager.default().requestImageData(for: self.asset, options: options) { (imageData, dataUTI, orientation, info) in
            guard let imageData = imageData else {
                completionBlock?(nil)
                return
            }
            guard let image = UIImage(data: imageData) else {
                completionBlock?(nil)
                return
            }
            self.image = image
            completionBlock?(image)
        }
    }
    
    func getThumbnail(completionBlock: ((UIImage?)->())?) {
        if let thumbnail = self.thumbnail {
            completionBlock?(thumbnail)
            return
        }
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .fastFormat
        PHImageManager.default().requestImage(for: self.asset, targetSize: PhotosProxy.thumbnailItemSize, contentMode: .aspectFill, options: options, resultHandler: { result, info in
            if let result = result {
                self.thumbnail = result
                completionBlock?(result)
            } else {
                completionBlock?(nil)
            }
        })
    }
}
