
import UIKit
import XCPlayground

var darkGreyColor = UIColor(red: (20.0/255.0), green: (20.0/255.0), blue: (20.0/255.0), alpha: 1.0)
var darkGreyTransparent = UIColor(red: (50.0/255.0), green: (50.0/255.0), blue: (50.0/255.0), alpha: 0.0)
var lightGreyColor = UIColor(red: (200.0/255.0), green: (200.0/255.0), blue: (200.0/255.0), alpha: 1.0)
var lightGreyTransparent = UIColor(red: (200.0/255.0), green: (200.0/255.0), blue: (200.0/255.0), alpha: 0.0)

let startingColor = lightGreyColor
let endColor = lightGreyTransparent

let tempo = 60.0 //bpm
let beatTime = 60.0/tempo //seconds

let startDiameter = 2.0
let animationScale = CGFloat(667/startDiameter*1.2)

let BeatCircleView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 375.0, height: 667.0))
BeatCircleView.backgroundColor = darkGreyColor
XCPShowView(identifier: "Container View", view: BeatCircleView)


let BeatView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: startDiameter, height: startDiameter))

// IN CLASS BeatView

func drawBeatCircle(beatCircle: UIView) {
    beatCircle.center = BeatCircleView.center
    beatCircle.layer.cornerRadius = CGFloat(startDiameter/2.0)
    beatCircle.backgroundColor = startingColor
    BeatCircleView.addSubview(beatCircle)
}


func animateBeatCircle(beatCircle: UIView, beatDuration: TimeInterval) {

    print(beatCircle)
    
    let beatAnimation = { () -> Void in
        beatCircle.backgroundColor = endColor
        let scaleTransform = CGAffineTransform(scaleX: animationScale, y: animationScale)
        beatCircle.transform = scaleTransform
    }
    
    UIView.animate(withDuration: beatDuration, animations: beatAnimation)
}
func resetBeatCircle(beatCircle: UIView) {
    beatCircle.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
}


//MAIN
drawBeatCircle(beatCircle: BeatView)
animateBeatCircle(beatCircle: BeatView, beatDuration: TimeInterval(beatTime))




