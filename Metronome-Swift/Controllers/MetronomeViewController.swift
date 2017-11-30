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
    @IBOutlet weak var PlayPauseButton: UIButton!
    
    @IBOutlet weak var NavBar: UINavigationItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    let emptyButton: UIBarButtonItem = UIBarButtonItem()
    
    //    let metronome = AVMetronome()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var currentOrientation: String = "portrait"
    var metronome: AVMetronome!
    var containerView: BeatContainerView!
    var metronomeDisplayLink: CADisplayLink!
    
    var decrementLongPressTimer: Timer?
    var incrementLongPressTimer: Timer?
    
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
        self.emptyButton.image = UIImage(named: "placeholder")
        
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
        tapButton.alpha = 0.75
        
        self.view.bringSubview(toFront: PlayPauseButton)
        self.view.bringSubview(toFront: tempoButton)
        self.view.bringSubview(toFront: incrementButton)
        self.view.bringSubview(toFront: decrementButton)
        
        // Set up gesture recognizer
        let tapDownGestureRecognizer = TapDownGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.tapButton.addGestureRecognizer(tapDownGestureRecognizer)
        
        let multiTouchGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleMultiTouch))
        multiTouchGestureRecognizer.numberOfTapsRequired = 1
        multiTouchGestureRecognizer.numberOfTouchesRequired = 2
        self.tapButton.addGestureRecognizer(multiTouchGestureRecognizer)
        
        // Set up Tempo Control Buttons, Slider and Text
        tempoButton.setTitle(String(metronome.tempoBPM), for: .normal)
//        tempoButton.addTarget(self, #selector(), )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make Gradient
        self.showControls()
        self.createGradientLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Get original orientation
        if UIDevice.current.orientation.isFlat {
            self.currentOrientation = "portrait"
        } else {
            self.currentOrientation = UIDevice.current.orientation.isPortrait ? "portrait" : "landscape"
        }
        self.containerView.currentOrientation = currentOrientation
        print("Current orientation \(self.currentOrientation)")
        
        if originalOrientation.isEmpty {
            originalOrientation = self.currentOrientation
            print("Original orientation \(originalOrientation)")
        }
        
        // CoachMarks
        let showTutorial = UserDefaults.standard.bool(forKey: "showTutorial")
        if (showTutorial){
            self.showCoachMarks()
//            UserDefaults.standard.set(false, forKey: "showTutorial")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.controlsAreHidden
    }
    
    @IBAction func incrementButtonPressed(_ sender: UIButton) {
        self.metronome.incrementTempo()
        incrementLongPressTimer?.invalidate()
    }
    @IBAction func incrementButtonLongPress(_ sender: UIButton) {
        incrementLongPressTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { (Timer) in
            if self.metronome.getTempo() < self.metronome.maxTempo {
                self.metronome.incrementTempo()
            } else {
                self.incrementLongPressTimer?.invalidate()
            }
        })
    }
    
    @IBAction func decrementButtonPressed(_ sender: UIButton) {
        self.metronome.decrementTempo()
        decrementLongPressTimer?.invalidate()
    }
    @IBAction func decmentButtonLongPress(_ sender: Any) {
        decrementLongPressTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { (Timer) in
            if self.metronome.getTempo() > self.metronome.minTempo {
                self.metronome.decrementTempo()
            } else {
                self.incrementLongPressTimer?.invalidate()
            }
        })
    }
    
    @IBAction func togglePlayPause(_ sender: UIButton) {
        self.showControls()
        
        if delegate.metronome.isOn {
            self.stopMetronome()
        } else {
            self.startMetronome()
        }
    }
    @IBAction func openMenu(sender: AnyObject) {
        performSegue(withIdentifier: "openSettings", sender: nil)
    }
    
    func startMetronome() {
        let showTutorial = UserDefaults.standard.bool(forKey: "showTutorial")
        if (showTutorial){
            self.showStopCoachMarks()
            UserDefaults.standard.set(false, forKey: "showTutorial")
        }
        delegate.metronome.start()
        PlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        PlayPauseButton.setImage(UIImage(named: "pause_highlight"), for: .highlighted)
    }
    
    func stopMetronome() {
        delegate.metronome.stop()
        PlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
        PlayPauseButton.setImage(UIImage(named: "play_highlight"), for: .highlighted)
    }
    
    func handleTap(gestureRecognizer: TapDownGestureRecognizer) {
        if self.controlsAreHidden { self.showControls() }
        print("Touch")
        print("\(gestureRecognizer.numberOfTouches) fingers")
        
        let tapLocation = gestureRecognizer.location(in: self.view)
        let tapIdx = metronome.getAbsoluteBeat() % metronome.possibleTimeSignatures.max()!
        self.containerView.animateBeatCircle(
            beatIndex: tapIdx, beatDuration: metronome.getInterval(), startPoint: tapLocation
        )

        if metronome.isOn {
            metronome.logTap()
            self.killControlAnimations()
        }
        else {
                self.startMetronome()
        }
    }
    
    
    func handleMultiTouch(gestureRecognizer: UITapGestureRecognizer) {
        if self.controlsAreHidden { self.showControls() }

        print("Multitouch")
        print("\(gestureRecognizer.numberOfTouches) fingers")
        if metronome.isOn {
            self.stopMetronome()
        }
    }
    
    func hideControls(_ metronome: AVMetronome) {
        self.controlsAreHidden = true
        DispatchQueue.main.async(execute: {() -> Void in
            UIView.animate(withDuration: 2, delay: 0, options: [.curveEaseIn, .allowUserInteraction], animations: {
                self.tempoButton.alpha = 0
                self.incrementButton.alpha = 0
                self.decrementButton.alpha = 0
                self.PlayPauseButton.alpha = 0
//                self.settingsButton.isEnabled = false
                self.tapButton.alpha = 0.1
                self.setNeedsStatusBarAppearanceUpdate()
            })
        })
    }
    
    func showControls() {
        self.controlsAreHidden = false
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.tempoButton.alpha = 1
            self.incrementButton.alpha = 1
            self.decrementButton.alpha = 1
            self.PlayPauseButton.alpha = 1
//            self.settingsButton.isEnabled = true
            self.tapButton.alpha = 0.75
            self.setNeedsStatusBarAppearanceUpdate()
        })
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
        print("Rotated to \(self.currentOrientation)")
        self.gradientLayer.gl.frame = self.view.bounds
    }
    
    func createGradientLayer() {
        // Set up the background colors
        self.gradientLayer.setColors(startColor: Globals.colors.currentTheme.Light, endColor: Globals.colors.currentTheme.Dark)
        self.gradientLayer.gl.frame = self.view.bounds
        self.view.layer.insertSublayer(self.gradientLayer.gl, at: 0)
    }
    
    func showCoachMarks() {
        let coachMargin:CGFloat = 16
        //            let welcomeCoachRect:CGRect = CGRect(x:0, y:0, width:0, height:0)
        let controlCoachRect:CGRect = CGRect(x: decrementButton.frame.minX - coachMargin,
                                             y: decrementButton.frame.minY - coachMargin,
                                             width: incrementButton.frame.maxX - decrementButton.frame.minX + 2*coachMargin,
                                             height: tempoButton.frame.height + 2*coachMargin)
        let playButtonCoachRect:CGRect = CGRect(x: PlayPauseButton.frame.minX - coachMargin,
                                                y: PlayPauseButton.frame.minY - coachMargin,
                                                width: PlayPauseButton.frame.width + 2*coachMargin,
                                                height: PlayPauseButton.frame.height + 2*coachMargin)
        let tapButtonCoachRect:CGRect = CGRect(x: coachMargin,
                                               y: (self.view.frame.height - (self.view.frame.width - 2*coachMargin))/2,
                                               width: self.view.frame.width - 2*coachMargin,
                                               height: self.view.frame.width - 2*coachMargin)
        
        let coachMarks = [
            [   "rect": NSValue(cgRect: playButtonCoachRect),
                "caption": "Tap anywhere, or press Play to start the metronome.",
            ] as [String: Any],
            [   "rect": NSValue(cgRect: tapButtonCoachRect),
                "caption": "Keep Tapping to set the tempo.",
            ] as [String: Any],
            [   "rect": NSValue(cgRect: controlCoachRect),
                "caption": "Or set the tempo manually."
            ] as [String: Any]
        ]
        
        let coachMarksView = MPCoachMarks(frame: (self.view.bounds), coachMarks: coachMarks)
        //            coachMarksView?.enableContinueLabel = false
        coachMarksView?.continueLabelText = "Tap anywhere to continue"
        coachMarksView?.continueLocation = .LOCATION_TOP
        coachMarksView?.skipButtonText = "Skip Tutorial"
        self.view.addSubview(coachMarksView ?? UIView())
        coachMarksView?.start()
    }
    
    func showStopCoachMarks() {
        print("Coach Marks")
        let coachMargin:CGFloat = 16
        let stopCoachRect = CGRect(x: coachMargin,
                                   y: (self.view.frame.height - (self.view.frame.width - 2*coachMargin))/2,
                                   width: self.view.frame.width - 2*coachMargin,
                                   height: self.view.frame.width - 2*coachMargin)
        let coachMarks = [
            [   "rect": NSValue(cgRect: stopCoachRect),
                "caption": "Double Tap, or 2-finger Tap to stop the metronome.",
            ] as [String: Any]
        ]
        let coachMarksView = MPCoachMarks(frame: (self.view.bounds), coachMarks: coachMarks)
        coachMarksView?.continueLabelText = "OK"
        coachMarksView?.continueLocation = .LOCATION_TOP
        self.view.addSubview(coachMarksView ?? UIView())
        coachMarksView?.start()
    }
    
    
    // MARK: Keyboard
    /*
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
     */
    
}
