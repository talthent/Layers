//
//  MasksPicker.swift
//  Layers
//
//  Created by Tal Cohen on 27/02/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit

class MasksPicker: UIImageView {
    
    var selectedMask = 0
    
    var masks = [UIImage]()
    
    init() {
        var i = 0
        var nextMask = UIImage(named: "m\(i)")
        while nextMask != nil {
            self.masks.append(nextMask!)
            i += 1
            nextMask = UIImage(named: "m\(i)")
        }
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
        maskLayer.contents = self.masks[self.selectedMask].cgImage
        maskLayer.frame = self.bounds
        self.layer.mask = maskLayer
        self.layer.masksToBounds = true
    }
}
