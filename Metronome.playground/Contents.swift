//: Playground - noun: a place where people can play

import UIKit
import Foundation
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely()

class Metronome {
    
    var metronomeTimer: NSTimer!
    var tempo = 120.0
    var timeInterval: NSTimeInterval!
    var lastBeat = CFAbsoluteTimeGetCurrent()
    var current_time = CFAbsoluteTimeGetCurrent()
    var error: CFTimeInterval = 0
    var total_error: CFTimeInterval = 0
    var avg_error: CFTimeInterval = 0
    
    var beat = 1
    var total_clicks = 0
    
    func start() {
        timeInterval = 60.0/self.tempo
        metronomeTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "playBeat:", userInfo: nil, repeats: true)
    }
    
    func stop() {
        metronomeTimer.invalidate()
    }
    
    @objc func playBeat(timer:NSTimer!) {
        current_time = CFAbsoluteTimeGetCurrent()
        error = timeInterval - (current_time - lastBeat)
        total_error = total_error + error
        
        print("\(beat) Click: \(total_clicks)")
        print("Avg. Error: \(total_error/Double(total_clicks))")
        
        lastBeat = current_time
        incrementBeat()
    }
    
    func incrementBeat() {
        beat += 1
        if(beat > 4) {
            beat = 1
        }
        total_clicks += 1
        
        // Debug stop/start
        if (total_clicks > 100) {
            self.stop()
            total_clicks = 0
            beat = 1
            self.start()
        }
    }
}

var myMetro = Metronome()

myMetro.start()