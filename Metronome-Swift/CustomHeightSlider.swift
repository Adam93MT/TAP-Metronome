//
//  CustomHeightSlider.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-03.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class CustomHeightSlider: UISlider {
    
    let sliderMinColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    let sliderMaxColor = UIColor.black//UIColor(red:0.04, green: 0.04, blue: 0.04, alpha: 1)
    let sliderThumbColor = UIColor(red: 0.706, green: 0.706, blue: 0.706, alpha: 1)
    let trackHeight: CGFloat = 72

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init Slider")
        self.setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        print("init Slider")
        self.setup()
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
            var newBounds = super.trackRect(forBounds: bounds)
            newBounds.size.height = self.trackHeight
            newBounds.size.width = self.frame.width
            return newBounds
    }
    
    private func setup() {
        self.thumbRect(
            forBounds: CGRect(x:0, y:0, width:self.trackHeight, height: self.trackHeight),
            trackRect: CGRect(x:0, y:0, width:self.trackHeight, height: self.trackHeight),
            value: Float(self.trackHeight)
        )
        let _ = self.trackRect(
            forBounds: CGRect(x:0, y:0, width:self.trackHeight, height: self.trackHeight)
        )
        print("H: \(self.frame.height), W: \(self.frame.width)")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
