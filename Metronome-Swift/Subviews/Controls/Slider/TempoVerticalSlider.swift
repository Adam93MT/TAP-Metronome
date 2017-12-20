//
//  TempoVerticalSlider.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-16.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class TempoVerticalSlider: UISlider {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var tempoThumb: TouchableLabel!
    
    let thumbWidth: Double =  112
    let thumbHeight = Double(Globals.dimensions.buttonHeight)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        print("setup slider")
        
        // Setup standard slider elements
        self.thumbTintColor = .clear
        self.backgroundColor = UIColor.clear.withAlphaComponent(0)
        self.minimumTrackTintColor = .white
        self.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.2)
//        self.maximumValueImage = UIImage(named: "sliderMaxEndCap")
//        self.minimumValueImage = UIImage(named: "sliderMinEndCap")
//
        // Setup the label
        initSliderLabel()
        
        // detect touches on thumb
        self.addTarget(self, action: #selector(self.touchSlider), for: .allTouchEvents)
        // Finally, we rotate the whole thing by 90deg
        self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
    }

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var newThumbRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        newThumbRect.size.width = 44
        newThumbRect.size.height = 44
        return newThumbRect.offsetBy(dx: 0, dy: -5)
    }
    
    func initSliderLabel() {
        tempoThumb = TouchableLabel(frame: CGRect(x: 0, y: 0, width: thumbWidth, height: thumbHeight))
        tempoThumb.frame.size = CGSize(width: 112, height: Globals.dimensions.buttonHeight)
        tempoThumb.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2 )
        tempoThumb.layer.zPosition = 1
        
        // text & color
        tempoThumb.textAlignment = .center
        tempoThumb.text = String(delegate.metronome.getTempo())
        tempoThumb.textColor = Globals.colors.currentTheme.Dark
        tempoThumb.font = tempoThumb.font.withSize(28)
//        tempoThumb.setColors(Globals.colors.textColor, highlightColor: Globals.colors.highlightButtonColor)
        tempoThumb.layer.masksToBounds = true
        tempoThumb.layer.cornerRadius = Globals.dimensions.buttonHeight/2
        self.addSubview(tempoThumb)
    }
    
    func updateLabel() {
        // recall its rotated 90deg
        let thumbX: CGFloat = self.thumbRect(
            forBounds: self.bounds, trackRect: self.trackRect(forBounds: self.bounds), value: self.value
        ).midX
        let thumbY: CGFloat = self.thumbRect(
            forBounds: self.bounds, trackRect: self.trackRect(forBounds: self.bounds), value: self.value
        ).midY
        tempoThumb.center.x = CGFloat(thumbX)
        tempoThumb.center.y = CGFloat(thumbY)
        
        tempoThumb.text = String(delegate.metronome.getTempo())
    }
    
    func touchSlider(sender: UIGestureRecognizer) {
        if sender.state == .began {
            tempoThumb.isHighlighted = true
            tempoThumb.addShadow()
        } else if sender.state == .ended || sender.state == .possible {
            tempoThumb.isHighlighted = false
        }
    }
    
    func updateValue(newVal: Float) {
        self.value = newVal
        self.updateLabel()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
