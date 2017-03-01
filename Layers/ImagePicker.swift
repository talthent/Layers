//
//  ImagePicker.swift
//  Layers
//
//  Created by Tal Cohen on 26/02/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit

protocol ImagePickerDelegate : class {
    func didSelectImage(imagePicker: ImagePicker, image: UIImage)
    func didDeselectImage(imagePicker: ImagePicker)
}

class ImagePicker : UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    static let maxHeight : CGFloat = 110
    static let minHeight : CGFloat = 10
    
    var selectedItemId : String?
    
    weak var delegate : ImagePickerDelegate?
    var collectionView : UICollectionView!
    let layout : UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.itemSize = CGSize(width: 100, height: 100)
        l.scrollDirection = .horizontal
        l.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        l.minimumLineSpacing = 5
        return l
    }()
    
    var photos : [String] {
        get {
            return PhotosProxy.shared.photos
        }
    }
    
    init(delegate: ImagePickerDelegate) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.backgroundColor = .clear
        
        self.setupCollectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: PhotosProxy.loadingPhotosCompleteEvent, object: nil)
        
        
        PhotosProxy.shared.loadPhotos()
    }
    
    func setupCollectionView() {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.collectionViewLayout = self.layout
        self.collectionView.backgroundColor = .clear//UIColor(white: 0, alpha: 0.8)
        self.collectionView.register(ImagePickerPhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.collectionView)
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            self.collectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.collectionView.heightAnchor.constraint(equalToConstant: 110)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshData() {
        self.collectionView.reloadSections([0])
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! ImagePickerPhotoCell
        let imageId = self.photos[indexPath.item]
        cell.image = PhotosProxy.shared.getPhoto(id: imageId).thumbnail
        cell.checked = self.selectedItemId == imageId
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerPhotoCell else {
            return
        }
        if cell.checked {
            cell.checked = false
            self.selectedItemId = nil
            self.delegate?.didDeselectImage(imagePicker: self)
            
        } else {
            if let previousSelectedItemId = self.selectedItemId,
                let previousSelectedCellIndexPath = self.getPhotoIndex(id: previousSelectedItemId) {
                self.getCellAtIndex(previousSelectedCellIndexPath)?.checked = false
            }
            cell.checked = true
            self.isUserInteractionEnabled = false
            let imageId = self.photos[indexPath.item]
            self.selectedItemId = imageId
            PhotosProxy.shared.getImage(id: imageId, completionBlock: { (image) in
                self.isUserInteractionEnabled = true
                if let image = image {
                    self.delegate?.didSelectImage(imagePicker: self, image: image)
                }
            })
        }
    }
    
    func getPhotoIndex(id: String) -> Int? {
        for i in 0..<self.photos.count {
            if self.photos[i] == id {
                return i
            }
        }
        return nil
    }
    
    fileprivate func getCellAtIndex(_ index: Int) -> ImagePickerPhotoCell? {
        return self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ImagePickerPhotoCell
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
