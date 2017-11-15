//
//  UIControlButton.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-19.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class UIControlButton: UIButton {
    
    var normalColor = Globals.colors.normalButtonColor
    var highlightColor = Globals.colors.highlightButtonColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = self.normalColor
        self.layer.cornerRadius = min(self.frame.width, self.frame.height)/2.0
    }
    
    func setDefaultColor(defaultColor: UIColor) {
        self.normalColor = defaultColor
        self.setup()
    }
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? highlightColor : normalColor
        }
    }
    
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
