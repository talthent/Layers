//
//  AppDelegate.swift
//  Layers
//
//  Created by Tal Cohen on 23/02/17.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit
import Instabug
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        FIRApp.configure()
        Instabug.start(withToken: "0d279019d277a82f410e3ef3c5b74c9e", invocationEvent: .none)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = ViewController(nibName: nil, bundle: nil)
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        PhotosProxy.shared.loadPhotos()
    }
    
}

