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
    var currentOrientation: String = "portrait"
    var blurEffectView: UIVisualEffectView!
    // var tempoLabel: UILabel!
    var checkImage: UIImage!
    var crossImage: UIImage!
    
    var initialVal: Int!
    var sliderPosY: CGFloat!
    var sliderLength: CGFloat!
    var maxVal: Int!
    var minVal: Int!
    
    @IBOutlet weak var tempoSlider: TempoVerticalSlider!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // assign 'class-globals'
        checkImage = UIImage(named: "check")
        crossImage = UIImage(named: "cross")
        initialVal = delegate.metronome.getTempo()
        maxVal = delegate.metronome.maxTempo
        minVal = delegate.metronome.minTempo
        sliderPosY = tempoSlider.frame.midY
        sliderLength = tempoSlider.frame.height
        
        self.view.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        self.view.insertSubview(blurEffectView, at: 0)
        
        tempoSlider.maximumValue = Float(maxVal)
        tempoSlider.minimumValue = Float(minVal)
        tempoSlider.value = Float(delegate.metronome.getTempo())
        
        // set initial rotation
        if UIDevice.current.orientation.isPortrait {
            self.currentOrientation = "portrait"
        } else if UIDevice.current.orientation.isLandscape {
            self.currentOrientation = "landscape"
        }
        // Listen for device rotation
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleDeviceRotation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil
        )
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tempoSlider.updateLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tempoModalisVisible = true
        // update the slider value every time it appears
        tempoSlider.value = Float(delegate.metronome.getTempo())
        // position the label once we've set the value
        tempoSlider.updateLabel()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tempoModalisVisible = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        delegate.metronome.setTempo(Int(tempoSlider.value))
        self.tempoSlider.updateLabel()
    }
    
    @IBAction func pressedDecrement(_ sender: UIButton) {
        delegate.metronome.decrementTempo()
        self.tempoSlider.updateLabel()
    }
    
    @IBAction func pressedIncrement(_ sender: UIButton) {
        delegate.metronome.incrementTempo()
        self.tempoSlider.updateLabel()
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
    
    func changeCloseIcon() {
        if (delegate.metronome.getTempo() != initialVal) {
            closeButton.setImage(checkImage, for: .normal)
        } else {
            closeButton.setImage(crossImage, for: .normal)
        }
    }
    
    func handleDeviceRotation() {
        if UIDevice.current.orientation.isPortrait {
            self.currentOrientation = "portrait"
        } else if UIDevice.current.orientation.isLandscape {
            self.currentOrientation = "landscape"
        }
        
        blurEffectView.frame = self.view.frame
        tempoSlider.updateLabel()
        
    }
}
