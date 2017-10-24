//
//  UserDefaultsManager.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-23.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    private static let useDarkThemeKey = "useDarkThemeKey"
    
    static var useDarkTheme: Bool {
        get {
            return UserDefaults.standard.bool(forKey: useDarkThemeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: useDarkThemeKey)
        }
    }
}
