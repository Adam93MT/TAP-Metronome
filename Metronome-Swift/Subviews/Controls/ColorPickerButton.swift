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
    let borderWidth: CGFloat = 2
    let defaultBorderWidth: CGFloat = 0
    let defaultBorderColor = UIColor.white.withAlphaComponent(0.5).cgColor
    let highlightBorderColor = UIColor.white.cgColor
    
    let gradientLayer = GradientView()
    
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
        self.layer.borderWidth = defaultBorderWidth
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
            self.layer.borderWidth = isPicked ? borderWidth : defaultBorderWidth
            if isPicked { Globals.colors.setTheme(self.colorString) }
        }
    }
    
    func createGradientLayer() {
        // Set up the background colors
        
        if (self.colorString != "") {
            self.gradientLayer.setColors(
                startColor: (Globals.colors.colorOptions[self.colorString]?.bgColorLight)!,
                endColor: (Globals.colors.colorOptions[self.colorString]?.bgColorDark)!
            )
//            self.gradientLayer.gl.frame = CGRect(x:0, y:0, width: Globals.dimensions.buttonHeight, height: Globals.dimensions.buttonHeight)
            
            self.gradientLayer.gl.frame = self.bounds
            
            self.gradientLayer.gl.cornerRadius = self.layer.cornerRadius
            self.layer.insertSublayer(self.gradientLayer.gl, at: 0)
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
