//
//  TapDownGestureRecognizer.swift
//  TAP Metronome-Swift
//
//  Created by Adam M Thompson on 2017-10-07.
//  Copyright © 2017 Adam Thompson. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class TapDownGestureRecognizer: UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .possible {
            self.state = .recognized
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
}
