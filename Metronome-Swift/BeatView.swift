//
//  BeatView.swift
//  Metronome-Swift
//
//  Created by Adam Thompson on 2015-12-24.
//  Copyright (c) 2015 Adam Thompson. All rights reserved.
//

import UIKit

class BeatView: UIView {
    
//    let darkGreyColor: UIColor!
    var startShape: CGPath!
    var endShape: CGPath!
    var beatCircleLayer: CAShapeLayer!
    var startColor = UIColor(red: (200.0/255.0), green: (200.0/255.0), blue: (200.0/255.0), alpha: 1.0)
    var endColor = UIColor(red: (200.0/255.0), green: (200.0/255.0), blue: (200.0/255.0), alpha: 0.0)
    var startDiameter = 2.0
    
//    override init (frame : CGRect) {
//        super.init(frame : frame)
//        addBehavior()
//    }
//    convenience init () {
//        self.init(frame: CGRectZero)
//    }
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    func addBehavior (){
//        self.backgroundColor = UIColor.clearColor()
//        drawBeatCircle()
//    }
    
    
    
//    func drawBeatCircle() {
//        
//        self.beatCircleLayer = CAShapeLayer()
//        beatCircleLayer.path = startShape
//        
//        //change the fill color
//        beatCircleLayer.fillColor = UIColor.redColor().CGColor
//        //you can change the stroke color
//        beatCircleLayer.strokeColor = UIColor.clearColor().CGColor
//        //you can change the line width
//        beatCircleLayer.lineWidth = 3.0
//        
//        self.layer.addSublayer(beatCircleLayer)
//    }
    
//    func animateBeatCircle(beatDuration: NSTimeInterval) {
//        // animate the `path`
//        let animation = CABasicAnimation(keyPath: "path")
//        animation.toValue = endShape
//        animation.duration = beatDuration // duration is 1 sec
//        // 3
//        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
//        animation.fillMode = kCAFillModeBoth // keep to value after finishing
//        animation.removedOnCompletion = false // don't remove after finishing
//        // 4
//        beatCircleLayer.addAnimation(animation, forKey: animation.keyPath)
//    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "BeatCircleView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    */
//    override func drawRect(rect: CGRect) {
//        var path = UIBezierPath(ovalInRect: rect)
//        UIColor.greenColor().setFill()
//        path.fill()
//    }
    
    

}
