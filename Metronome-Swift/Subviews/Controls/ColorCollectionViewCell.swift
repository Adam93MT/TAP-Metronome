//
//  ColorCollectionViewCell.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-11-14.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
   
    var colorString = ""
    var defaultColor: UIColor!
    let borderWidth: CGFloat = 2
    let defaultBorderWidth: CGFloat = 0
    let defaultBorderColor = UIColor.white.withAlphaComponent(0.5).cgColor
    let highlightBorderColor = UIColor.white.cgColor
    let gradientLayer = GradientView()
    let highlightLayer = UIView()
    
    override var isSelected: Bool {
        didSet {
            if (globalColors.validateColor(self.colorString)) {
                self.layer.borderColor = isSelected ? highlightBorderColor : defaultBorderColor
                self.layer.borderWidth = isSelected ? borderWidth : defaultBorderWidth
                if isSelected {
                    Globals.colors.setTheme(self.colorString)
                }
            }
            else {
//                isSelected = oldValue
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            highlightLayer.isHidden = !isHighlighted
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
    }
    
    func setColorStringValue(_ color: String) {
        if globalColors.validateColor(color) {
            self.colorString = color
            self.defaultColor = globalColors.getColorOption(color).bgColorLight
            if self.colorString == Globals.colors.bgTheme {
                self.isSelected = true
            }
            createGradientLayer()
            
        } else {
            // otherwise we'll make it an "Add More" button
            self.colorString = "add"
            self.isSelected = false
            self.backgroundColor = Globals.colors.normalButtonColor
            setupAddMoreButton()
        }
        
        createHighlightLayer()
    }
    
    func createGradientLayer() {
        // Set up the background colors
        if (self.colorString != "") {
            self.gradientLayer.setColors(
                startColor: (globalColors.getColorOption(self.colorString).bgColorLight)!,
                endColor: (globalColors.getColorOption(self.colorString).bgColorDark)!
            )
            self.gradientLayer.gl.frame = self.bounds
            self.gradientLayer.gl.cornerRadius = self.layer.cornerRadius
            self.layer.insertSublayer(self.gradientLayer.gl, at: 0)
        }
    }
    
    func createHighlightLayer() {
        highlightLayer.backgroundColor = Globals.colors.highlightButtonColor
        highlightLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width)
        self.addSubview(highlightLayer)
        self.bringSubview(toFront: highlightLayer)
        highlightLayer.isHidden = true
    }
    
    func setupAddMoreButton() {
        let iconImage = UIImageView(image: UIImage(named: "increment"))
        let w = iconImage.image?.size.width
        let h = iconImage.image?.size.height
        iconImage.frame = CGRect(x: (self.frame.width - w!)/2, y: (self.frame.height - h!)/2, width: w!, height: h!)
        self.addSubview(iconImage)
    }
}
