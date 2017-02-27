//
//  UIImageViewExtension.swift
//  Continuously
//
//  Created by Tal Cohen on 23/02/17.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    enum RenderMaskedImageError : Error {
        case noContext
        case emptyContexy
    }
    
    func renderMaskedImage() throws -> UIImage  {
        UIGraphicsBeginImageContext(UIScreen.main.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            throw RenderMaskedImageError.noContext
        }
        self.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            throw RenderMaskedImageError.emptyContexy
        }
        UIGraphicsEndImageContext()
        return image
    }
    
}
