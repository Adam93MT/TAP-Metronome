//
//  TapDownGestureRecognizer.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-07.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class TapDownGestureRecognizer: UITapGestureRecognizer {
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        self.delaysTouchesBegan = false
//        self.delaysTouchesEnded = false
        self.numberOfTapsRequired = 1
        self.numberOfTouchesRequired = 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        print("\(touches.count) fingers")
        print("State: \(self.state.hashValue)")

        if (touches.count > self.numberOfTouchesRequired) {
            self.state = .failed
        }
        if self.state == .possible {
            self.state = .recognized
        }
    }
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
//        print("touchesMoved")
//        self.state = .failed
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
//        print("touchesEnded")
//        self.state = .failed // fail on touch up
//    }
}
