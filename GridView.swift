//
//  GridView.swift
//  Layers
//
//  Created by Tal Cohen on 07/03/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit

class GridView: UIView {
    
    override func draw(_ rect: CGRect) {
        let verticalLine1 = UIBezierPath()
        verticalLine1.move(to: CGPoint(x: rect.width / 3, y: 0))
        verticalLine1.addLine(to: CGPoint(x: rect.width / 3, y: rect.height))
        verticalLine1.close()
        
        let verticalLine2 = UIBezierPath()
        verticalLine2.move(to: CGPoint(x: rect.width / 3 * 2, y: 0))
        verticalLine2.addLine(to: CGPoint(x: rect.width / 3 * 2, y: rect.height))
        verticalLine2.close()
        
        let horizontalLine1 = UIBezierPath()
        horizontalLine1.move(to: CGPoint(x: 0, y: rect.height / 3))
        horizontalLine1.addLine(to: CGPoint(x: rect.width, y: rect.height / 3))
        horizontalLine1.close()
        
        let horizontalLine2 = UIBezierPath()
        horizontalLine2.move(to: CGPoint(x: 0, y: rect.height / 3 * 2))
        horizontalLine2.addLine(to: CGPoint(x: rect.width, y: rect.height / 3 * 2))
        horizontalLine2.close()
        
        UIColor.white.set()
        verticalLine1.stroke()
        verticalLine2.stroke()
        horizontalLine1.stroke()
        horizontalLine2.stroke()
    }
}
