//
//  GradientLayer.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-10.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit

class GradientView: UIView {
    let gl = CAGradientLayer()
    
    override func awakeFromNib() {
        gl.frame = self.bounds
        self.layer.insertSublayer(gl, at: 0)
    }
    
    override func layoutSubviews() {
        gl.frame = self.bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.gl.locations = [0.0, 1.0]
        self.layer.insertSublayer(gl, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColors(startColor: UIColor, endColor: UIColor) {
        self.gl.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    func setLocations(start: NSNumber, end: NSNumber) {
        self.gl.locations = [start, end]
    }
}
