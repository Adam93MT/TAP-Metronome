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

    
    @IBOutlet weak var GroupsLabel: UILabel!
    
    @IBOutlet weak var twoBeats: BeatGroupButton!
    @IBOutlet weak var threeBeats: BeatGroupButton!
    @IBOutlet weak var fourBeats: BeatGroupButton!
    @IBOutlet weak var sixBeats: BeatGroupButton!
    var BeatGroupButtonsArray = [BeatGroupButton]()
    
    @IBOutlet weak var ColorsLabel: UILabel!
    
    @IBOutlet weak var redButton: ColorPickerButton!
    @IBOutlet weak var orangeButton: ColorPickerButton!
    @IBOutlet weak var yellowButton: ColorPickerButton!
    @IBOutlet weak var greenButton: ColorPickerButton!
    @IBOutlet weak var blueButton: ColorPickerButton!
    @IBOutlet weak var purpleButton: ColorPickerButton!
    @IBOutlet weak var blackButton: ColorPickerButton!
    
    @IBOutlet weak var plusButton: UICircleButton!
    //    var TimeButtonsArray = [BeatNumberButton]()
    var ColorButtonsArray = [ColorPickerButton]()
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
        BeatGroupButtonsArray = [twoBeats, threeBeats, fourBeats, sixBeats]

        twoBeats.setValue(val: 2)
        threeBeats.setValue(val: 3)
        fourBeats.setValue(val: 4)
        sixBeats.setValue(val: 6)
        
        // Color Buttons
        ColorButtonsArray = [redButton, orangeButton, yellowButton, greenButton, blueButton, purpleButton, blackButton]
        
        redButton.setColorStringValue("red")
        orangeButton.setColorStringValue("orange")
        yellowButton.setColorStringValue("yellow")
        greenButton.setColorStringValue("green")
        blueButton.setColorStringValue("blue")
        purpleButton.setColorStringValue("purple")
        blackButton.setColorStringValue("black")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createGradientLayer()
        for btn in ColorButtonsArray {
            btn.createGradientLayer()
        }
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
    
    @IBAction func pressedGroupButton(_ sender: BeatGroupButton) {
        for button in BeatGroupButtonsArray {
            button.isPicked = false
        }
        sender.isPicked = true
    }
    
    // Press Color Buttons
    @IBAction func pressedColorButton(_ sender: ColorPickerButton) {
        for cbtn in ColorButtonsArray {
            if cbtn != sender {cbtn.isPicked = false}
        }
        sender.isPicked = true
        updateUIColor()
    }
    
    func updateUIColor() {
        self.view.backgroundColor = Globals.colors.bgColorLight
        self.gradientLayer.gl.removeFromSuperlayer()
        self.createGradientLayer()
        for button in BeatGroupButtonsArray {
            button.setColors()
        }
    }
    
    func createGradientLayer() {
        // Set up the background colors
        self.gradientLayer.setColors(startColor: Globals.colors.bgColorLight, endColor: Globals.colors.bgColorDark)
        self.gradientLayer.gl.frame = self.view.bounds
        self.view.layer.insertSublayer(self.gradientLayer.gl, at: 0)
    }

    @IBAction func pressAddButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Coming Soon!", message: "Soon you'll be able to add your own custom colours.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
