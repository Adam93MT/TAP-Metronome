//
//  SpacerView.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-27.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class SpacerView: UIView {
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = false
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = false
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
