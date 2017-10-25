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
    let defaultBorderColor = UIColor.white.withAlphaComponent(0.5).cgColor
    let highlightBorderColor = UIColor.white.cgColor
    
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
        self.layer.borderColor = defaultBorderColor
        self.layer.borderWidth = 1
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
            self.layer.borderColor = isPicked ? highlightBorderColor : defaultBorderColor
            self.layer.borderWidth = isPicked ? borderWidth : 1
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
