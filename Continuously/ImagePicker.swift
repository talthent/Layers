//
//  ImagePicker.swift
//  Continuously
//
//  Created by Tal Cohen on 26/02/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit

protocol ImagePickerDelegate : class {
    func didSelectImage(imagePicker: ImagePicker, image: UIImage)
    func didDeselectImage(imagePicker: ImagePicker)
}

class ImagePicker : UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, PhotosProxyDelegate {
    
    var selectedItem : Int?
    
    fileprivate var photosProxy : PhotosProxy!
    let layout = UICollectionViewFlowLayout()
    let itemSize = CGSize(width: 100, height: 100)
    weak var imagePickerDelegate : ImagePickerDelegate?
    
    var photos : [UIImage]? {
        get {
            return self.photosProxy?.photos
        }
    }
    
    func getSample(success: ((UIImage) -> ())?, failure: (() -> ())?) {
        self.photosProxy.fetchHiResPhoto(index: 0, success: success, failure: failure)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    init(delegate: ImagePickerDelegate) {
        self.imagePickerDelegate = delegate
        super.init(frame: .zero, collectionViewLayout: self.layout)
        self.initialize()
    }
    
    func initialize() {
        self.backgroundColor = UIColor(white: 0, alpha: 0.8)
        self.register(ImagePickerPhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        self.layout.itemSize = self.itemSize
        self.layout.scrollDirection = .horizontal
        self.layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.layout.minimumInteritemSpacing = 5
        self.delegate = self
        self.dataSource = self
        self.photosProxy = PhotosProxy(delegate: self)
    }
    
    //MARK: - PhotosProxyDelegate
    func didFinishLoadingPhotos() {
        self.reloadSections([0])
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos?.count ?? 0
    }
    
    override var numberOfSections: Int {
        get {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! ImagePickerPhotoCell
        cell.checked = self.selectedItem == indexPath.item
        cell.image = self.photos![indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NSLog("didSelect \(indexPath.item)")
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerPhotoCell else {
            return
        }
        if cell.checked {
            cell.checked = false
            self.selectedItem = nil
            self.imagePickerDelegate?.didDeselectImage(imagePicker: self)
            
        } else {
            if let previousSelectedItem = self.selectedItem {
                self.getCellAtIndex(previousSelectedItem)?.checked = false
            }
            
            self.photosProxy.fetchHiResPhoto(index: indexPath.item, success: { (image) in
                self.selectedItem = indexPath.item
                cell.checked = true
                self.imagePickerDelegate?.didSelectImage(imagePicker: self, image: image)
            }, failure: nil)
        }
        
    }
    
    fileprivate func getCellAtIndex(_ index: Int) -> ImagePickerPhotoCell? {
        return self.cellForItem(at: IndexPath(item: index, section: 0)) as? ImagePickerPhotoCell
    }
}




class ImagePickerPhotoCell : UICollectionViewCell {
    
    var image : UIImage? {
        set {
            self.imageView.image = newValue
        }
        get {
            return self.imageView.image
        }
    }
    
    var checked = false {
        didSet {
            self.imageView.layer.borderWidth = checked ? 4 : 0
        }
    }
    
    fileprivate let imageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 4
        iv.layer.borderColor = UIColor(red: 0.1, green: 0.8, blue: 0.8, alpha: 0.4).cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize() {
        self.contentView.addSubview(self.imageView)
        NSLayoutConstraint.activate([
            self.imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
            ])
        
    }
}
