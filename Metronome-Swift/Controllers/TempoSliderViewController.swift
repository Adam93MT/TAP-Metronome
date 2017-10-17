//
//  TempoSliderViewController.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-16.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class TempoSliderViewController: UIViewController {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var metronome: AVMetronome!
    
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        metronome = delegate.metronome
        
        self.view.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        self.view.insertSubview(blurEffectView, at: 0)
        
        tempoSlider.thumbTintColor = UIColor.clear
        tempoSlider.setMinimumTrackImage(UIImage(named: "sliderCapMin"), for: UIControlState.normal)
        tempoSlider.setMaximumTrackImage(UIImage(named: "sliderCapMax"), for: UIControlState.normal)
        tempoSlider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState.normal)
        tempoSlider.maximumValue = Float(metronome.maxTempo)
        tempoSlider.minimumValue = Float(metronome.minTempo)
        tempoSlider.value = Float(metronome.tempoBPM)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        closeButton.center.y += 64
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        closeButton.center.y -= 64
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print("slider: \(Int(tempoSlider.value))")
        self.metronome.setTempo(Int(tempoSlider.value))
    }
    
    // MARK: - Navigation

     @IBAction func closeTempoModal(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
     }
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
