//
//  CaptureButton.swift
//  Layers
//
//  Created by Tal Cohen on 28/02/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Foundation
import UIKit

class CaptureButton : UIView {
    
    let innerCircle : UIButton = {
        let b = UIButton(frame: .zero)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setBackgroundImage(UIImage(named: "captureButtonInner"), for: .normal)
        return b
    }()
    
    let outerCircle : UIImageView = {
        let iv = UIImageView(frame: .zero)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "captureButtonOuter")
        return iv
    }()
    
    let loader : UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()
    
    init() {
        super.init(frame: .zero)
        self.addSubview(self.outerCircle)
        self.addSubview(self.innerCircle)
        self.addSubview(self.loader)
        NSLayoutConstraint.activate([
            self.outerCircle.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.outerCircle.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.outerCircle.topAnchor.constraint(equalTo: self.topAnchor),
            self.outerCircle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.innerCircle.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.innerCircle.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.innerCircle.topAnchor.constraint(equalTo: self.topAnchor),
            self.innerCircle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.loader.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
    }
    
    func startLoading() {
        self.loader.startAnimating()
        self.innerCircle.isEnabled = false
        self.innerCircle.isHidden = true
    }
    
    func stopLoading() {
        self.loader.stopAnimating()
        self.innerCircle.isEnabled = true
        self.innerCircle.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTarget(_ target: Any?, action: Selector) {
        self.innerCircle.addTarget(target, action: action, for: .touchUpInside)
    }
}
