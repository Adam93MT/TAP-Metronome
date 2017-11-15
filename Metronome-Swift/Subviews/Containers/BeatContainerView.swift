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
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // The array of all circles
    var BeatViewsArray = [BeatView]()
    var TapBeatViewsArray = [BeatView]()
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
    
    var startShape: CGPath!
    var beatCircleLayer: CAShapeLayer!
    
    // DEBUG vars ------
    var timebaseInfo = mach_timebase_info_data_t()
    var total_error: Float = 0
    var avg_error: Float = 0
    // ------------
    
    override func draw(_ rect: CGRect) {
        self.viewCentreX = rect.width/2
        self.viewCentreY = rect.height/2
        self.defaultLocationX = viewCentreX - CGFloat(self.startDiameter/2)
        self.defaultLocationY = viewCentreY - CGFloat(self.startDiameter/2)
        
        self.startShape = UIBezierPath(ovalIn: CGRect(x: defaultLocationX, y: defaultLocationY, width: self.startDiameter, height: self.startDiameter)).cgPath
        self.beatCircleLayer = CAShapeLayer()
        setup()
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        setup()
    }
    
    private func absToNanos(_ abs: UInt64) -> UInt64 {
        mach_timebase_info(&timebaseInfo)
        // https://shiftedbits.org/2008/10/01/mach_absolute_time-on-the-iphone/
        return abs * UInt64(timebaseInfo.numer)/UInt64(timebaseInfo.denom)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initAllBeatCircles(_ timeSignature: Int) {
        if allBeatsInitialized == false {
            print("Initializing All Circles...")
            self.total_error = 0
            
            let hypotenuse = CGFloat(sqrt(Double(self.screenWidth * self.screenWidth + self.screenHeight * self.screenHeight)))
            
            self.startDiameter = min(self.screenWidth, self.screenHeight) * 0.5
            
            self.endScale = hypotenuse/self.startDiameter * 1.5
            
            let maxTS = delegate.metronome.possibleTimeSignatures.max()!
            for b in 0...maxTS-1 {
                let newBeat = BeatView(
                    frame: CGRect(x: 0.0, y: 0.0, width: startDiameter, height: startDiameter)
                )
                newBeat.center = self.center
                newBeat.layer.cornerRadius = CGFloat(startDiameter/2.0)
                newBeat.backgroundColor = startColor
                newBeat.isHidden = true
                BeatViewsArray.append(newBeat)
                self.addSubview(BeatViewsArray[b])
                
                let newBeatTap = BeatView(
                    frame: CGRect(x: 0.0, y: 0.0, width: startDiameter, height: startDiameter)
                )
                newBeatTap.center = self.center
                newBeatTap.layer.cornerRadius = CGFloat(startDiameter/2.0)
                newBeatTap.backgroundColor = startColor
                newBeatTap.isHidden = true
                TapBeatViewsArray.append(newBeatTap)
                self.addSubview(TapBeatViewsArray[b])
        }
            
        self.beatCircleLayer = CAShapeLayer()
        beatCircleLayer.path = startShape
        self.layer.addSublayer(beatCircleLayer)
        }
        allBeatsInitialized = true
    }
    
    func removeAllBeatCircles() {
        for b in 0...BeatViewsArray.count-1 {
            beatCircleReset(b)
            BeatViewsArray[b].removeFromSuperview()
            TapBeatViewsArray[b].removeFromSuperview()
//            BeatViewsArray.remove(at: b)
        }
    }
    
    func animateBeatCircle(beatIndex: Int, beatDuration: Double, startPoint: CGPoint? = nil) {
        var thisBeat: BeatView!
        
        // Beat was triggered by a tap if startPoint != nil
        if (startPoint != nil) {
            thisBeat = self.TapBeatViewsArray[beatIndex]
            thisBeat.frame.origin.x = startPoint!.x - thisBeat.frame.width/2
            thisBeat.frame.origin.y = startPoint!.y - thisBeat.frame.height/2
        }
        else {
            thisBeat = self.BeatViewsArray[beatIndex]
            if self.currentOrientation == originalOrientation {
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
        let animationDuration = beatDuration * 2.0
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: beatAnimation,
           completion:  { finished in
                self.beatCircleReset(beatIndex) // reset circle once the animation is finished
        })
        
        // --- Error logging ---
        let delay = mach_absolute_time() - delegate.metronome.current_time
        let delay_ms = Float(delay) / Float(NSEC_PER_MSEC)
        print("Animation Delay \(delay_ms) ms")
        if delay_ms < 1000 { self.total_error += delay_ms }
    }
    
    func beatCircleReset(_ beatIndex:Int) {
        let thisBeat = self.BeatViewsArray[beatIndex]
        let thisBeatTap = self.TapBeatViewsArray[beatIndex]
        let resetScaleTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        thisBeat.transform = resetScaleTransform
        thisBeatTap.transform = resetScaleTransform
        thisBeat.alpha = 1
        thisBeatTap.alpha = 1
        thisBeat.isHidden = true
        thisBeatTap.isHidden = true
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
