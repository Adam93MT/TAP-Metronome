//
//  TouchableLabel.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-25.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class TouchableLabel: UILabel {
    
    var defaultColor: UIColor = .white
    var highlightColor: UIColor = .gray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.isHighlighted = false
    }
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? self.highlightColor : self.defaultColor
        }
    }
    
    func setColors(_ defaultColor: UIColor, highlightColor: UIColor) {
        self.defaultColor = defaultColor
        self.highlightColor = highlightColor
    }
    
    func addShadow() {
        print("adding shadow")
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
        self.layer.shadowRadius = 2
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    func removeShadow() {
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize.zero
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
