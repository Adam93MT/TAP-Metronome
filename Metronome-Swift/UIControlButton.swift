//
//  UIControlButton.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-19.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class UIControlButton: UIButton {
    
    let normalColor = UIColor.white.withAlphaComponent(0.15)
    let highlightColor = UIColor.white.withAlphaComponent(0.8)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = normalColor
        self.layer.cornerRadius = min(self.frame.width, self.frame.height)/2.0
        
//        self.addTarget(target: self, action: #selector(self.buttonHighlight), forControlEvent: UITouch)
//        self.addTarget(target: self, action: #selector(self.buttonNormal), forControlEvent: UIControlEventTouchUpInside)
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
