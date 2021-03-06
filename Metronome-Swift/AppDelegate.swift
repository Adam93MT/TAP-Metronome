//
//  AppDelegate.swift
//  Metronome-Swift
//
//  Created by Adam Thompson on 10/7/14.
//  Copyright (c) 2015 Adam Thompson. All rights reserved.
//

import UIKit

let Defaults: UserDefaults = UserDefaults.standard

struct globalMeasures {
    var buttonHeight: CGFloat
    var minPadding: CGFloat
    var minButtonSpacing: CGFloat
    
    init() {
        buttonHeight = 48
        minPadding = 16
        minButtonSpacing = 12
    }
    
}

struct Globals {
    static let kBipDurationSeconds: Double = 0.04
    static let kTempoChangeResponsivenessSeconds: Double = 0.250
    static var colors = globalColors(Defaults.string(forKey: "bgTheme"))
    static var dimensions = globalMeasures()
}

var tempoModalisVisible: Bool = false
var onSettingsPage: Bool = false
var originalOrientation: String = ""
let VersionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String?
let BuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"]  as? String

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let metronome: AVMetronome = AVMetronome()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Disable screen turning off
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Navbar colors
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = Globals.colors.textColor
        
        let lastVersion = UserDefaults.standard.string(forKey: "lastVersion")
        let lastBuild = UserDefaults.standard.string(forKey: "lastBuild")
        
        if !(lastVersion == VersionNumber && lastBuild == BuildNumber) {
            UserDefaults.standard.set(true, forKey: "showTutorial")
            UserDefaults.standard.set(VersionNumber, forKey: "lastVersion")
            UserDefaults.standard.set(BuildNumber, forKey: "lastBuild")
        } else {
            UserDefaults.standard.set(false, forKey: "showTutorial")
        }
        // DEBUG 
//        UserDefaults.standard.set(true, forKey: "showTutorial")
        
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

