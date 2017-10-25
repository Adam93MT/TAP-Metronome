//
//  ColorPickerButton.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-25.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class ColorPickerButton: UICircleButton {

    var colorString = ""
    let borderWidth:CGFloat = 2
    let borderColor = UIColor.white.cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setColorStringValue(_ color: String) {
        self.colorString = color
        setDefaultColor(defaultColor: (Globals.colors.colorOptions[self.colorString]?.bgColorLight)!)
        if self.colorString == Globals.colors.bgTheme {
            self.isPicked = true
        }
    }
    
    var isPicked: Bool = false {
        didSet {
            self.layer.borderColor = isPicked ? borderColor : UIColor.clear.cgColor
            self.layer.borderWidth = isPicked ? borderWidth : 0
            if isPicked { Globals.colors.setTheme(self.colorString) }
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
