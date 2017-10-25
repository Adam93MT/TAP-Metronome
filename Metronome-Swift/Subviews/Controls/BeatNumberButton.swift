//
//  BeatNumberButton.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-23.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class BeatNumberButton: UIButton {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    let borderWidth:CGFloat = 2
    let borderColor = UIColor.white.cgColor
    var defaultColor = Globals.colors.bgColorLight.withAlphaComponent(0.5)
    var pickedColor = Globals.colors.bgColorDark.withAlphaComponent(0.5)
    
    var value: Int = 0
    var siblings = [BeatNumberButton]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = defaultColor
        self.titleLabel?.font = self.titleLabel?.font.withSize(42)
        if self.value == delegate.metronome.getTimeSignature() {
            self.isPicked = true
        }
//        self.addTarget(self, action: #selector(self.touchButton), for: .touchUpInside)
        
    }

    func setValue(val: Int) {
        self.value = val
        if val == delegate.metronome.getTimeSignature() {
            self.isPicked = true
        }
    }
    func setColors() {
        defaultColor = Globals.colors.bgColorLight.withAlphaComponent(0.5)
        pickedColor = Globals.colors.bgColorDark.withAlphaComponent(0.5)
        self.backgroundColor = isPicked ? pickedColor : defaultColor
    }
    
    var isPicked: Bool = false {
        didSet {
            self.backgroundColor = isPicked ? pickedColor : defaultColor
            self.layer.borderColor = isPicked ? borderColor : UIColor.clear.cgColor
            self.layer.borderWidth = isPicked ? borderWidth : 0
            if isPicked { delegate.metronome.setTimesignature(self.value) } 
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
