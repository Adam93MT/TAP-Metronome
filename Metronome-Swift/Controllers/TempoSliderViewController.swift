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
    var Label: UILabel!
    
    var sliderPosY: CGFloat!
    var sliderLength: CGFloat!
    var maxVal: Int!
    var minVal: Int!
    var thumbWidth: Double!
    var thumbHeight: Double!
    let thumbBGImage = UIImage(named: "tempo_slider_thumb_pressed")
    
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // assign 'globals'
        metronome = delegate.metronome
        maxVal = metronome.maxTempo
        minVal = metronome.minTempo
        sliderPosY = tempoSlider.frame.midY
        sliderLength = tempoSlider.frame.height
        thumbWidth = Double(thumbBGImage!.size.width)
        thumbHeight = Double(thumbBGImage!.size.height)
        
        self.view.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        self.view.insertSubview(blurEffectView, at: 0)
        
        tempoSlider.maximumValue = Float(maxVal)
        tempoSlider.minimumValue = Float(minVal)
        tempoSlider.value = Float(metronome.tempoBPM)
    
        Label = UILabel(frame: CGRect(x: 0, y: 0, width: thumbWidth, height: thumbHeight))
        self.initSliderLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        closeButton.center.y += 64
        // update the slider value every time it appears
        tempoSlider.value = Float(metronome.tempoBPM)
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
        metronome.setTempo(Int(tempoSlider.value))
        self.updateLabel(val: tempoSlider.value)
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
    
    func initSliderLabel() {
        Label.center = self.view.center//CGPoint(x: labelX, y: labelY)
        Label.textAlignment = .center
        Label.text = String(delegate.metronome.getTempo())
        Label.textColor = delegate.textColor
        Label.font = Label.font.withSize(32)
        self.view.addSubview(Label)
        
        let bgImageView = UIImageView(image: thumbBGImage)
        Label.addSubview(bgImageView)
        
        let val = tempoSlider.value
        self.updateLabel(val: val)
    }
    
    func updateLabel(val: Float) {
        let labelY = Float(sliderPosY) + Float(sliderLength) * (1 - val/(Float(self.maxVal - self.minVal))) - 1.5*Float(thumbHeight)
        Label.center.y = CGFloat(labelY)
        Label.text = String(delegate.metronome.getTempo())
    }
}
