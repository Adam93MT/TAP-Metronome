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
    var currentTheme: themeColor!
    var textColor: UIColor
    var beatCircleStartColor: UIColor
    var normalButtonColor: UIColor
    var highlightButtonColor: UIColor
    
//    enum colorOptions : themeColor {
//        case red = themeColor(hue: 355)
//        case orange = themeColor(hue: 24, sat: 80)
//        case yellow = themeColor(hue: 24, sat: 80)
//        case green = themeColor(hue: 90)
//        case seafoam = themeColor(hue: 155)
//        case cyan = themeColor(hue: 184)
//        case blue = themeColor(hue: 210)
//        case purple = themeColor(hue: 255)
//        case grey = themeColor(hue: 0, sat: 0)
//        case black = themeColor(light: UIColor(rgb: 0x292929), dark: UIColor(rgb: 0x0A0A0A))
//    }
    
    static let colorOptions: [themeColor] = [
        themeColor("red", hue: 355),
        themeColor("orange", hue: 24, sat: 80),
//        themeColor("yellow", hue: 56, sat: 100),
//        themeColor("green", hue: 90),
        themeColor("seafoam", hue: 155),
        themeColor("cyan", hue: 184),
        themeColor("blue", hue: 210),
        themeColor("purple", hue: 255),
//        themeColor("magenta", hue: 290),
        themeColor("grey", hue: 0, sat: 0),
        themeColor("black", light: UIColor(rgb: 0x292929), dark: UIColor(rgb: 0x0A0A0A))
    ]
    
    struct themeColor {
        var Name: String?
        var Light: UIColor!
        var Dark: UIColor!
        
        init(_ name: String, hue: CGFloat) {
            Name = name
            Light = UIColor(hue: hue/360, saturation: 72.0/100, brightness: 72.0/100, alpha: 1)
            Dark = UIColor(hue: hue/360, saturation: 86.0/100, brightness: 36.0/100, alpha: 1)
        }
        
        init(_ name: String, hue: CGFloat, sat: CGFloat) {
            Name = name
            Light = UIColor(hue: hue/360, saturation: sat/100, brightness: 77.0/100, alpha: 1)
            Dark = UIColor(hue: hue/360, saturation: sat/100, brightness: 40.0/100, alpha: 1)
        }
        
        init (_ name: String, light: UIColor, dark: UIColor) {
            Name = name
            Light = light
            Dark = dark
        }
    }
    
    init(_ themeColor: String? = nil) {
        bgColor = UIColor.black
        textColor = UIColor(rgb: 0xFAFAFA)
        beatCircleStartColor = UIColor(rgb: 0xFFFFFF)
        normalButtonColor = UIColor.white.withAlphaComponent(0.15)
        highlightButtonColor = UIColor.white.withAlphaComponent(0.5)
        
        // check if the default theme is legit
        var defaultTheme = UserDefaults.standard.string(forKey: "theme")
        let checkTheme = (defaultTheme != nil) ? globalColors.validateColor(defaultTheme!) : false
        defaultTheme = checkTheme ? defaultTheme : "black"
        print("Theme: \(defaultTheme!)")

        // set the theme to the set color, fallback to the default
        let themeName = (themeColor != nil) ? themeColor : defaultTheme
        UserDefaults.standard.set(themeName, forKey: "theme")
        
        currentTheme = globalColors.getColorOption(themeName!)
        
    }
    
    func setTheme(_ newTheme: String) {
        // if the new theme is legit, set it, otherwise fall back on the default
        let checkTheme = globalColors.validateColor(newTheme)
        let defaultTheme = UserDefaults.standard.string(forKey: "theme")
        let themeName = checkTheme ? newTheme : defaultTheme

        print("Setting theme \(themeName!)")
        
        currentTheme = globalColors.getColorOption(themeName!)
        
        // set new default
        UserDefaults.standard.set(themeName, forKey: "theme")
    }
    
    static func validateColor(_ withName: String) -> Bool {
        let check = globalColors.colorOptions.contains(where: {$0.Name == withName})
        return check
    }
    
    static func getColorOption(_ withName: String) -> themeColor {
        let idx = globalColors.colorOptions.index(where: {$0.Name == withName})
        return globalColors.colorOptions[idx!]
    }
    
    static func getColorName(withID: Int) -> String {
        return globalColors.colorOptions[withID].Name!
    }
    
    static func getIndexOfColorOption(_ withName: String) -> Int {
        let idx = globalColors.colorOptions.index(where: {$0.Name == withName})
        return idx!
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
    
    func withPseudoAlphaComponent(pseudoAlpha: CGFloat) -> UIColor {
        let baseColor = self
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        baseColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let newSaturation = pow(1 - pseudoAlpha, 1.25) * (saturation)
        let newBrightness = 1 - ((1 - pseudoAlpha) * (1 - brightness))
        
        return UIColor(hue: hue, saturation: newSaturation, brightness: newBrightness, alpha: 1.0)
        
    }
}
