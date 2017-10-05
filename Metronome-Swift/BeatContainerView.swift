//
//  BeatCircleView.swift
//  TAP Metronome
//
//  Created by Adam Thompson on 2016-06-19.
//  Copyright (c) 2016 Adam Thompson. All rights reserved.
//

import UIKit

class BeatContainerView: UIView {
    
    var view:UIView!
    
    // The array of all circles
    var BeatViewsArray = [BeatView]()
    var allBeatsInitialized: Bool = false
    
    let startColor = UIColor.white//UIColor(red: (200.0/255.0), green: (200.0/255.0), blue: (200.0/255.0), alpha: 1.0)
    let endColor = UIColor(red: (200.0/255.0), green: (200.0/255.0), blue: (200.0/255.0), alpha: 0.0)
    
    let startDiameter: CGFloat = 128
//    var endDiameter: CGFloat!
    var animationScale: CGFloat!
    var startShape: CGPath!
    var endShape: CGPath!
    var beatCircleLayer: CAShapeLayer!
    
    override func draw(_ rect: CGRect) {
        print("Called DrawRect")
//        self.startDiameter = 10.0
        let h2 = Double(view.frame.height) * Double(view.frame.height)
        let w2 = Double(view.frame.width) * Double(view.frame.width)
        let endDiameter = CGFloat(sqrt(h2 + w2))
        self.animationScale = CGFloat(endDiameter/self.startDiameter) * 1.2
//        print("Scale: \(animationScale)")
        
        let viewCentreX = rect.width/2
        let viewCentreY = rect.height/2
        let startX = viewCentreX - CGFloat(self.startDiameter/2)
        let startY = viewCentreY - CGFloat(self.startDiameter/2)
//        let endX = viewCentreX - CGFloat(self.endDiameter/2)
//        let endY = viewCentreY - CGFloat(self.endDiameter/2)
        
        self.startShape = UIBezierPath(ovalIn: CGRect(x: startX, y: startY, width: self.startDiameter, height: self.startDiameter)).cgPath
//        self.endShape = UIBezierPath(ovalIn: CGRect(x: endX, y: endY, width: self.endDiameter, height: self.endDiameter)).cgPath
        self.beatCircleLayer = CAShapeLayer()
        setup()
//        addBehavior()
    }
    
    override init (frame : CGRect) {
        print("init BeatContainerView")
        super.init(frame : frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initAllBeatCircles(_ timeSignature: Int) {
        if allBeatsInitialized == false {
            print("Initializing All Circles")
            // Create one BeatView for each beat in the Time Signature
            for beat in 0...timeSignature-1 {
                print("Initializing \(beat) ")
                let newBeatView = BeatView(frame: CGRect(x: 0.0, y: 0.0, width: startDiameter, height: startDiameter))
                newBeatView.center = self.center
                newBeatView.layer.cornerRadius = CGFloat(startDiameter/2.0)
                newBeatView.backgroundColor = startColor//UIColor.redColor()
                newBeatView.endColor = endColor
                newBeatView.startDiameter = startDiameter
                newBeatView.isHidden = true
                BeatViewsArray.append(newBeatView)
                self.addSubview(BeatViewsArray[beat])
                
//                print("Size: \(BeatViewsArray[beat].frame.height)")
        }
            
        self.beatCircleLayer = CAShapeLayer()
        beatCircleLayer.path = startShape
        beatCircleLayer.fillColor = UIColor.blue.cgColor     //change the fill color
        beatCircleLayer.strokeColor = UIColor.clear.cgColor  //you can change the stroke color
        beatCircleLayer.lineWidth = 0 //you can change the line width
        self.layer.addSublayer(beatCircleLayer)
        }
        allBeatsInitialized = true
    }
    
    func removeAllBeatCircles() {
        for _ in 0...BeatViewsArray.count-1 {
            print(BeatViewsArray.count)
            beatCircleReset(1)
            BeatViewsArray[0].removeFromSuperview()
            BeatViewsArray.remove(at: 0)
        }
    }
    
    func animateBeatCircle(_ beat: Int, beatDuration: Double) {
        print("Animating Beat Circle... \(beat)")
        self.BeatViewsArray[beat-1].isHidden = false
        let beatAnimation = { () -> Void in
            let scaleTransform = CGAffineTransform(scaleX: self.animationScale, y: self.animationScale)
            self.BeatViewsArray[beat-1].backgroundColor = self.endColor
            self.BeatViewsArray[beat-1].transform = scaleTransform
        }
        
        let animDelay = 1.5
        UIView.animate(withDuration: beatDuration * animDelay, animations: beatAnimation, completion:  { finished in
            self.beatCircleReset(beat)
        })
    }
    
    func beatCircleReset(_ beat:Int) {
        let resetScaleTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.BeatViewsArray[beat-1].transform = resetScaleTransform
        self.BeatViewsArray[beat-1].backgroundColor = startColor
        self.BeatViewsArray[beat-1].isHidden = true
    }
    
//    func animateBeatCircle(beatDuration: Double) {
//        // animate the `path`
//        let animation = CABasicAnimation(keyPath: "path")
//        animation.toValue = endShape
//        animation.duration = beatDuration // duration is 1 sec
//
//        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
//        animation.fillMode = kCAFillModeBoth // keep to value after finishing
//        animation.isRemovedOnCompletion = false // don't remove after finishing
//
//        beatCircleLayer.add(animation, forKey: animation.keyPath)
//    }
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        //view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for:type(of: self))
        let nib = UINib(nibName: "BeatCircleView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
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
