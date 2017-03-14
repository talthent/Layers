
//
//  ChangeMaskTutorial.swift
//  Layers
//
//  Created by Tal Cohen on 14/03/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit

class ChangeMaskTutorial : UIView {
    
    var timer : Timer?
    
    let title : UILabel = {
        let l = UILabel(frame: .zero)
        l.text = "TAP THE SCREEN\nTO CHANGE MASK"
        l.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightUltraLight)
        l.textColor = UIColor(white: 1, alpha: 0.6)
        l.sizeToFit()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.alpha = 0
        return l
    }()
    
    init() {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        self.addSubview(self.title)
        NSLayoutConstraint.activate([
            self.title.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.title.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.title.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -40)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(stop), userInfo: nil, repeats: false)
        UIView.animate(withDuration: 0.5) { 
            self.title.alpha = 1
            self.backgroundColor = UIColor(white: 0, alpha: 0.8)
        }
    }
    
    func stop() {
        self.timer?.invalidate()
        self.timer = nil
        UIView.animate(withDuration: 0.5) {
            self.title.alpha = 0
            self.backgroundColor = .clear
        }
    }
    
}
