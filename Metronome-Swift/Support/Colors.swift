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
    var normalButtonColor: UIColor
    var highlightButtonColor: UIColor
    
    let colorOptions: [String: themeColor] = [
        "red" : themeColor(hue: 355),
        "orange" : themeColor(hue: 24, sat: 80),
        "yellow" : themeColor(hue: 56, sat: 100),
        "green" : themeColor(hue: 90),
        "seafoam" : themeColor(hue: 155),
        "cyan" : themeColor(hue: 184),
        "blue" : themeColor(hue: 210),
        "purple" : themeColor(hue: 255),
        "magenta" : themeColor(hue: 290),
        "grey" : themeColor(hue: 0, sat: 0),
        "black": themeColor(light: UIColor(rgb: 0x292929), dark: UIColor(rgb: 0x0A0A0A))
    ]
    
    struct themeColor {
        var bgColorLight: UIColor!
        var bgColorDark: UIColor!
        
        init(hue: CGFloat) {
            bgColorLight = UIColor(hue: hue/360, saturation: 72.0/100, brightness: 72.0/100, alpha: 1)
            bgColorDark = UIColor(hue: hue/360, saturation: 86.0/100, brightness: 36.0/100, alpha: 1)
        }
        
        init(hue: CGFloat, sat: CGFloat) {
            bgColorLight = UIColor(hue: hue/360, saturation: sat/100, brightness: 77.0/100, alpha: 1)
            bgColorDark = UIColor(hue: hue/360, saturation: sat/100, brightness: 40.0/100, alpha: 1)
        }
        
        init (light: UIColor, dark: UIColor) {
            bgColorLight = light
            bgColorDark = dark
        }
    }
    
    init(_ themeColor: String? = nil) {
        bgColor = UIColor.black
        textColor = UIColor(rgb: 0xFAFAFA)
        beatCircleStartColor = UIColor(rgb: 0xFFFFFF)
        normalButtonColor = UIColor.white.withAlphaComponent(0.15)
        highlightButtonColor = UIColor.white.withAlphaComponent(0.15)
        
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
        let checkTheme = validateColor(newTheme)
        let defaultTheme = UserDefaults.standard.string(forKey: "theme")
        bgTheme = checkTheme ? newTheme : defaultTheme

        print("setting theme \(bgTheme!)")
        
        // set new default
        UserDefaults.standard.set(bgTheme, forKey: "theme")
        bgColorLight = (self.colorOptions[bgTheme]?.bgColorLight)!
        bgColorDark = (self.colorOptions[bgTheme]?.bgColorDark)!
    }
    
    func validateColor(_ color: String) -> Bool {
        let checkTheme = colorOptions.contains { (key, value) -> Bool in
            key == color
        }
        return checkTheme
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
