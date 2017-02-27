//
//  MasksPicker.swift
//  Continuously
//
//  Created by Tal Cohen on 27/02/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit

class MasksPicker: UIImageView {
    
    var selectedMask = 0
    
    let masks = [
        UIImage(named: "m1"),
        UIImage(named: "m2"),
        UIImage(named: "m3"),
        UIImage(named: "m4"),
        UIImage(named: "m5"),
        UIImage(named: "m6"),
        UIImage(named: "m7")
    ]
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.contentMode = .scaleAspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeMask() {
        self.selectedMask = self.selectedMask + 1 == self.masks.count ? 0 : self.selectedMask + 1
        self.createMask()
    }
    
    func createMask() {
        let maskLayer = CALayer()
        maskLayer.contents = self.masks[self.selectedMask]?.cgImage
        maskLayer.frame = self.bounds
        self.layer.mask = maskLayer
        self.layer.masksToBounds = true
    }
}
