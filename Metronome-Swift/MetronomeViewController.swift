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
    @IBOutlet weak var showControlsButton: UIButton!

    // The superView containing all animating Circles
    //@IBOutlet weak var beatCircleView: BeatCircleView!
    
    let metronome = Metronome()
    var containerView: BeatContainerView!
    var metronomeDisplayLink: CADisplayLink!
    
    // Colours
    let backgroundColor = UIColor.black
    let tempoLabelColor = UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1)
    let tempoLabelColorPressed = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
    let MinColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
    let MaxColor = UIColor(red:0.04, green: 0.04, blue: 0.04, alpha: 0.2)
    let textLabelBottomSpace: CGFloat = 24
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Lets us access the ViewController from metronome logic
        metronome.parentViewController = self
        
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        print("Height: \(viewHeight), Width: \(viewWidth)")
        
        // Set Up Beat Circle Views
        self.containerView = BeatContainerView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
        self.containerView.center = view.center
        self.containerView.backgroundColor = UIColor.clear
        view.addSubview(self.containerView)
        view.sendSubview(toBack: self.containerView)
        
        // Set up Tap button
        tapButton.frame.size = CGSize(width: viewWidth, height: viewWidth);
        tapButton.contentEdgeInsets = UIEdgeInsetsMake(viewWidth/2, viewWidth/2, viewWidth/2, viewWidth/2);
        view.bringSubview(toFront: tapButton)
        view.backgroundColor = backgroundColor
        
        // Set up Tempo Control Buttons, Slider and Text
        self.addDoneButtonOnKeyboard()
        
        showControlsButton.isHidden = true
        tempoTextField.text = String(metronome.tempo)
        tempoTextField.backgroundColor = UIColor.clear
        // add keyboard listeners to move UI up/down
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        incrementButton.backgroundColor = MaxColor
        decrementButton.backgroundColor = MinColor
        tempoSlider.thumbTintColor = UIColor.clear
        tempoSlider.minimumTrackTintColor = MinColor
        tempoSlider.maximumTrackTintColor = MaxColor
        tempoSlider.setMinimumTrackImage(UIImage(named: "sliderCapMin"), for: UIControlState.normal)
        tempoSlider.setMaximumTrackImage(UIImage(named: "sliderCapMax"), for: UIControlState.normal)
        tempoSlider.maximumValue = Float(metronome.maxTempo)
        tempoSlider.minimumValue = Float(metronome.minTempo)
        tempoSlider.value = Float(metronome.tempo)
        
        // Set up control button
        showControlsButton.backgroundColor = MinColor
        showControlsButton.isHidden = true

        metronome.prepare()
        
        //self.startMetronome()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func swipeButton(_ sender: UIButton) {
        if metronome.isOn { metronome.stop() }
    }
    
    @IBAction func tapDown(_ sender: UIButton) {
        if metronome.isOn { metronome.logTap() }
        else { metronome.start() }
    }
    @IBAction func tapUp(_ sender: UIButton) {
        // nothing but need to catch tapUp
        self.showUI()
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
        let viewHeight = view.frame.height
        UIView.animate(withDuration: 10, delay: 0, options: .curveEaseIn, animations: {
            let textHeight = self.tempoTextField.frame.height
            let barHeight = self.tempoSlider.frame.height
            self.tempoTextField.frame.origin.y = viewHeight + textHeight
            self.incrementButton.frame.origin.y = viewHeight + textHeight + self.textLabelBottomSpace + barHeight
            self.decrementButton.frame.origin.y = viewHeight + textHeight + self.textLabelBottomSpace + barHeight
            self.tempoSlider.frame.origin.y = viewHeight + textHeight + self.textLabelBottomSpace + barHeight
            self.tapButton.alpha = 0.1
        })
    }
    
    func showUI() {
        let viewHeight = view.frame.height
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            let textHeight = self.tempoTextField.frame.height
            let barHeight = self.tempoSlider.frame.height
            self.tempoTextField.frame.origin.y = viewHeight - barHeight - self.textLabelBottomSpace - textHeight
            self.incrementButton.frame.origin.y = viewHeight - barHeight
            self.decrementButton.frame.origin.y = viewHeight - barHeight
            self.tempoSlider.frame.origin.y = viewHeight - barHeight
            self.tapButton.alpha = 1
        })
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
    
    // MARK: - UIResponder
}

