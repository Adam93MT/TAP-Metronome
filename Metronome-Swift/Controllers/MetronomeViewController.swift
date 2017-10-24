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
    
    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet weak var decrementButton: UIButton!
    @IBOutlet weak var incrementButton: UIButton!
    @IBOutlet weak var tempoButton: UIButton!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    //    let metronome = AVMetronome()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var metronome: AVMetronome!
    var containerView: BeatContainerView!
    var metronomeDisplayLink: CADisplayLink!
    
    var currentOrientation: String = "portrait"
    var originalOrientation: String = "portrait"
    var viewWidth: CGFloat!
    var viewHeight: CGFloat!
    
    let gradientLayer = GradientView()
    let textLabelBottomSpace: CGFloat = 24
    var controlsAreHidden: Bool = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Lets us access the ViewController from metronome logic
        metronome = delegate.metronome
        metronome.vc = self
        
        self.viewWidth = view.frame.width
        self.viewHeight = view.frame.height
        
        // Setup BG Color
        self.view.backgroundColor = Globals.colors.bgColor
        
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
        tapButton.frame.size = CGSize(width: viewWidth, height: viewHeight);
        tapButton.contentEdgeInsets = UIEdgeInsetsMake(
            viewHeight/2, viewWidth/2, viewHeight/2, viewWidth/2
        )
        tapButton.setTitle("TAP", for: .normal)
        tapButton.alpha = 0.75
        
        // Set up gesture recognizer
        let tapDownGestureRecognizer = TapDownGestureRecognizer(target: self, action: #selector(self.handleTap))
        tapDownGestureRecognizer.delaysTouchesBegan = false
        tapDownGestureRecognizer.delaysTouchesEnded = false
        tapDownGestureRecognizer.numberOfTapsRequired = 1
        tapDownGestureRecognizer.numberOfTouchesRequired = 1
        self.tapButton.addGestureRecognizer(tapDownGestureRecognizer)
        
        
        // Set up Tempo Control Buttons, Slider and Text
//        self.addDoneButtonOnKeyboard()
        tempoButton.setTitle(String(metronome.tempoBPM), for: .normal)
        // add keyboard listeners to move UI up/down
//        NotificationCenter.default.addObserver(
//            self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil
//        )
//        NotificationCenter.default.addObserver(
//            self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil
//        )

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
    
    @IBAction func incrementButtonPressed(_ sender: UIButton) {
        print("tempo++")
        self.metronome.incrementTempo()
    }
    
    @IBAction func decrementButtonPressed(_ sender: UIButton) {
        self.metronome.decrementTempo()
    }
    
    @IBAction func openMenu(sender: AnyObject) {
        performSegue(withIdentifier: "openSettings", sender: nil)
    }
    
    func handleTap(gestureRecognizer: TapDownGestureRecognizer) {
        if metronome.isOn {
            metronome.logTap()
            killControlAnimations()
        }
        else {
            metronome.last_fire_time = mach_absolute_time()
            // metronome.playBeat() // for machMetronome
            metronome.start()
        }
        
        if self.controlsAreHidden {
            self.showControls()
        }
        
        let tapLocation = gestureRecognizer.location(in: self.view)
        let tapIdx = metronome.getBeatIndex() + metronome.getTimeSignature()
        // self.metronome.incrementBeat()
        self.containerView.animateBeatCircle(
            beatIndex: tapIdx, beatDuration: metronome.getInterval(), startPoint: tapLocation
        )
    }
    
    func hideControls(_ metronome: AVMetronome) {
        self.controlsAreHidden = true
        DispatchQueue.main.async(execute: {() -> Void in
            UIView.animate(withDuration: 4, delay: 0, options: [.curveEaseIn, .allowUserInteraction], animations: {
                self.tempoButton.alpha = 0
                self.incrementButton.alpha = 0
                self.decrementButton.alpha = 0
                self.settingsButton.isEnabled = false
                self.tapButton.alpha = 0.1
                self.setNeedsStatusBarAppearanceUpdate()
            })
        })
    }
    
    func showControls() {
        self.controlsAreHidden = false
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.tempoButton.alpha = 1
            self.incrementButton.alpha = 1
            self.decrementButton.alpha = 1
            self.settingsButton.isEnabled = true
            self.tapButton.alpha = 0.75
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.controlsAreHidden
    }
    
    func animateBeatCircle(_ metronome: AVMetronome, beatIndex: Int, beatDuration: Double) {
        DispatchQueue.main.async(execute: {() -> Void in
            self.containerView.animateBeatCircle(beatIndex: beatIndex, beatDuration: beatDuration)
        })
    }
    
    func resetAllBeatCircles(){
        for b in 0...metronome.timeSignature * 2 - 1{
            self.containerView.beatCircleReset(b)
        }
    }
    
    func killControlAnimations() {
        self.tempoButton.layer.removeAllAnimations()
        self.incrementButton.layer.removeAllAnimations()
        self.decrementButton.layer.removeAllAnimations()
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
        self.gradientLayer.setColors(startColor: Globals.colors.bgColorLight, endColor: Globals.colors.bgColorDark)
        self.gradientLayer.setLocations(start: 0.0, end: 0.5)
        self.gradientLayer.gl.frame = self.view.bounds
        self.view.layer.insertSublayer(self.gradientLayer.gl, at: 0)
    }
    
    
    // MARK: Keyboard
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
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0.0//+= keyboardSize.height
            }
        }
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
        
        // self.tempoTextField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        // self.tempoTextField.resignFirstResponder()
    }
    
}
