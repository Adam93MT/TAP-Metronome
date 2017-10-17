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
        
        self.thumbTintColor = .clear//delegate.bgColorDark.withAlphaComponent(0.8)
        self.backgroundColor = .clear
        self.minimumTrackTintColor = .white
        self.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.1)
        self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2 )
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
