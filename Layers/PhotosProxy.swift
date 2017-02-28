//
//  PhotosProxy.swift
//  Layers
//
//  Created by Tal Cohen on 21/02/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Photos

class PhotosProxy {

    static let thumbnailItemSize = CGSize(width: 100, height: 100)
    static let shared = PhotosProxy()

    static let loadingPhotosCompleteEvent = NSNotification.Name("loadingPhotosComplete")
    
    var photos = [Photo]()
    
    func loadPhotos() {
        PHPhotoLibrary.requestAuthorization { (auth) in
            switch auth {
            case .authorized:
                self.fetchPhotos(targetSize: PhotosProxy.thumbnailItemSize, completionBlock: { photos in
                    self.photos = photos
                    NotificationCenter.default.post(name: PhotosProxy.loadingPhotosCompleteEvent, object: nil)
                })
            default:
                break;
            }
        }
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
            photos[i].getThumbnail(completionBlock: { (thumbnail) in
                photos[i].thumbnail = thumbnail
                group.leave()
            })
            
        }
        group.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: { 
            completionBlock?(photos)
        }))
    }
}
