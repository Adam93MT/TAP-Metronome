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
    
    let metronome = Metronome()
    var containerView: BeatContainerView!
    var metronomeDisplayLink: CADisplayLink!
    
    var currentOrientation: String = "portrait"
    var originalOrientation: String = "portrait"
    var viewWidth: CGFloat!
    var viewHeight: CGFloat!
    
    // Colours
    let backgroundColor = UIColor.black
    let tempoLabelColor = UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1)
    let tempoLabelColorPressed = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
    let MinColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
    let MaxColor = UIColor(red:0.04, green: 0.04, blue: 0.04, alpha: 0.2)
    let textLabelBottomSpace: CGFloat = 24
    var controlsAreHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Lets us access the ViewController from metronome logic
        metronome.parentViewController = self
        
        self.viewWidth = view.frame.width
        self.viewHeight = view.frame.height
        
        // Listen for device rotation
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleDeviceRotation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil
        )
        
        // Set Up Beat Circle Views
        self.containerView = BeatContainerView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
        self.containerView.center = view.center
        self.containerView.backgroundColor = UIColor.clear
        self.containerView.originalOrientation = self.originalOrientation
        self.containerView.screenWidth = self.viewWidth
        self.containerView.screenHeight = self.viewHeight
        view.addSubview(self.containerView)
        view.sendSubview(toBack: self.containerView)
        
        // Set up Tap button
        tapButton.frame.size = CGSize(width: viewWidth, height: viewHeight);
        tapButton.contentEdgeInsets = UIEdgeInsetsMake(
            viewHeight/2, viewWidth/2, viewHeight/2, viewWidth/2
        )
        view.backgroundColor = backgroundColor
        
        // Set up gesture recognizer
        let tapDownGestureRecognizer = TapDownGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.tapButton.addGestureRecognizer(tapDownGestureRecognizer)
        
        
        // Set up Tempo Control Buttons, Slider and Text
        self.addDoneButtonOnKeyboard()
        
        tempoTextField.text = String(metronome.tempo)
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
        tempoSlider.value = Float(metronome.tempo)

        metronome.prepare()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
            val = self.metronome.tempo
        }
        if (val! > metronome.maxTempo){
            val = metronome.maxTempo
            self.tempoTextField.text = String(metronome.maxTempo)
        } else if (val! < metronome.minTempo){
            val = metronome.minTempo
            self.tempoTextField.text = String(metronome.minTempo)
        }
        print("text box value: \(String(describing: val))")
        self.metronome.setTempo(newTempo: val!)
    }
    
    @IBAction func incrementButtonPressed(_ sender: UIButton) {
        self.metronome.incrementTempo()
    }
    
    @IBAction func decrementButtonPressed(_ sender: UIButton) {
        self.metronome.decrementTempo()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.metronome.setTempo(newTempo: Int(tempoSlider.value))
    }
    
    func handleTap(gestureRecognizer: TapDownGestureRecognizer) {
        if metronome.isOn {
            metronome.logTap()
            killControlAnimations()
        }
        else {
            metronome.start()
        }
        if self.controlsAreHidden {
            self.showUI()
        }
        let tapLocation = gestureRecognizer.location(in: self.view)
        self.metronome.playBeat()
        let tapIdx = metronome.getBeatIndex() + metronome.getTimeSignature()
        self.metronome.incrementBeat()
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
    
    func hideUI() {
        UIView.animate(withDuration: 4, delay: 0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            self.tempoTextField.alpha = 0
            self.incrementButton.alpha = 0
            self.decrementButton.alpha = 0
            self.tempoSlider.alpha = 0
            self.tapButton.alpha = 0.1
        })
        self.controlsAreHidden = true
    }
    
    func showUI() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.tempoTextField.alpha = 1
            self.incrementButton.alpha = 1
            self.decrementButton.alpha = 1
            self.tempoSlider.alpha = 1
            self.tapButton.alpha = 1
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
        for b in 1...metronome.timeSignature {
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
    }
}

