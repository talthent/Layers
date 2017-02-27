//
//  ViewController.swift
//  Layers
//
//  Created by Tal Cohen on 23/02/17.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, ImagePickerDelegate, UIGestureRecognizerDelegate, UIViewControllerPreviewingDelegate {
    
    var tapGesture : UITapGestureRecognizer?
    
    var videoBox = UIView()
    var masksPicker = MasksPicker()
    var imagePicker : ImagePicker!
    var captureButton : UIButton = {
        let b = UIButton()
        b.backgroundColor = UIColor(white: 1, alpha: 0.8)
        b.layer.borderWidth = 1
        b.layer.cornerRadius = 27
        b.clipsToBounds = true
        return b
    }()
    var flipCameraButton : UIButton = {
        let b = UIButton()
        b.setBackgroundImage(UIImage(named: "flipCamera"), for: .normal)
        return b
    }()
    
    var cameraEngine = CameraEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupCamera()
        self.setupGestures()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: self.view)
        }
    }
    
    fileprivate func setupViews() {
        self.videoBox.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.videoBox)
        NSLayoutConstraint.activate([
            self.videoBox.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.videoBox.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.videoBox.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.videoBox.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
        
        
        self.masksPicker.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.masksPicker)
        NSLayoutConstraint.activate([
            self.masksPicker.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.masksPicker.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.masksPicker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.masksPicker.topAnchor.constraint(equalTo: self.view.topAnchor)
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
        
        self.flipCameraButton.addTarget(self, action: #selector(flipCameraButtonTapped), for: .touchUpInside)
        self.flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.flipCameraButton)
        NSLayoutConstraint.activate([
            self.flipCameraButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
            self.flipCameraButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            self.flipCameraButton.widthAnchor.constraint(equalToConstant: 54),
            self.flipCameraButton.heightAnchor.constraint(equalToConstant: 54)
            ])
        
    }
    
    fileprivate func setupCamera() {
        self.cameraEngine.start()
        if let previewLayer = self.cameraEngine.getPreviewLayer() {
            self.videoBox.layer.addSublayer(previewLayer)
            previewLayer.frame = UIScreen.main.bounds
        }
    }
    
    fileprivate func setupGestures() {
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(tap:)))
        self.tapGesture?.delegate = self
        self.view.addGestureRecognizer(self.tapGesture!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.masksPicker.createMask()
    }
    
    func captureButtonTapped() {
        self.cameraEngine.captureAndMerge(maskedImage: try! self.masksPicker.renderMaskedImage())
        self.startCaptureAnimation()
    }
    
    func flipCameraButtonTapped() {
        self.cameraEngine.flipCamera()
        self.setupCamera()
    }
    
    func startCaptureAnimation() {
        let whiteView = UIView()
        whiteView.backgroundColor = .white
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(whiteView)
        NSLayoutConstraint.activate([
            whiteView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            whiteView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            whiteView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            whiteView.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
        UIView.animate(withDuration: 0.3, animations: { 
            whiteView.alpha = 0
        }) { _ in
            whiteView.removeFromSuperview()
        }
    }
    
    //MARK: Gesture Handlers
    func tapGestureHandler(tap : UITapGestureRecognizer) {
        self.masksPicker.changeMask()
    }
    
    //MARK: ImagePickerDelegate
    func didSelectImage(imagePicker: ImagePicker, image: UIImage) {
        self.masksPicker.image = image
    }
    
    func didDeselectImage(imagePicker: ImagePicker) {
        self.masksPicker.image = nil
    }
    
    //MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.imagePicker) == true {
            return false
        }
        return true
    }
    
    //MARK: UIGestureRecognizerDelegate
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let point = self.view.convert(location, to: self.imagePicker)
        guard let indexPath = self.imagePicker.indexPathForItem(at: point) else {
            return nil
        }
        guard let cell = self.imagePicker.cellForItem(at: indexPath) else {
            return nil
        }
        let photoVC = PreviewViewController(photo: self.imagePicker.photos[indexPath.item])
        photoVC.rootViewController = self
        previewingContext.sourceRect = cell.frame
        return photoVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) { }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
