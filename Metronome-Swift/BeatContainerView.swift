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
    
    let startColor = UIColor.white
    let endAlpha: CGFloat = 0
    var startDiameter: CGFloat = 128
    var endScale: CGFloat = 10
//    let initialCirclePadding: CGFloat = 128
    
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var defaultLocationX: CGFloat!
    var defaultLocationY: CGFloat!
    var viewCentreX: CGFloat!
    var viewCentreY: CGFloat!
    var currentOrientation: String = "portrait"
    var originalOrientation: String = "portrait"
    
    var startShape: CGPath!
    var beatCircleLayer: CAShapeLayer!
    
    override func draw(_ rect: CGRect) {
        print("Called DrawRect")
//        self.startDiameter = 10.0
//        let h2 = Double(view.frame.height) * Double(view.frame.height)
//        let w2 = Double(view.frame.width) * Double(view.frame.width)
//        let endDiameter = CGFloat(sqrt(h2 + w2))
//        self.endScale = CGFloat(endDiameter/self.startDiameter) * 1.2
//        self.startDiameter = CGFloat(endDiameter/self.startDiameter) * 1.2
        
        self.viewCentreX = rect.width/2
        self.viewCentreY = rect.height/2
        self.defaultLocationX = viewCentreX - CGFloat(self.startDiameter/2)
        self.defaultLocationY = viewCentreY - CGFloat(self.startDiameter/2)
        
        self.startShape = UIBezierPath(ovalIn: CGRect(x: defaultLocationX, y: defaultLocationY, width: self.startDiameter, height: self.startDiameter)).cgPath
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
            let hypotenuse = CGFloat(sqrt(Double(self.screenWidth * self.screenWidth + self.screenHeight * self.screenHeight)))
            
            self.startDiameter = min(self.screenWidth, self.screenHeight) * 0.5
//            self.endScale = 0.1
            
            self.endScale = hypotenuse/self.startDiameter * 1.5
            
            // Create two BeatView for each beat in the Time Signature
            // plus one for timer and one for taps
            for beat in 0...timeSignature*2-1 {
                print("Initializing \(beat) ")
                let newBeatView = BeatView(
                    frame: CGRect(x: 0.0, y: 0.0, width: startDiameter, height: startDiameter)
                )
                newBeatView.center = self.center
                newBeatView.layer.cornerRadius = CGFloat(startDiameter/2.0)
                newBeatView.backgroundColor = startColor//UIColor.redColor()
                newBeatView.isHidden = true
                BeatViewsArray.append(newBeatView)
                self.addSubview(BeatViewsArray[beat])
                
//                print("Size: \(BeatViewsArray[beat].frame.height)")
        }
            
        self.beatCircleLayer = CAShapeLayer()
        beatCircleLayer.path = startShape
        self.layer.addSublayer(beatCircleLayer)
        }
        allBeatsInitialized = true
    }
    
    func removeAllBeatCircles() {
        for b in 0...BeatViewsArray.count-1 {
            print(BeatViewsArray.count)
            beatCircleReset(b)
            BeatViewsArray[b].removeFromSuperview()
            BeatViewsArray.remove(at: b)
        }
    }
    
    func animateBeatCircle(beatIndex: Int, beatDuration: Double, startPoint: CGPoint? = nil) {
        let thisBeat = self.BeatViewsArray[beatIndex]
//        self.beatCircleReset(beatIndex) // make sure it's reset
//        print("Animating Beat index \(beatIndex)")
        
       //  handle startPoint
        if (startPoint != nil) {
//            print("Tap Location: \(String(describing: startPoint))")
            thisBeat.frame.origin.x = startPoint!.x - thisBeat.frame.width/2
            thisBeat.frame.origin.y = startPoint!.y - thisBeat.frame.height/2
        }
        else {
            if self.currentOrientation == self.originalOrientation{
                thisBeat.frame.origin.x = self.defaultLocationX
                thisBeat.frame.origin.y = self.defaultLocationY
            }
            else {
                thisBeat.frame.origin.x = self.defaultLocationY
                thisBeat.frame.origin.y = self.defaultLocationX
            }
        }
        
        // setup the animation
        thisBeat.isHidden = false
        let beatAnimation = { () -> Void in
            let scaleTransform = CGAffineTransform(scaleX: self.endScale, y: self.endScale)
            thisBeat.alpha = self.endAlpha
            thisBeat.transform = scaleTransform
        }
        
        // Do the animation
        UIView.animate(withDuration: beatDuration * 2, delay: 0, options: [.curveEaseOut], animations: beatAnimation,
           completion:  { finished in
                self.beatCircleReset(beatIndex) // reset circle once the animation is finished
        })
    }
    
    func beatCircleReset(_ beatIndex:Int) {
        let thisBeat = self.BeatViewsArray[beatIndex]
        let resetScaleTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        print("... Resetting beat index \(beatIndex)")
        thisBeat.transform = resetScaleTransform
        thisBeat.alpha = 1
        thisBeat.isHidden = true
    }
    
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
