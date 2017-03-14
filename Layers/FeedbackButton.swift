//
//  FeedbackButton.swift
//  Layers
//
//  Created by Tal Cohen on 14/03/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit
import Instabug

class RoundButton : UIButton {
    
    let title : UILabel = {
        let t = UILabel(frame: .zero)
        t.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)
        t.textColor = .white
        t.textAlignment = .center
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    init(size : CGFloat, title: String) {
        super.init(frame: .zero)
        self.addSubview(self.title)
        NSLayoutConstraint.activate([
            self.title.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.title.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        self.title.text = title
        self.layer.cornerRadius = size / 2
        self.backgroundColor = UIColor(white: 0, alpha: 0.7)
    }
    
    override var isHighlighted: Bool {
        didSet {
            switch isHighlighted {
            case true:
                self.title.textColor = .gray
            case false:
                self.title.textColor = .white
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
