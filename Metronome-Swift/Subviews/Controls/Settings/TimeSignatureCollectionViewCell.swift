//
//  TimeSignatureCollectionViewCell.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-11-30.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class TimeSignatureCollectionViewCell: UICollectionViewCell {
 
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var value: Int!
    var titleLabel: UILabel!
    let borderWidth: CGFloat = 2
    let defaultBorderWidth: CGFloat = 0
    
    let defaultBorderColor = UIColor.white.withAlphaComponent(0.5).cgColor
    let highlightBorderColor = UIColor.white.cgColor
    
    let defaultColor = Globals.colors.normalButtonColor
    let highlightColor = Globals.colors.highlightButtonColor

    let highlightLayer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        self.addSubview(titleLabel)
        titleLabel.font = titleLabel.font.withSize(36)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Globals.colors.textColor
        self.backgroundColor = defaultColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderColor = isSelected ? highlightBorderColor : defaultBorderColor
            self.layer.borderWidth = isSelected ? borderWidth : defaultBorderWidth
            self.backgroundColor = isSelected ? highlightColor : defaultColor
            if isSelected {
                delegate.metronome.setTimesignature(self.value)
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
    
    func setValue(_ val: Int) {
        self.value = val
        if val == delegate.metronome.getTimeSignature() {
            self.isSelected = true
        }
        titleLabel.text = String(val)
    }
    
    func createHighlightLayer() {
        highlightLayer.backgroundColor = Globals.colors.highlightButtonColor
        highlightLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width)
        self.addSubview(highlightLayer)
        self.bringSubview(toFront: highlightLayer)
        highlightLayer.isHidden = true
    }
    
}
