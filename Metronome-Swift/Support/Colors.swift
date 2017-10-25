//
//  Colors.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-23.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class globalColors {
    var bgColor: UIColor
    var bgTheme: String!
    var bgColorLight: UIColor
    var bgColorDark: UIColor
    var textColor: UIColor
    var beatCircleStartColor: UIColor
    
    struct themeColor {
        var bgColorLight: UIColor!
        var bgColorDark: UIColor!
        
        init(_ light: UIColor, _ dark: UIColor) {
            bgColorLight = light
            bgColorDark = dark
        }
    }
    
    let colorOptions: [String: themeColor] = [
        "red": themeColor(UIColor(rgb: 0xF5515F), UIColor(rgb: 0x9F041B)),
        "orange": themeColor(UIColor(rgb: 0xFF875C), UIColor(rgb: 0xF2480A)),
        "yellow": themeColor(UIColor(rgb: 0xFAD961), UIColor(rgb: 0xF76B1C)),
        "green": themeColor(UIColor(rgb: 0xB4EC51), UIColor(rgb: 0x429321)),
        "blue": themeColor(UIColor(rgb: 0x1D478C), UIColor(rgb: 0x13305D)),
        "purple": themeColor(UIColor(rgb: 0x7A51F5), UIColor(rgb: 0x20039E)),
        "black": themeColor(UIColor(rgb: 0x1B1B1B), UIColor(rgb: 0x040404))
    ]
    
    init(_ themeColor: String? = nil) {
        bgColor = UIColor.black
        textColor = UIColor(rgb: 0xFAFAFA)
        beatCircleStartColor = UIColor(rgb: 0xFFFFFF)
        
        // check if the default theme is legit
        var defaultTheme = UserDefaults.standard.string(forKey: "theme")
        let checkTheme = colorOptions.contains { (key, value) -> Bool in
            key == defaultTheme
        }
        defaultTheme = checkTheme ? defaultTheme : "black"
        print("Theme: \(defaultTheme!)")
        
        // set the theme to the set color, fallback to the default
        bgTheme = (themeColor != nil) ? themeColor : defaultTheme
        UserDefaults.standard.set(defaultTheme, forKey: "theme")
        bgColorLight = (self.colorOptions[bgTheme]?.bgColorLight)!
        bgColorDark = (self.colorOptions[bgTheme]?.bgColorDark)!
    }
    
    func setTheme(_ newTheme: String) {
        // if the new theme is legit, set it, otherwise fall back on the default
        
        let checkTheme = colorOptions.contains { (key, value) -> Bool in
            key == newTheme
        }
        bgTheme = checkTheme ? newTheme : UserDefaults.standard.string(forKey: "theme")

        print("setting theme \(bgTheme!)")
        
        // set new default
        UserDefaults.standard.set(newTheme, forKey: "theme")
        bgColorLight = (self.colorOptions[bgTheme]?.bgColorLight)!
        bgColorDark = (self.colorOptions[bgTheme]?.bgColorDark)!
    }
}



extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
