//
//  ViewController.swift
//  Continuously
//
//  Created by Tal Cohen on 23/02/17.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, ImagePickerDelegate {
    
    var videoBox = UIView()
    var maskImage = UIImageView()
    var imagePicker : ImagePicker!
    var captureButton : UIButton = {
        let b = UIButton()
        b.backgroundColor = UIColor(white: 1, alpha: 0.8)
        b.layer.borderWidth = 1
        b.layer.cornerRadius = 27
        b.clipsToBounds = true
        return b
    }()
    
    var cameraEngine = CameraEngine()
    
    fileprivate func setupViews() {
        self.videoBox.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.videoBox)
        NSLayoutConstraint.activate([
            self.videoBox.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.videoBox.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.videoBox.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.videoBox.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
        
        self.maskImage.contentMode = .scaleAspectFill
        self.maskImage.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.maskImage)
        NSLayoutConstraint.activate([
            self.maskImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.maskImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.maskImage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.maskImage.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
        
        self.imagePicker = ImagePicker(delegate: self)
        self.imagePicker.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.imagePicker)
        NSLayoutConstraint.activate([
            self.imagePicker.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.imagePicker.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.imagePicker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.imagePicker.heightAnchor.constraint(equalToConstant: 110)
            ])
        
        self.captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        self.captureButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.captureButton)
        NSLayoutConstraint.activate([
            self.captureButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.captureButton.bottomAnchor.constraint(equalTo: self.imagePicker.topAnchor, constant: -10),
            self.captureButton.widthAnchor.constraint(equalToConstant: 54),
            self.captureButton.heightAnchor.constraint(equalToConstant: 54)
            ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        
        self.cameraEngine.start()
        if let previewLayer = self.cameraEngine.getPreviewLayer() {
            self.videoBox.layer.addSublayer(previewLayer)
            previewLayer.frame = self.videoBox.bounds
        }
        
        let maskLayer = CALayer()
        maskLayer.contents = UIImage(named: "m1")?.cgImage
        maskLayer.frame = self.maskImage.bounds
        self.maskImage.layer.mask = maskLayer
        self.maskImage.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func captureButtonTapped() {
        print("Camera button pressed")
        self.cameraEngine.capture()
    }
    
    //MARK: ImagePickerDelegate
    func didSelectImage(imagePicker: ImagePicker, image: UIImage) {
        self.maskImage.image = image
    }
    
    func didDeselectImage(imagePicker: ImagePicker) {
        self.maskImage.image = nil
    }
}
