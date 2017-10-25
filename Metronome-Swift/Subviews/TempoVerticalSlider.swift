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
    var tempoLabel: UILabel!
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
        self.thumbTintColor = .clear//delegate.bgColorDark.withAlphaComponent(0.8)
        self.backgroundColor = .clear
        self.minimumTrackTintColor = .white
        self.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.2)
        
        // Setup the label
        initSliderLabel()
        
        // Finally, we rotate the whole thing by 90deg
        self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2 )
    }

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var newThumbRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
//        newThumbRect.origin.x = 0
//        newThumbRect.origin.y = 22
        newThumbRect.size.width = 44
        newThumbRect.size.height = 44
        return newThumbRect.offsetBy(dx: 0, dy: -5)
    }
    
    func initSliderLabel() {
        tempoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: thumbWidth, height: thumbHeight))
        tempoLabel.frame.size = CGSize(width: 112, height: Globals.dimensions.buttonHeight)
        tempoLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2 )
        tempoLabel.layer.zPosition = 1
        
        // text & color
        tempoLabel.textAlignment = .center
        tempoLabel.text = String(delegate.metronome.getTempo())
        tempoLabel.textColor = Globals.colors.bgColor
        tempoLabel.font = tempoLabel.font.withSize(28)
        tempoLabel.backgroundColor = UIColor(rgb: 0xFAFAFA)
        tempoLabel.layer.masksToBounds = true
        tempoLabel.layer.cornerRadius = Globals.dimensions.buttonHeight/2
        self.addSubview(tempoLabel)
    }
    
    func updateLabel() {
        
        // recall its rotated 90deg
        let thumbX:CGFloat = self.thumbRect(
            forBounds: self.bounds, trackRect: self.trackRect(forBounds: self.bounds), value: self.value
        ).midX
        let thumbY: CGFloat = self.thumbRect(
            forBounds: self.bounds, trackRect: self.trackRect(forBounds: self.bounds), value: self.value
        ).midY
        tempoLabel.center.x = CGFloat(thumbX)
        tempoLabel.center.y = CGFloat(thumbY)
        
        tempoLabel.text = String(delegate.metronome.getTempo())
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
