//
//  PhotosProxy.swift
//  Continuously
//
//  Created by Tal Cohen on 21/02/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Photos

protocol PhotosProxyDelegate {
    func didFinishLoadingPhotos()
}

class Photo {
    var asset : PHAsset
    var image : UIImage?
    var thumbnail : UIImage?
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    func getImage(success: ((UIImage)->())?, failure: (()->())?) {
        if let image = self.image {
            success?(image)
            return
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        PHImageManager.default().requestImageData(for: self.asset, options: options) { (imageData, dataUTI, orientation, info) in
            guard let imageData = imageData else {
                failure?()
                return
            }
            guard let image = UIImage(data: imageData) else {
                failure?()
                return
            }
            self.image = image
            success?(image)
        }
    }
    
    func getThumbnail(success: ((UIImage)->())?, failure: (()->())?) {
        if let thumbnail = self.thumbnail {
            success?(thumbnail)
            return
        }
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .fastFormat
        PHImageManager.default().requestImage(for: self.asset, targetSize: PhotosProxy.thumbnailItemSize, contentMode: .aspectFill, options: options, resultHandler: { result, info in
            if let result = result {
                self.thumbnail = result
                success?(result)
            } else {
                failure?()
            }
        })
    }
}

class PhotosProxy {

    static let thumbnailItemSize = CGSize(width: 100, height: 100)
    
    var delegate : PhotosProxyDelegate?
    
    var photos = [Photo]()
    
    init(delegate: PhotosProxyDelegate?) {
        self.loadPhotos()
        self.delegate = delegate
    }
    
    func loadPhotos() {
        self.fetchPhotos(targetSize: PhotosProxy.thumbnailItemSize, completionBlock: { photos in
            self.photos = photos
            self.delegate?.didFinishLoadingPhotos()
        })
    }
    
    fileprivate func fetchPhotos(amount : Int? = nil, targetSize size: CGSize, completionBlock: ((_ photos: [Photo])->())?){
        var photos = [Photo]()
        
        let group = DispatchGroup()
        let options = PHFetchOptions()
        if let amount = amount {
            options.fetchLimit = amount
        }
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        fetchResult.enumerateObjects({ (asset, id, bool) in
            photos.append(Photo(asset: asset))
        })
        
        for i in 0..<photos.count {
            group.enter()
            let options = PHImageRequestOptions()
            options.resizeMode = .fast
            options.deliveryMode = .fastFormat
            PHImageManager.default().requestImage(for: photos[i].asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { result, info in
                if let result = result {
                    photos[i].thumbnail = result
                }
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: { 
            completionBlock?(photos)
        }))
    }
}
