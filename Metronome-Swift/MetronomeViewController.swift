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
import AudioToolbox

@available(iOS 10.0, *)
class MetronomeViewController: UIViewController {
    
    @IBOutlet weak var tempoTextField: UITextField!
    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet weak var timeSignatureButton: UIButton!
    @IBOutlet weak var decrementButton: UIButton!
    @IBOutlet weak var incrementButton: UIButton!
    @IBOutlet weak var tempoSlider: CustomHeightSlider!
    
    let metronome = AVMetronome()
    var containerView: BeatContainerView!
    var metronomeDisplayLink: CADisplayLink!
    
    var currentOrientation: String = "portrait"
    var originalOrientation: String = "portrait"
    var viewWidth: CGFloat!
    var viewHeight: CGFloat!
    
    // Colours
    let gradientLayer = GradientView()
    let backgroundColor = UIColor.black
    var gradientStartColor: UIColor = UIColor(red: 29/255.0, green: 71/255.0, blue: 140/255.0, alpha: 0.5)
    var gradientEndColor: UIColor = UIColor(red: 19/255.0, green: 48/255.0, blue: 93/255.0, alpha: 0.5)
    let textColor = UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1)
    let MinColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
    let MaxColor = UIColor(red:0.04, green: 0.04, blue: 0.04, alpha: 0.2)
    let textLabelBottomSpace: CGFloat = 24
    var controlsAreHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Lets us access the ViewController from metronome logic
//        metronome.parentViewController = self
        metronome.delegate = self
        
        self.viewWidth = view.frame.width
        self.viewHeight = view.frame.height
        
        // Setup BG Color
        self.view.backgroundColor = backgroundColor
//        self.view.backgroundColor = UIColor.purple
        
        // Listen for device rotation
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleDeviceRotation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil
        )
        
        // Set Up Beat Circle Views
        self.containerView = BeatContainerView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
        self.containerView.originalOrientation = self.originalOrientation
        self.containerView.screenWidth = self.viewWidth
        self.containerView.screenHeight = self.viewHeight
        self.containerView.center = view.center
        self.containerView.initAllBeatCircles(metronome.getTimeSignature())
        self.containerView.backgroundColor = UIColor.clear
        
        view.addSubview(self.containerView)
        view.sendSubview(toBack: self.containerView)
        
        // Set up Tap button
//        tapButton.setTitleColor(self.textColor, for: .normal)
        tapButton.frame.size = CGSize(width: viewWidth, height: viewHeight);
        tapButton.contentEdgeInsets = UIEdgeInsetsMake(
            viewHeight/2, viewWidth/2, viewHeight/2, viewWidth/2
        )
        tapButton.setTitle("TAP", for: .normal)
        tapButton.alpha = 0.75
//        tapButton.setImage(UIImage(named: "Play"), for: .normal)
//        tapButton.setImage(UIImage(named: "Circle"), for: .normal)
        
        // Set up gesture recognizer
        let tapDownGestureRecognizer = TapDownGestureRecognizer(target: self, action: #selector(self.handleTap))
        tapDownGestureRecognizer.delaysTouchesBegan = false
        tapDownGestureRecognizer.delaysTouchesEnded = false
        tapDownGestureRecognizer.numberOfTapsRequired = 1
        tapDownGestureRecognizer.numberOfTouchesRequired = 1
        self.tapButton.addGestureRecognizer(tapDownGestureRecognizer)
        
        
        // Set up Tempo Control Buttons, Slider and Text
        self.addDoneButtonOnKeyboard()
        tempoTextField.text = String(metronome.tempoBPM)
        tempoTextField.tintColor = self.textColor
        tempoTextField.backgroundColor = UIColor.clear
        // add keyboard listeners to move UI up/down
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil
        )
        incrementButton.backgroundColor = MaxColor
        decrementButton.backgroundColor = MinColor
//        tempoSlider.thumbTintColor = UIColor.clear
        tempoSlider.minimumTrackTintColor = MinColor
        tempoSlider.maximumTrackTintColor = MaxColor
        tempoSlider.setMinimumTrackImage(UIImage(named: "sliderCapMin"), for: UIControlState.normal)
        tempoSlider.setMaximumTrackImage(UIImage(named: "sliderCapMax"), for: UIControlState.normal)
        tempoSlider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControlState.normal)
        tempoSlider.maximumValue = Float(metronome.maxTempo)
        tempoSlider.minimumValue = Float(metronome.minTempo)
        tempoSlider.value = Float(metronome.tempoBPM)

//        metronome.prepare()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make Gradient
        self.createGradientLayer()
        
        // Get original orientation
        self.currentOrientation = UIDevice.current.orientation.isPortrait ? "portrait" : "landscape"
        if UIDevice.current.orientation.isFlat {
            self.currentOrientation = "portrait"
        }
        print("Initial orientation \(self.currentOrientation)")
        self.originalOrientation = self.currentOrientation
        self.containerView.originalOrientation = self.originalOrientation
    }
    
    @IBAction func swipeButton(_ sender: UIButton) {
        if metronome.isOn { metronome.stop() }
    }
    
    @IBAction func editedTextField(_ sender: UITextField) {
        var val: Int!
        if let v: Int = Int(self.tempoTextField.text!) {
            val = v
        } else {
            val = Int(self.metronome.tempoBPM)
        }
        if (val! > metronome.maxTempo){
            val = metronome.maxTempo
            self.tempoTextField.text = String(metronome.maxTempo)
        } else if (val! < metronome.minTempo){
            val = metronome.minTempo
            self.tempoTextField.text = String(metronome.minTempo)
        }
        print("text box value: \(String(describing: val))")
        self.metronome.setTempo(val!)
    }
    
    @IBAction func incrementButtonPressed(_ sender: UIButton) {
        print("tempo++")
        self.metronome.incrementTempo()
    }
    
    @IBAction func decrementButtonPressed(_ sender: UIButton) {
        print("tempo--")
        self.metronome.decrementTempo()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print("changed slider")
        self.metronome.setTempo(Int(tempoSlider.value))
    }
    
    func handleTap(gestureRecognizer: TapDownGestureRecognizer) {
        
        if metronome.isOn {
            metronome.logTap()
            killControlAnimations()
        }
        else {
            metronome.last_fire_time = mach_absolute_time()
//            metronome.playBeat() // for machMetronome
            metronome.start()
        }
        
        if self.controlsAreHidden {
            self.showControls()
        }
        
        let tapLocation = gestureRecognizer.location(in: self.view)
        let tapIdx = metronome.getBeatIndex() + metronome.getTimeSignature()
//        self.metronome.incrementBeat()
        self.containerView.animateBeatCircle(
            beatIndex: tapIdx, beatDuration: metronome.getInterval(), startPoint: tapLocation
        )
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("keyboard will show: \(self.view.frame.origin.y)")
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                print("keyboard height: \(keyboardSize.height)")
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("keyboard will hide: \(self.view.frame.origin.y)")
        if let _ = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0.0//+= keyboardSize.height
            }
        }
    }
    
    func animateBeatCircle(_ metronome: AVMetronome, beatIndex: Int, beatDuration: Double) {
        DispatchQueue.main.async(execute: {() -> Void in
            self.containerView.animateBeatCircle(beatIndex: beatIndex, beatDuration: beatDuration)
        })
    }
    
    func hideControls(_ metronome: AVMetronome) {
        DispatchQueue.main.async(execute: {() -> Void in
            UIView.animate(withDuration: 4, delay: 0, options: [.curveEaseIn, .allowUserInteraction], animations: {
                self.tempoTextField.alpha = 0
                self.incrementButton.alpha = 0
                self.decrementButton.alpha = 0
                self.tempoSlider.alpha = 0
                self.tapButton.alpha = 0.1
            })
            self.controlsAreHidden = true
        })
    }
    
    func showControls() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.tempoTextField.alpha = 1
            self.incrementButton.alpha = 1
            self.decrementButton.alpha = 1
            self.tempoSlider.alpha = 1
            self.tapButton.alpha = 0.75
        })
        self.controlsAreHidden = false
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.black
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.tempoTextField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.tempoTextField.resignFirstResponder()
    }
    
    func resetAllBeatCircles(){
        for b in 0...metronome.timeSignature * 2 - 1{
            self.containerView.beatCircleReset(b)
        }
    }
    
    func killControlAnimations() {
        self.tempoTextField.layer.removeAllAnimations()
        self.incrementButton.layer.removeAllAnimations()
        self.decrementButton.layer.removeAllAnimations()
        self.tempoSlider.layer.removeAllAnimations()
        self.tapButton.layer.removeAllAnimations()
        self.view.layer.removeAllAnimations()
        self.view.layoutIfNeeded()
    }
    
    func handleDeviceRotation() {
        if UIDevice.current.orientation.isPortrait {
            self.currentOrientation = "portrait"
            self.containerView.currentOrientation = "portrait"
        } else if UIDevice.current.orientation.isLandscape {
            self.currentOrientation = "landscape"
            self.containerView.currentOrientation = "landscape"
        }
        self.gradientLayer.gl.frame = self.view.bounds
        
    }
    
    func createGradientLayer() {
        // Set up the background colors
        self.gradientLayer.setColors(startColor: gradientStartColor, endColor: gradientEndColor)
        self.gradientLayer.setLocations(start: 0.0, end: 0.5)
        self.gradientLayer.gl.frame = self.view.bounds
        self.view.layer.insertSublayer(self.gradientLayer.gl, at: 0)
    }
}

