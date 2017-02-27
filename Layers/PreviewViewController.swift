//
//  PreviewViewController.swift
//  Layers
//
//  Created by Tal Cohen on 27/02/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit

class PreviewViewController : UIViewController {
    var photo : Photo?
    var imageView = UIImageView()
    weak var rootViewController : UIViewController?
    
    override var previewActionItems: [UIPreviewActionItem] {
        return [
            UIPreviewAction(title: "Share", style: .default, handler: { (action, viewController) in
                self.photo?.getImage(completionBlock: { (image) in
                    guard let image = image else {
                        return
                    }
                    let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    self.rootViewController?.present(activityViewController, animated: true, completion: nil)
                })
            })]
    }
    
    init(photo: Photo?) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.imageView)
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
        
        self.photo?.getImage(completionBlock: { (image) in
            self.imageView.image = image
        })
    }
}
