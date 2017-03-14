//
//  ViewController.swift
//  Layers
//
//  Created by Tal Cohen on 23/02/17.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit
import Foundation
import Instabug
import FirebaseAnalytics

class ViewController: UIViewController {
    
    var tapGesture : UITapGestureRecognizer?
    var panGesture : UIPanGestureRecognizer?
    var panStartingPoint : CGPoint?
    var imagePickerHeightStartingPoint : CGFloat?
    
    var videoBox = UIView()
    var masksPicker = MasksPicker()
    var imagePicker : ImagePicker!
    var imagePickerHeightConstraint : NSLayoutConstraint?
    var captureButton = CaptureButton()
    var flipCameraButton : UIButton = {
        let b = UIButton()
        b.setBackgroundImage(UIImage(named: "flipCamera"), for: .normal)
        b.alpha = 0.8
        return b
    }()
    var addGridButton : UIButton = {
        let b = UIButton()
        b.setBackgroundImage(UIImage(named: "grid"), for: .normal)
        b.alpha = 0.8
        return b
    }()
    var gridView : GridView = {
        let grid = GridView()
        grid.backgroundColor = .clear
        grid.isUserInteractionEnabled = false
        grid.alpha = 0.5
        grid.isHidden = true
        return grid
    }()
    var feedbackButton = RoundButton(size: 28, title: "!")
    var changeMaskTutorial = ChangeMaskTutorial()
    var changeMaskTutorialTimer : Timer?
    
    var cameraEngine = CameraEngine()
    var firstBatchArrived = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupCamera()
        self.setupGestures()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: self.view)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotifications(notification:)), name: PhotosProxy.fetchingPhotosFirstBatchCompletedEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotifications(notification:)), name: PhotosProxy.onePhotoAddedEvent, object: nil)
        
        if Settings.shouldPlayChangeMaskTutorial() {
            self.changeMaskTutorialTimer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(changeMaskTutorialTimerAction), userInfo: nil, repeats: false)
        }
    }
    
    func changeMaskTutorialTimerAction() {
        self.changeMaskTutorialTimer?.invalidate()
        self.changeMaskTutorialTimer = nil
        self.changeMaskTutorial.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.masksPicker.createMask()
    }
    
    fileprivate func setupViews() {
        self.view.backgroundColor = .black
        
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
        
        //Grid should be added to view after videoBox and masks
        self.gridView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.gridView)
        NSLayoutConstraint.activate([
            self.gridView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.gridView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.gridView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.gridView.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
        
        self.changeMaskTutorial.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.changeMaskTutorial)
        NSLayoutConstraint.activate([
            self.changeMaskTutorial.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.changeMaskTutorial.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.changeMaskTutorial.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.changeMaskTutorial.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
        
        self.imagePicker = ImagePicker(delegate: self)
        self.imagePicker.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.imagePicker)
        self.imagePickerHeightConstraint = self.imagePicker.heightAnchor.constraint(equalToConstant: ImagePicker.minHeight)
        NSLayoutConstraint.activate([
            self.imagePicker.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.imagePicker.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.imagePicker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.imagePickerHeightConstraint!
            ])
        
        self.captureButton.startLoading()
        self.captureButton.addTarget(self, action: #selector(captureButtonTapped))
        self.captureButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.captureButton)
        NSLayoutConstraint.activate([
            self.captureButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.captureButton.bottomAnchor.constraint(equalTo: self.imagePicker.topAnchor, constant: -10),
            self.captureButton.widthAnchor.constraint(equalToConstant: 66),
            self.captureButton.heightAnchor.constraint(equalToConstant: 66)
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
        
        self.addGridButton.addTarget(self, action: #selector(toggleGrid), for: .touchUpInside)
        self.addGridButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.addGridButton)
        NSLayoutConstraint.activate([
            self.addGridButton.rightAnchor.constraint(equalTo: self.flipCameraButton.leftAnchor, constant: -10),
            self.addGridButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            self.addGridButton.widthAnchor.constraint(equalToConstant: 54),
            self.addGridButton.heightAnchor.constraint(equalToConstant: 54)
            ])
        
        self.feedbackButton.addTarget(self, action: #selector(feedbackButtonTapped), for: .touchUpInside)
        self.feedbackButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.feedbackButton)
        NSLayoutConstraint.activate([
            self.feedbackButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
            self.feedbackButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            self.feedbackButton.widthAnchor.constraint(equalToConstant: 28),
            self.feedbackButton.heightAnchor.constraint(equalToConstant: 28)
            ])
    }
    
    func feedbackButtonTapped() {
        Instabug.invoke()
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
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(pan:)))
        self.panGesture?.delegate = self
        self.view.addGestureRecognizer(self.panGesture!)
    }
    
    func handleNotifications(notification: Notification) {
        switch notification.name {
        case PhotosProxy.fetchingPhotosFirstBatchCompletedEvent:
            if firstBatchArrived == false {
                self.expandImagePicker(animated: true)
                self.imagePicker.selectPhoto(atIndex: 0)
                self.firstBatchArrived = true
                self.captureButton.stopLoading()
            }
        default:
            break;
        }
    }
    
    fileprivate func expandImagePicker(animated: Bool) {
        self.imagePickerHeightConstraint?.constant = ImagePicker.maxHeight
        if animated {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .allowUserInteraction, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        } else {
            self.view.layoutIfNeeded()
        }
    }
    
    func captureButtonTapped() {
        FIRAnalytics.logEvent(withName: userTookAPhotoEvent, parameters: ["hasMask" : (self.masksPicker.image != nil) as NSObject])
        self.cameraEngine.captureAndMerge(maskedImage: try! self.masksPicker.renderMaskedImage())
        self.startCaptureAnimation()
        
    }
    
    func flipCameraButtonTapped() {
        FIRAnalytics.logEvent(withName: userFlippedCameraEvent, parameters: nil)
        self.cameraEngine.flipCamera()
        self.setupCamera()
    }
    
    func toggleGrid() {
        self.gridView.isHidden = !self.gridView.isHidden
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
        FIRAnalytics.logEvent(withName: userChangedMaskEvent, parameters: nil)
        self.changeMaskTutorial.stop()
        self.masksPicker.changeMask()
    }
    
    func panGestureHandler(pan : UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            self.panStartingPoint = pan.location(in: self.view)
            self.imagePickerHeightStartingPoint = self.imagePickerHeightConstraint?.constant
        case .changed:
            let distance = self.panStartingPoint!.y - pan.location(in: self.view).y
            var result = distance + self.imagePickerHeightStartingPoint!
            
            if result < ImagePicker.minHeight {
                result = ImagePicker.minHeight
            } else if result > ImagePicker.maxHeight {
                result = ImagePicker.maxHeight + (result - ImagePicker.maxHeight) / 4
            }
            self.imagePickerHeightConstraint?.constant = result
        case .cancelled, .ended ,.failed:
            let imagePickerHeight = self.imagePickerHeightConstraint!.constant
            let velocity = pan.velocity(in: self.view).y
        
            var height : CGFloat
            if velocity < -800 {
                height = ImagePicker.maxHeight
            } else if velocity > 800 {
                height = ImagePicker.minHeight
            } else if imagePickerHeight < ImagePicker.maxHeight - ImagePicker.minHeight {
                height = ImagePicker.minHeight
            } else {
                height = ImagePicker.maxHeight
            }
            self.imagePickerHeightConstraint?.constant = height
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .allowUserInteraction, animations: { 
                self.view.layoutIfNeeded()
            }, completion: nil)
        default:
            break
        }
    }
}

//MARK: UIGestureRecognizerDelegate
extension ViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.imagePicker) == true {
            return false
        }
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        //Ignore horizontal pan gesture
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: self.view)
            return fabs(velocity.y) > fabs(velocity.x)
        }
        return true
    }
}

//MARK: ImagePickerDelegate
extension ViewController : ImagePickerDelegate {
    func didSelectImage(imagePicker: ImagePicker, image: UIImage) {
        FIRAnalytics.logEvent(withName: userChoseAPhotoFromGalleryEvent, parameters: nil)
        self.masksPicker.image = image
    }
    
    func didDeselectImage(imagePicker: ImagePicker) {
        self.masksPicker.image = nil
    }
}

//MARK: UIViewControllerPreviewingDelegate
extension ViewController : UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        FIRAnalytics.logEvent(withName: user3DTouchedPhotoFromGalleryEvent, parameters: nil)
        let point = self.view.convert(location, to: self.imagePicker.collectionView)
        guard let indexPath = self.imagePicker.collectionView.indexPathForItem(at: point),
            let cell = self.imagePicker.collectionView.cellForItem(at: indexPath) else {
            return nil
        }
        let imageId = self.imagePicker.photos[indexPath.item]
        let photoVC = PreviewViewController(photo: PhotosProxy.shared.getPhoto(id: imageId))
        photoVC.rootViewController = self
        previewingContext.sourceRect = cell.frame
        return photoVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) { }
}
