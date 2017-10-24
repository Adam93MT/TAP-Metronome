//
//  BeatNumberButton.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-23.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class BeatNumberButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = Globals.colors.bgColorLight.withAlphaComponent(0.5)
        
        self.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 80))
        self.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 68))
        
        self.titleLabel?.font = self.titleLabel?.font.withSize(42)
        self.layer.cornerRadius = 4
    }

    func setColor(_ newColor: UIColor) {
        self.backgroundColor = newColor.withAlphaComponent(0.5)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
