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
    
    // long press timers
    var decrementLongPressTimer: Timer?
    var incrementLongPressTimer: Timer?
    
    var blurEffectView: UIVisualEffectView!
    var checkImage: UIImage!
    var crossImage: UIImage!
    
    var touchableView: UIView!
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
        
        touchableView = UIView()
        touchableView.frame = CGRect(x: tempoSlider.frame.minX
                                        - (CGFloat(tempoSlider.thumbWidth) - tempoSlider.frame.width)/2 + 1,
                                     y: tempoSlider.frame.minY,
                                     width: CGFloat(tempoSlider.thumbWidth),
                                     height: tempoSlider.frame.height)
        
        self.view.addSubview(touchableView)
        touchableView.backgroundColor = .clear
        self.view.bringSubview(toFront: touchableView)
        
        // detect drag
        let dragGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.dragSlider))
        dragGestureRecognizer.maximumNumberOfTouches = 1
        touchableView.addGestureRecognizer(dragGestureRecognizer)
        self.view.bringSubview(toFront: tempoSlider)
        
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
        tempoSlider.value = Float(delegate.metronome.getTempo())
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
        updateCloseIcon()
    }
    
    @IBAction func pressedDecrement(_ sender: UIButton) {
        delegate.metronome.decrementTempo()
        self.decrementLongPressTimer?.invalidate()
        self.tempoSlider.updateValue(newVal: Float(self.delegate.metronome.getTempo()))
        updateCloseIcon()
    }
    @IBAction func decmentButtonLongPress(_ sender: Any) {
        decrementLongPressTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { (Timer) in
            if self.delegate.metronome.getTempo() > self.delegate.metronome.minTempo {
                self.delegate.metronome.decrementTempo()
            } else {
                self.incrementLongPressTimer?.invalidate()
            }
            
            self.tempoSlider.updateValue(newVal: Float(self.delegate.metronome.getTempo()))
            self.updateCloseIcon()
        })
    }
    
    @IBAction func pressedIncrement(_ sender: UIButton) {
        self.incrementLongPressTimer?.invalidate()
        delegate.metronome.incrementTempo()
        self.tempoSlider.updateValue(newVal: Float(self.delegate.metronome.getTempo()))
        updateCloseIcon()
    }
    @IBAction func incrementButtonLongPress(_ sender: UIButton) {
        incrementLongPressTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { (Timer) in
            if self.delegate.metronome.getTempo() < self.delegate.metronome.maxTempo {
                self.delegate.metronome.incrementTempo()
            } else {
                self.incrementLongPressTimer?.invalidate()
            }
            
            self.tempoSlider.updateValue(newVal: Float(self.delegate.metronome.getTempo()))
            self.updateCloseIcon()
        })
    }
    
    func dragSlider(sender: UIGestureRecognizer) {
        let xLocation = sender.location(in: self.tempoSlider).x
        let maxX = self.tempoSlider.frame.height
        let percent = xLocation / maxX
        let tempo = percent * CGFloat(delegate.metronome.maxTempo - delegate.metronome.minTempo) + CGFloat(delegate.metronome.minTempo)
        delegate.metronome.setTempo(Int(tempo))
        tempoSlider.touchSlider(sender: sender)
        self.tempoSlider.updateValue(newVal: Float(delegate.metronome.getTempo()))
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
    
    func updateCloseIcon() {
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
