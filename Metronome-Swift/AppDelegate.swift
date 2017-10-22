//
//  AppDelegate.swift
//  Metronome-Swift
//
//  Created by Adam Thompson on 10/7/14.
//  Copyright (c) 2015 Adam Thompson. All rights reserved.
//

import UIKit

struct globalColors {
    var bgColor: UIColor
    var bgTheme: String!
    var bgColorLight: UIColor
    var bgColorDark: UIColor
    var textColor: UIColor
    var beatCircleStartColor: UIColor
    
    init(_ themeColor: String? = nil) {
        bgColor = UIColor.black
        bgTheme = (themeColor != nil) ? themeColor : ""
        textColor = UIColor(rgb: 0xFAFAFA)
        beatCircleStartColor = UIColor(rgb: 0xFFFFFF)
        switch bgTheme {
            case "red":
                bgColorLight = UIColor(rgb: 0xF5515F)
                bgColorDark = UIColor(rgb: 0x9F041B)
            case "orange":
                bgColorLight = UIColor(rgb: 0xFF875C)
                bgColorDark = UIColor(rgb: 0xF2480A)
            case "yellow":
                bgColorLight = UIColor(rgb: 0xFAD961)
                bgColorDark = UIColor(rgb: 0xF76B1C)
            case "green":
                bgColorLight = UIColor(rgb: 0xB4EC51)
                bgColorDark = UIColor(rgb: 0x429321)
            case "blue":
                bgColorLight = UIColor(rgb: 0x1D478C)
                bgColorDark = UIColor(rgb: 0x13305D)
            case "purple":
                bgColorLight = UIColor(rgb: 0x7A51F5)
                bgColorDark = UIColor(rgb: 0x20039E)
            default:
                bgColorLight = UIColor(rgb: 0x1B1B1B) // default to black
                bgColorDark = UIColor(rgb: 0x040404)
        }
        
    }
}

struct globalMeasures {
    var buttonHeight: CGFloat
    
    init() {
        buttonHeight = 48
    }
    
}

struct Globals {
    static let kBipDurationSeconds: Double = 0.020
    static let kTempoChangeResponsivenessSeconds: Double = 0.250
    static let colors = globalColors()
    static let dimensions = globalMeasures()
}

var tempoModalisVisible: Bool = false


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let metronome: AVMetronome = AVMetronome()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

func dismissedTempoModal() {
    tempoModalisVisible = false
}

func enteredTempoModal() {
    tempoModalisVisible = true
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

