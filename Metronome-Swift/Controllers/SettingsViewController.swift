//
//  SettingsViewController.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-23.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var BeatsLabel: UILabel!
    @IBOutlet weak var ColorsLabel: UILabel!
    
    @IBOutlet weak var twoBeats: BeatNumberButton!
    @IBOutlet weak var threeBeats: BeatNumberButton!
    @IBOutlet weak var fourBeats: BeatNumberButton!
    @IBOutlet weak var sixBeats: BeatNumberButton!
    
    @IBOutlet weak var redButton: UICircleButton!
    @IBOutlet weak var orangeButton: UICircleButton!
    @IBOutlet weak var yellowButton: UICircleButton!
    @IBOutlet weak var greenButton: UICircleButton!
    @IBOutlet weak var blueButton: UICircleButton!
    @IBOutlet weak var purpleButton: UICircleButton!
    @IBOutlet weak var blackButton: UICircleButton!
    
    var TimeButtonsArray = [BeatNumberButton]()
    var ColorButtonsArray = [UICircleButton]()
    let borderWidth:CGFloat = 2
    let borderColor = UIColor.white.cgColor
    let gradientLayer = GradientView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onSettingsPage = true
        self.setNeedsStatusBarAppearanceUpdate()
        self.view.backgroundColor = Globals.colors.bgColorLight
        // Do any additional setup after loading the view.
        
        // Beats Buttons
        TimeButtonsArray = [twoBeats, threeBeats, fourBeats, sixBeats]
        
        switch delegate.metronome.getTimeSignature() {
        case 2:
            twoBeats.layer.borderWidth = borderWidth
            twoBeats.layer.borderColor = borderColor
        case 3:
            threeBeats.layer.borderWidth = borderWidth
            threeBeats.layer.borderColor = borderColor
        case 4:
            fourBeats.layer.borderWidth = borderWidth
            fourBeats.layer.borderColor = borderColor
        case 6:
            sixBeats.layer.borderWidth = borderWidth
            sixBeats.layer.borderColor = borderColor
        default:
            twoBeats.layer.borderWidth = borderWidth
            twoBeats.layer.borderColor = borderColor
        }
        
        // Color Buttons
        ColorButtonsArray = [redButton, orangeButton, yellowButton, greenButton, blueButton, purpleButton, blackButton]
        
        // set buton colors
        redButton.setDefaultColor(defaultColor: (Globals.colors.colorOptions["red"]?.bgColorLight)!)
        orangeButton.setDefaultColor(defaultColor: (Globals.colors.colorOptions["orange"]?.bgColorLight)!)
        yellowButton.setDefaultColor(defaultColor: (Globals.colors.colorOptions["yellow"]?.bgColorLight)!)
        greenButton.setDefaultColor(defaultColor: (Globals.colors.colorOptions["green"]?.bgColorLight)!)
        blueButton.setDefaultColor(defaultColor: (Globals.colors.colorOptions["blue"]?.bgColorLight)!)
        purpleButton.setDefaultColor(defaultColor: (Globals.colors.colorOptions["purple"]?.bgColorLight)!)
        blackButton.setDefaultColor(defaultColor: (Globals.colors.colorOptions["black"]?.bgColorLight)!)
        
        switch Globals.colors.bgTheme {
            case "red":
                redButton.layer.borderWidth = borderWidth
                redButton.layer.borderColor = borderColor
            case "orange":
                orangeButton.layer.borderWidth = borderWidth
                orangeButton.layer.borderColor = borderColor
            case "yellow":
                yellowButton.layer.borderWidth = borderWidth
                yellowButton.layer.borderColor = borderColor
            case "green":
                greenButton.layer.borderWidth = borderWidth
                greenButton.layer.borderColor = borderColor
            case "blue":
                blueButton.layer.borderWidth = borderWidth
                blueButton.layer.borderColor = borderColor
            case "purple":
                purpleButton.layer.borderWidth = borderWidth
                purpleButton.layer.borderColor = borderColor
            default:
                blackButton.layer.borderWidth = borderWidth
                blackButton.layer.borderColor = borderColor
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createGradientLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onSettingsPage = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Press Beat Buttons
    @IBAction func selectTwoBeats(_ sender: BeatNumberButton) {
        UserDefaults.standard.set(2, forKey: "timeSignature")
        delegate.metronome.setTimesignature(2)
        updateUITime(sender)
    }
    @IBAction func selectThreeBeats(_ sender: BeatNumberButton) {
        UserDefaults.standard.set(3, forKey: "timeSignature")
        delegate.metronome.setTimesignature(3)
        updateUITime(sender)
    }
    @IBAction func selectFourBeats(_ sender: BeatNumberButton) {
        UserDefaults.standard.set(4, forKey: "timeSignature")
        delegate.metronome.setTimesignature(4)
        updateUITime(sender)
    }
    @IBAction func selectSixBeats(_ sender: BeatNumberButton) {
        UserDefaults.standard.set(6, forKey: "timeSignature")
        delegate.metronome.setTimesignature(6)
        updateUITime(sender)
    }
    
    // Press Color Buttons
    @IBAction func selectRed(_ sender: Any) {
        Globals.colors.setTheme("red")
        self.updateUIColor()
        redButton.layer.borderWidth = borderWidth
        redButton.layer.borderColor = borderColor
    }
    @IBAction func selectOrange(_ sender: Any) {
        Globals.colors.setTheme("orange")
        self.updateUIColor()
        orangeButton.layer.borderWidth = borderWidth
        orangeButton.layer.borderColor = borderColor
    }
    @IBAction func selectYellow(_ sender: Any) {
        Globals.colors.setTheme("yellow")
        self.updateUIColor()
        yellowButton.layer.borderWidth = borderWidth
        yellowButton.layer.borderColor = borderColor
    }
    @IBAction func selectGreen(_ sender: Any) {
        Globals.colors.setTheme("green")
        self.updateUIColor()
        greenButton.layer.borderWidth = borderWidth
        greenButton.layer.borderColor = borderColor
    }
    @IBAction func selectBlue(_ sender: Any) {
        Globals.colors.setTheme("blue")
        self.updateUIColor()
        blueButton.layer.borderWidth = borderWidth
        blueButton.layer.borderColor = borderColor
    }
    @IBAction func selectPurple(_ sender: Any) {
        Globals.colors.setTheme("purple")
        self.updateUIColor()
        purpleButton.layer.borderWidth = borderWidth
        purpleButton.layer.borderColor = borderColor
    }
    @IBAction func selectBlack(_ sender: Any) {
        Globals.colors.setTheme("black")
        self.updateUIColor()
        blackButton.layer.borderWidth = borderWidth
        blackButton.layer.borderColor = borderColor
    }
    
    func updateUIColor() {
        self.view.backgroundColor = Globals.colors.bgColorLight
        self.gradientLayer.gl.removeFromSuperlayer()
        self.createGradientLayer()
        for button in ColorButtonsArray {
            button.layer.borderWidth = 0
            button.layer.borderColor = UIColor.clear.cgColor
        }
        for button in TimeButtonsArray {
            button.setColor(Globals.colors.bgColorLight)
        }
    }
    
    func updateUITime(_ thisButton: BeatNumberButton) {
        for button in TimeButtonsArray {
            button.layer.borderWidth = 0
            button.layer.borderColor = UIColor.clear.cgColor
        }
        thisButton.layer.borderWidth = borderWidth
        thisButton.layer.borderColor = borderColor
    }
    
    
    func createGradientLayer() {
        // Set up the background colors
        self.gradientLayer.setColors(startColor: Globals.colors.bgColorLight, endColor: Globals.colors.bgColorDark)
        self.gradientLayer.setLocations(start: 0.0, end: 0.5)
        self.gradientLayer.gl.frame = self.view.bounds
        self.view.layer.insertSublayer(self.gradientLayer.gl, at: 0)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
