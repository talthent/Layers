//
//  PhotosProxy.swift
//  Layers
//
//  Created by Tal Cohen on 21/02/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Photos

class PhotosProxy {

    let firstBatch = 10
    static let thumbnailItemSize = CGSize(width: 200, height: 200)
    static let shared = PhotosProxy()

    static let fetchingPhotosFirstBatchCompletedEvent = NSNotification.Name("fetchingPhotosFirstBatchCompletedEvent")
    static let onePhotoAddedEvent = Notification.Name("onePhotoAddedEvent")
    
    var photos = [String]()
    var photosBucket = [String:Photo]()
    
    func loadLastPhoto() {
        self.fetchPhotos(end: 1) { 
            NotificationCenter.default.post(name: PhotosProxy.onePhotoAddedEvent, object: nil)
        }
    }
    
    func loadPhotos() {
        NSLog("******* LOAD PHOTOS!!! *******")
        PHPhotoLibrary.requestAuthorization { (auth) in
            switch auth {
            case .authorized:
                self.fetchPhotosIds()
                self.fetchPhotosFirstBatch({ 
                    NotificationCenter.default.post(name: PhotosProxy.fetchingPhotosFirstBatchCompletedEvent, object: nil)
                    DispatchQueue.global(qos: .background).async {
                        self.fetchPhotosSecondBatch(nil)
                    }
                })
            default:
                break;
            }
        }
    }
    
    func getThumbnail(id : String, completionBlock: ((UIImage?)->())?) {
        self.photosBucket[id]!.getThumbnail(completionBlock: completionBlock)
    }
    
    func getImage(id : String, completionBlock: ((UIImage?)->())?) {
        self.photosBucket[id]!.getImage(completionBlock: completionBlock)
    }
    
    func getPhoto(id : String) -> Photo {
        return self.photosBucket[id]!
    }
    
    fileprivate func fetchPhotosIds() {
        NSLog("Fetching IDs...")
        var photos = [String]()
        let options = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        
        fetchResult.enumerateObjects({ (asset, id, bool) in
            if self.photosBucket[asset.localIdentifier] == nil {
                self.photosBucket[asset.localIdentifier] = Photo(asset: asset)
            }
            photos.append(asset.localIdentifier)
        })
        
        self.photos = photos
        NSLog("Fetching IDs completed")
    }
    
    fileprivate func fetchPhotosFirstBatch(_ completion: (()->())?) {
        self.fetchPhotos(start: 0, end: min(self.photos.count, self.firstBatch), completion)
    }
    
    fileprivate func fetchPhotosSecondBatch(_ completion: (()->())?) {
        if self.photos.count > self.firstBatch {
            self.fetchPhotos(start: self.firstBatch, end: self.photos.count, completion)
        } else {
            completion?()
        }
    }
    
    fileprivate func fetchPhotos(start: Int = 0, end: Int, _ completion: (()->())?){
        //FIRST BATCH
        NSLog("Fetching Photos \(start) to \(end)...")
        let group = DispatchGroup()
        for i in start..<end {
                group.enter()
                self.photosBucket[self.photos[i]]!.getThumbnail(completionBlock: { (thumbnail) in
                    group.leave()
                })
        }
        group.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            NSLog("Fetching Photos \(start) to \(end) completed")
            completion?()
        }))
    }
}
