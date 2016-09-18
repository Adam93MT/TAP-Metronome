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
    let sliderMinColor = UIColor(red: 0.353, green: 0.353, blue: 0.353, alpha: 1)
    let sliderMaxColor = UIColor(red: 0.211, green: 0.211, blue: 0.211, alpha: 1)
    let sliderThumbColor = UIColor(red: 0.706, green: 0.706, blue: 0.706, alpha: 1)
    let tempoLabelColor = UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1)
    let tempoLabelColorPressed = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)

    @IBAction func tempoSliderChanged(_ sender: UISlider) {
        print("Slider Value: \(tempoSlider.value)")
        metronome.setTempo(newTempo: Int(tempoSlider.value))
        tempoLabel.text = String(metronome.tempo)
        metronome.prepare()
    }
    
    @IBAction func swipeButton(_ sender: UIButton) {
        if metronome.isOn {
            self.stopMetronome()
        }
         // else ignore
        
    }

    @IBAction func tapDown(_ sender: UIButton) {        
        if metronome.isOn == false {
            self.startMetronome()
        }
        else {
            // Log tempo
            metronome.logTap()
        }
        
    }
    @IBAction func tapUp(_ sender: UIButton) {

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
        print("Tempo: \(metronome.tempo)")
        metronome.start()
        startUI()
    }
    
    func stopMetronome() {
        metronome.stop()
        stopUI()
    }
    
    func startUI() {
//        tempoSlider.isEnabled = false
        tempoLabel.isEnabled = false
//        UIView.animate(withDuration: 0.2, animations: {() -> Void in
//            self.tempoSlider.alpha = 0.4
//        })
    }
    
    func stopUI() {
        tapButton.isEnabled = true
        tapButton.isHidden = false
        // Enable the metronome stepper.
        tempoSlider.isEnabled = true
//        UIView.animate(withDuration: 0.2, animations: {() -> Void in
//            self.tempoSlider.alpha = 1
//        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        print("Height: \(viewHeight), Width: \(viewWidth)")
        
        beatCircleView = BeatCircleView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
        beatCircleView.center = view.center
        view.addSubview(beatCircleView)
        view.sendSubview(toBack: beatCircleView)
        metronome.parentViewController = self
        
        tapButton.frame.size = CGSize(width: viewWidth, height: viewWidth);
        tapButton.contentEdgeInsets = UIEdgeInsetsMake(viewWidth/2, viewWidth/2, viewWidth/2, viewWidth/2);
        view.bringSubview(toFront: tapButton)
        
        view.backgroundColor = backgroundColor
        
        // Set the inital value of the tempo.
        metronome.tempo = 100
        metronome.timeSignature = 4
        tempoLabel.text = String(metronome.tempo)
        tempoSlider.value = Float(metronome.tempo)
        tempoSlider.thumbTintColor = sliderThumbColor
        tempoSlider.minimumTrackTintColor = sliderMinColor
        tempoSlider.maximumTrackTintColor = sliderMaxColor
        tempoSlider.isEnabled = true

        metronome.prepare()
        
        //self.startMetronome()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    // MARK: - UIResponder
}

