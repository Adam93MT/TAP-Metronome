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
    var tempoLabel: UILabel!
    var checkImage: UIImage!
    var crossImage: UIImage!
    
    var initialVal: Int!
    var sliderPosY: CGFloat!
    var sliderLength: CGFloat!
    var maxVal: Int!
    var minVal: Int!
    var thumbWidth: Double =  112
    var thumbHeight = Double(Globals.dimensions.buttonHeight)
    
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // assign 'globals'
        checkImage = UIImage(named: "check")
        crossImage = UIImage(named: "cross")
        initialVal = delegate.metronome.getTempo()
        
        maxVal = delegate.metronome.maxTempo
        minVal = delegate.metronome.minTempo
        sliderPosY = tempoSlider.frame.midY
        sliderLength = tempoSlider.frame.height
//        thumbWidth = Double(thumbBGImage!.size.width)
//        thumbHeight = Double(thumbBGImage!.size.height)
        
        self.view.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        self.view.insertSubview(blurEffectView, at: 0)
        
        tempoSlider.maximumValue = Float(maxVal)
        tempoSlider.minimumValue = Float(minVal)
        tempoSlider.value = Float(delegate.metronome.getTempo())
    
        tempoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: thumbWidth, height: thumbHeight))
        self.initSliderLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // update the slider value every time it appears
        tempoSlider.value = Float(delegate.metronome.getTempo())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print("slider: \(Int(tempoSlider.value))")
        delegate.metronome.setTempo(Int(tempoSlider.value))
        self.updateLabel(val: Float(delegate.metronome.getTempo()))
    }
    
    @IBAction func pressedDecrement(_ sender: UIButton) {
        delegate.metronome.decrementTempo()
        self.updateLabel(val: tempoSlider.value)
    }
    
    @IBAction func pressedIncrement(_ sender: UIButton) {
        delegate.metronome.incrementTempo()
        self.updateLabel(val: Float(delegate.metronome.getTempo()))
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
        tempoLabel.frame.size = CGSize(width: 112, height: Globals.dimensions.buttonHeight)
        tempoLabel.center = self.view.center //CGPoint(x: labelX, y: labelY)
        tempoLabel.textAlignment = .center
        tempoLabel.text = String(delegate.metronome.getTempo())
        tempoLabel.textColor = Globals.colors.bgColor
        tempoLabel.font = tempoLabel.font.withSize(28)
        tempoLabel.backgroundColor = UIColor(rgb: 0xFAFAFA)
        tempoLabel.layer.masksToBounds = true
        tempoLabel.layer.cornerRadius = Globals.dimensions.buttonHeight/2
        self.view.addSubview(tempoLabel)
        
        let val = tempoSlider.value
        self.updateLabel(val: val)
    }
    
    func updateLabel(val: Float) {
        // the 0.925 and 1.75 is found experimentally. not sure why
        let labelY = Float(sliderPosY) + 0.925 * Float(sliderLength) * (1 - val/(Float(self.maxVal - self.minVal))) - 1.75 * Float(thumbHeight)
        tempoLabel.center.y = CGFloat(labelY)
        tempoLabel.text = String(delegate.metronome.getTempo())
        
        self.changeCloseIcon()
    }
    
    func changeCloseIcon() {
        if (delegate.metronome.getTempo() != initialVal) {
            closeButton.setImage(checkImage, for: .normal)
        } else {
            closeButton.setImage(crossImage, for: .normal)
        }
    }
}
