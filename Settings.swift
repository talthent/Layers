//
//  Settings.swift
//  Layers
//
//  Created by Tal Cohen on 14/03/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Foundation

class Settings {
    
    static let changeMaskTutorialPlayedKey = "change_mask_tutorial_played"
    
    class func shouldPlayChangeMaskTutorial() -> Bool {
        let played = UserDefaults.standard.bool(forKey: Settings.changeMaskTutorialPlayedKey)
        if !played {
            UserDefaults.standard.set(true, forKey: Settings.changeMaskTutorialPlayedKey)
        }
        return !played
    }
    
}
