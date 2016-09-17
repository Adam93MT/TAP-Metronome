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
    
    //-- Deprecated
//    @IBOutlet weak var tempoStepper: UIStepper!
//    @IBOutlet var metronomePlayButton: UIButton!
    var beatCircleView: BeatCircleView!
    
    var BeatViewsArray : [BeatView] = []
    var metronomeDisplayLink: CADisplayLink!
    
    let metronome = Metronome()
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

    @IBAction func tapDown(sender: UIButton) {
        if metronome.isOn {
            metronome.stop()
            stopUI()
        }
        else // Metronome is off
        {
            if !metronome.isPrepared {
                metronome.prepare()
            }
            println("Tempo: \(metronome.tempo)")
            metronome.start()
            startUI()
        }
    }
    @IBAction func tapUp(sender: UIButton) {

    }
    func startUI() {
        
        tempoSlider.enabled = false            // Disable the metronome stepper.
        tempoLabel.enabled = false          // Disable editing the tempo text field.
        
//        for var b = 0;  b < metronome.timeSignature; b++
//        {
//            BeatViewsArray.append(BeatView())
//            view.addSubview(BeatViewsArray[b])
//        }
    }
    
    func stopUI() {
//        for var b = 0;  b < metronome.timeSignature; b++
//        {
//            BeatViewsArray[b].removeFromSuperview()
//        }
//        BeatViewsArray.removeAll()
        
        tapButton.enabled = true
        tapButton.hidden = false
        
        // Enable the metronome stepper.
        tempoSlider.enabled = true
    }
    
    func animateBeatCircle() {
        println("Animating Beat Circle")
        //BeatViewsArray[beat - 1].animateBeatCircle(metronomeTimer)
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
        
        view.backgroundColor = backgroundColor
        
        // Set the inital value of the tempo.
        metronome.tempo = 120
        metronome.timeSignature = 4
        tempoLabel.text = String(metronome.tempo)
        tempoSlider.value = Float(metronome.tempo)
        tempoSlider.enabled = true

        metronome.prepare()
        
//        var myBeatView = BeatView()
//        view.addSubview(myBeatView)
//        var myTimeInterval: NSTimeInterval = 1
//        myBeatView.animateBeatCircle(myTimeInterval)
    }
    
    override func viewDidAppear(animated: Bool) {
//        beatCircleView.animateBeatCircle(metronome.timeInterval)
    }
    
    // MARK: - UIResponder
}

