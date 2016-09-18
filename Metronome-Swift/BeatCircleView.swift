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
    
    // The array of all circles
    var BeatViewsArray = [BeatView]()
    var allBeatsInitialized: Bool = false
    
    let startColor = UIColor(red: (200.0/255.0), green: (200.0/255.0), blue: (200.0/255.0), alpha: 1.0)
    let endColor = UIColor(red: (200.0/255.0), green: (200.0/255.0), blue: (200.0/255.0), alpha: 0.0)
    
    let startDiameter = 2.0
    
    var beatCircleLayer: CAShapeLayer!
    
    
//    override func drawRect(rect: CGRect) {
//        println("Called DrawRect")
//        startDiameter = 10
//        endDiameter = 766
//        var viewCentreX = rect.width/2
//        var viewCentreY = rect.height/2
//        var startX = viewCentreX - startDiameter/2
//        var startY = viewCentreY - startDiameter/2
//        var endX = viewCentreX - endDiameter/2
//        var endY = viewCentreY - endDiameter/2
//        
//        self.startShape = UIBezierPath(ovalInRect: CGRectMake(startX, startY, startDiameter, startDiameter)).CGPath
//        self.endShape = UIBezierPath(ovalInRect: CGRectMake(endX, endY, endDiameter, endDiameter)).CGPath
//        self.beatCircleLayer = CAShapeLayer()
//        setup()
//        addBehavior()
//    }
    
    override init (frame : CGRect) {
        println("Called override Init")
        super.init(frame : frame)
        setup()
    }
//    convenience init () {
//        println("Init Convenience")
//        self.init(frame: CGRectZero)
//        setup()
//    }
    required init(coder aDecoder: NSCoder) {
        println("Init Required")
        super.init(coder: aDecoder)
        setup()
    }

    func addBehavior (){
        self.backgroundColor = UIColor.clearColor()
//        self.initAllBeatCircles()
    }
    
    
    func initAllBeatCircles(timeSignature: Int) {
        if allBeatsInitialized == false {
        println("Initializing All Circles")
        // Create one BeatView for each beat in the Time Signature
        for beat in 0...timeSignature-1 {
            println("Initializing \(beat) ")
            var newBeatView = BeatView(frame: CGRect(x: 0.0, y: 0.0, width: startDiameter, height: startDiameter))
            BeatViewsArray.append(newBeatView)
            BeatViewsArray[beat].center = self.center
            BeatViewsArray[beat].layer.cornerRadius = CGFloat(startDiameter/2.0)
            BeatViewsArray[beat].backgroundColor = startColor//UIColor.redColor()
            BeatViewsArray[beat].endColor = endColor
            BeatViewsArray[beat].startDiameter = startDiameter
            self.addSubview(BeatViewsArray[beat])
            BeatViewsArray[beat].hidden = true
            
            println("Size: \(BeatViewsArray[beat].frame.height)")
        }
            
//        self.beatCircleLayer = CAShapeLayer()
//        beatCircleLayer.path = startShape
//        beatCircleLayer.fillColor = UIColor.blueColor().CGColor     //change the fill color
//        beatCircleLayer.strokeColor = UIColor.clearColor().CGColor  //you can change the stroke color
//        beatCircleLayer.lineWidth = 0 //you can change the line width
//        self.layer.addSublayer(beatCircleLayer)
        }
        allBeatsInitialized = true
    }
    
    func removeAllBeatCircles() {
        var totalBeats = BeatViewsArray.count
        for beat in 0...totalBeats-1 {
            println(BeatViewsArray.count)
            beatCircleReset(1)
            BeatViewsArray[0].removeFromSuperview()
            BeatViewsArray.removeAtIndex(0)
        }
    }
    
    func animateBeatCircle(beat:Int, beatDuration:NSTimeInterval) {
        //println("Animating Beat Circle... \(beat)")
        self.BeatViewsArray[beat-1].hidden = false
        var animationScale = CGFloat(667/self.startDiameter*1.2)
        var beatAnimation = { () -> Void in
            let scaleTransform = CGAffineTransformMakeScale(animationScale, animationScale)
            self.BeatViewsArray[beat-1].backgroundColor = self.endColor
            self.BeatViewsArray[beat-1].transform = scaleTransform
        }
    
        
        //UIView.animateWithDuration(beatDuration*2, animations: beatAnimation)
        UIView.animateWithDuration(beatDuration*2, animations: beatAnimation, completion:  { finished in
            //println("Beat \(beat) done")
            self.beatCircleReset(beat)
        })
        
        //BeatViewsArray[beat].animateBeat(beatDuration)
    }
    
    func beatCircleReset(beat:Int) {
        let resetScaleTransform = CGAffineTransformMakeScale(1.0, 1.0)
        self.BeatViewsArray[beat-1].transform = resetScaleTransform
        self.BeatViewsArray[beat-1].backgroundColor = startColor//UIColor.redColor()
        self.BeatViewsArray[beat-1].hidden = true
        
    }
    
//    func animateBeatCircle(beatDuration: NSTimeInterval) {
//        // animate the `path`
//        let animation = CABasicAnimation(keyPath: "path")
//        animation.toValue = endShape
//        animation.duration = beatDuration // duration is 1 sec
//
//        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
//        animation.fillMode = kCAFillModeBoth // keep to value after finishing
//        animation.removedOnCompletion = false // don't remove after finishing
//
//        beatCircleLayer.addAnimation(animation, forKey: animation.keyPath)
//    }
    
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
