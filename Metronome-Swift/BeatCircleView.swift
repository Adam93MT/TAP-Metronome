//
//  BeatCircleView.swift
//  TAP Metronome
//
//  Created by Adam Thompson on 2016-06-19.
//  Copyright (c) 2016 Adam Thompson. All rights reserved.
//

import UIKit

class BeatCircleView: UIView {
    
    var view:UIView!
    
    var startShape: CGPath!
    var startDiameter: CGFloat!
//    var startColor =
    
    var endShape: CGPath!
    var endDiameter: CGFloat!
//    var endColor = 
    
    var beatCircleLayer: CAShapeLayer!
    
    
    override func drawRect(rect: CGRect) {
        println("Called DrawRect")
        startDiameter = 10
        endDiameter = 766
        var viewCentreX = rect.width/2
        var viewCentreY = rect.height/2
        var startX = viewCentreX - startDiameter/2
        var startY = viewCentreY - startDiameter/2
        var endX = viewCentreX - endDiameter/2
        var endY = viewCentreY - endDiameter/2
        
        self.startShape = UIBezierPath(ovalInRect: CGRectMake(startX, startY, startDiameter, startDiameter)).CGPath
        self.endShape = UIBezierPath(ovalInRect: CGRectMake(endX, endY, endDiameter, endDiameter)).CGPath
        self.beatCircleLayer = CAShapeLayer()
        setup()
        addBehavior()
    }
    
    override init (frame : CGRect) {
        println("Called Init")
        super.init(frame : frame)
//        self.startShape = UIBezierPath(ovalInRect: CGRectMake(187.5, 333.5, 5, 5)).CGPath
//        self.endShape = UIBezierPath(ovalInRect: CGRectMake(-195.5, -49.5, 766, 766)).CGPath
//        self.beatCircleLayer = CAShapeLayer()
        setup()
//        addBehavior()
    }
    convenience init () {
        println("Init Convenience")
        self.init(frame: CGRectZero)
        setup()
    }
    required init(coder aDecoder: NSCoder) {
        println("Init Required")
        super.init(coder: aDecoder)
        setup()
    }

    func addBehavior (){
        self.backgroundColor = UIColor.clearColor()
        drawBeatCircle()
    }
    
    
    func drawBeatCircle() {
        self.beatCircleLayer = CAShapeLayer()
        beatCircleLayer.path = startShape
        
        beatCircleLayer.fillColor = UIColor.blueColor().CGColor     //change the fill color
        beatCircleLayer.strokeColor = UIColor.clearColor().CGColor  //you can change the stroke color
        beatCircleLayer.lineWidth = 0 //you can change the line width
        
        self.layer.addSublayer(beatCircleLayer)
    }
    
    func animateBeatCircle(beatDuration: NSTimeInterval) {
        // animate the `path`
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = endShape
        animation.duration = beatDuration // duration is 1 sec

        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
        animation.fillMode = kCAFillModeBoth // keep to value after finishing
        animation.removedOnCompletion = false // don't remove after finishing

        beatCircleLayer.addAnimation(animation, forKey: animation.keyPath)
    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass:self.dynamicType)
        let nib = UINib(nibName: "BeatCircleView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
