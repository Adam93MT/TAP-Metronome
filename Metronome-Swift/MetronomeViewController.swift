//
//  MetronomeViewController.swift
//  Metronome-Swift
//
//  Created by Adam Thompson on 12/23/15.
//  Copyright (c) 2015 Adam Thompson. All rights reserved.
//

import UIKit
import CoreFoundation
import Dispatch

class MetronomeViewController: UIViewController {
    
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var timeSignatureButton: UIButton!

     // The superView containing all animating Circles
    //@IBOutlet weak var beatCircleView: BeatCircleView!
    var beatCircleView: BeatCircleView!
    
    let metronome = Metronome()
    var metronomeDisplayLink: CADisplayLink!
    
    
    // Colours
    let backgroundColor = UIColor(red:0.04, green: 0.04, blue: 0.04, alpha: 1)
    let sliderColor = UIColor(red: 0.059, green: 0.059, blue: 0.059, alpha: 1)
    let sliderColorPressed = UIColor(red: 0.095, green: 0.095, blue: 0.095, alpha: 1)
    let tempoLabelColor = UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1)
    let tempoLabelColorPressed = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)

    @IBAction func tempoSliderChanged(sender: UISlider) {
        println("Slider Value: \(tempoSlider.value)")
        metronome.tempo = Int(tempoSlider.value) // Save the new tempo.
        tempoLabel.text = String(metronome.tempo)
        metronome.prepare()
    }
    
    @IBAction func swipeButton(sender: UIButton) {
        if metronome.isOn {
            self.stopMetronome()
        }
         // else ignore
        
    }

    @IBAction func tapDown(sender: UIButton) {
        if metronome.isOn == false {
            self.startMetronome()
        }
        else //is On 
        {
            // Log tempo
            metronome.logTap()
        }
        
    }
    @IBAction func tapUp(sender: UIButton) {

    }
    
    func toggleMetronome() {
        if metronome.isOn {
            self.stopMetronome()
        }
        else // Metronome is off
        {
            self.startMetronome()
        }
    }
    
    func startMetronome() {
        if !metronome.isPrepared {
            metronome.prepare()
        }
        println("Tempo: \(metronome.tempo)")
        metronome.start()
        startUI()
    }
    
    func stopMetronome() {
        metronome.stop()
        stopUI()
    }
    
    func startUI() {
        tempoSlider.enabled = false            // Disable the metronome stepper.
        tempoLabel.enabled = false          // Disable editing the tempo text field.
    }
    
    func stopUI() {
        tapButton.enabled = true
        tapButton.hidden = false
        // Enable the metronome stepper.
        tempoSlider.enabled = true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // Hide the keyboard
        tempoLabel.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var viewWidth = view.frame.width
        var viewHeight = view.frame.height
        println("Height: \(viewHeight), Width: \(viewWidth)")
        
        beatCircleView = BeatCircleView(frame: CGRectMake(0, 0, viewWidth, viewHeight))
        beatCircleView.center = view.center
        view.addSubview(beatCircleView)
        view.sendSubviewToBack(beatCircleView)
        metronome.parentViewController = self
        
        tapButton.frame.size = CGSizeMake(viewWidth, viewWidth);
        tapButton.contentEdgeInsets = UIEdgeInsetsMake(viewWidth/2, viewWidth/2, viewWidth/2, viewWidth/2);
        view.bringSubviewToFront(tapButton)
        
        view.backgroundColor = backgroundColor
        
        // Set the inital value of the tempo.
        metronome.tempo = 100
        metronome.timeSignature = 4
        tempoLabel.text = String(metronome.tempo)
        tempoSlider.value = Float(metronome.tempo)
        tempoSlider.enabled = true

        metronome.prepare()
        
        //self.startMetronome()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    // MARK: - UIResponder
}

