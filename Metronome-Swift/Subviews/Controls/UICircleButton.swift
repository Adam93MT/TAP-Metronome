//
//  UICircleButton.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-19.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class UICircleButton: UIControlButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func setup() {
        super.setup()
        
        let circleSize:CGFloat = Globals.dimensions.buttonHeight
        
        self.bounds = CGRect(x:0, y:0, width: circleSize, height: circleSize)
        
        self.addConstraint(NSLayoutConstraint(  item: self,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .notAnAttribute,
                                                multiplier: 1,
                                                constant: circleSize)
                                            )
        self.addConstraint(NSLayoutConstraint(  item: self,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .width,
                                                multiplier: 1,
                                                constant: 0)
                                            )
        
        self.layer.cornerRadius = circleSize/2
    
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
