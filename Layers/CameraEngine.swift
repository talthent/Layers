//
//  CameraEngine.swift
//  Layers
//
//  Created by Tal Cohen on 21/02/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit
import AVFoundation

class CameraEngine : NSObject {
    
    fileprivate var captureSession = AVCaptureSession()
    fileprivate let stillImageOutput = AVCaptureStillImageOutput()
    fileprivate var previewLayer : AVCaptureVideoPreviewLayer?
    fileprivate var captureDevice : AVCaptureDevice?
    
    override init() {
        super.init()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        self.captureDevice = self.findCamera(type: .back)
    }
    
    private func findCamera(type: AVCaptureDevicePosition) -> AVCaptureDevice? {
        if let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] {
            let cameras = devices.filter{ return $0.hasMediaType(AVMediaTypeVideo) && $0.position == type}
            if cameras.first != nil {
                print("Capture device found")
            } else {
                fatalError()
            }
            return cameras.first
        }
        return nil
    }
    
    func flipCamera() {
        if self.captureDevice?.position == .back {
            self.captureDevice = self.findCamera(type: .front)
        } else {
            self.captureDevice = self.findCamera(type: .back)
        }
        self.stop()
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return self.previewLayer
    }
    
    func stop() {
        self.captureSession.stopRunning()
        self.captureSession = AVCaptureSession()
        self.previewLayer?.removeFromSuperlayer()
        self.previewLayer = nil
    }
    
    func start() {
        
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
        
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else {
            print("no preview layer")
            return
        }
        self.previewLayer = previewLayer
        captureSession.startRunning()
    }
    
    //MARK: ACTIONS
    func captureAndMerge(maskedImage: UIImage) {
        self.capture(success: { (image) in
            
            UIGraphicsBeginImageContext(image.size)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            maskedImage.draw(in: CGRect(origin: .zero, size: image.size))
            let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if mergedImage != nil {
                self.saveImageToDisk(image: mergedImage)
            }
            
        }, failure: nil)
    }
    
    func captureAndSave() {
        self.capture(success: { (image) in
            self.saveImageToDisk(image: image)
        }, failure: nil)
    }
    
    fileprivate func capture(success: ((UIImage)->())?, failure: (()->())?) {
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (CMSampleBuffer, Error) in
                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(CMSampleBuffer) {
                    if let cameraImage = UIImage(data: imageData) {
                        success?(cameraImage)
                    } else {
                        failure?()
                    }
                }
            })
        }
    }
    
    fileprivate func saveImageToDisk(image: UIImage?) {
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            PhotosProxy.shared.loadPhotos()
        }
    }
    
}
