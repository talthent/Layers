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

class PhotosProxy {

    var photos = [UIImage]()
    var delegate : PhotosProxyDelegate?
    
    private let manager = PHImageManager.default()
    private var assets = [PHAsset]()
    
    init(delegate: PhotosProxyDelegate?) {
        self.loadPhotos()
        self.delegate = delegate
    }
    
    func loadPhotos() {
        self.fetchPhotos(targetSize: CGSize(width: 100, height: 100), completionBlock: { images in
            self.photos = images
            self.delegate?.didFinishLoadingPhotos()
        })
    }
    
    fileprivate func fetchPhotos(amount : Int? = nil, targetSize size: CGSize, completionBlock: ((_ photos: [UIImage])->())?){
        var assets = [PHAsset]()
        var fetchedPhotos = [UIImage]()
        
        let group = DispatchGroup()
        let options = PHFetchOptions()
        if let amount = amount {
            options.fetchLimit = amount
        }
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        fetchResult.enumerateObjects({ (asset, id, bool) in
            assets.append(asset)
        })
        self.assets = assets
        assets.forEach {
            group.enter()
            let options = PHImageRequestOptions()
            options.resizeMode = .none
            options.deliveryMode = .fastFormat
            manager.requestImage(for: $0, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { result, info in
                if let result = result {
                    fetchedPhotos.append(result)
                }
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: { 
            completionBlock?(fetchedPhotos)
        }))
    }
    
    func fetchHiResPhoto(index: Int, success: ((UIImage)->())?, failure: (()->())?) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        self.manager.requestImageData(for: self.assets[index], options: options) { (imageData, dataUTI, orientation, info) in
            guard let imageData = imageData else {
                failure?()
                return
            }
            guard let image = UIImage(data: imageData) else {
                failure?()
                return
            }
            success?(image)
        }
        
    }
}
