//
//  BeatGroupButton.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-26.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class BeatGroupButton: UIControlButton {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var val: Int!
    let buttonSize: CGFloat = 64
    let borderWidth: CGFloat = 2
    let defaultBorderWidth: CGFloat = 0
    let defaultBorderColor = UIColor.white.withAlphaComponent(0.5).cgColor
    let highlightBorderColor = UIColor.white.cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        print("override")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func setup() {
        super.setup()
        self.titleLabel!.font = self.titleLabel?.font.withSize(36)
        self.setSize()
    }

    func setValue(val: Int) {
        self.val = val
        if val == delegate.metronome.getTimeSignature() {
            self.isPicked = true
        }
        self.titleLabel!.text = String(val)
    }
    
    func setColors() {
//        self.backgroundColor = isPicked ? Globals.colors.bgColorDark : Globals.colors.bgColorLight
    }
    
    func setSize() {
        self.bounds = CGRect(x:0, y:0, width: buttonSize, height: buttonSize)
        
        self.addConstraint(NSLayoutConstraint(  item: self,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .notAnAttribute,
                                                multiplier: 1,
                                                constant: buttonSize)
        )
        self.addConstraint(NSLayoutConstraint(  item: self,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .width,
                                                multiplier: 1,
                                                constant: 0)
        )
        
        self.layer.cornerRadius = buttonSize/2
    }
    
    var isPicked: Bool = false {
        didSet {
            self.layer.borderColor = isPicked ? highlightBorderColor : defaultBorderColor
            self.layer.borderWidth = isPicked ? borderWidth : defaultBorderWidth
            if isPicked { delegate.metronome.setTimesignature(self.val) }
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
