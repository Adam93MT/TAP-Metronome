//
//  MetronomeLogic.swift
//  Metronome-Swift
//
//  Created by Adam Thompson on 2016-06-16.
//  Copyright (c) 2016 Adam Thompson. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation


class Metronome {
    let metronomeSoundURL = URL(fileURLWithPath: Bundle.main.path(forResource: "metronomeClick", ofType: "mp3")!)
    let downBeatSoundURL = URL(fileURLWithPath: Bundle.main.path(forResource: "downBeatClick", ofType: "mp3")!)
    var beatClick: AVAudioPlayer!
    var downBeatClick: AVAudioPlayer!
    
    var beatTimer: Timer!
    var timeInterval: TimeInterval!
    var parentViewController: MetronomeViewController!
    
    var isPrepared: Bool = false
    var isOn: Bool = false

    var timeSignature: Int = 4 // default is 4:4
    var beat = 1
    var tempo: Int!
    
    // DEBUG ------
    var lastBeat = CFAbsoluteTimeGetCurrent()
    var expectedBeatTime: Date!
    var playedLastBeat: Bool = false
    var current_time = CFAbsoluteTimeGetCurrent()
    
    var total_beats = 0
    var error: CFTimeInterval = 0
    var total_error: CFTimeInterval = 0
    var avg_error: CFTimeInterval = 0
    // ------------
    
    func prepare() {
        self.beatClick = try? AVAudioPlayer(contentsOf: metronomeSoundURL)
        self.downBeatClick = try? AVAudioPlayer(contentsOf: downBeatSoundURL)
        self.beatClick.prepareToPlay()
        self.downBeatClick.prepareToPlay()
        
        if parentViewController != nil {
            parentViewController.beatCircleView.initAllBeatCircles(timeSignature)
        }
        
        timeInterval = TimeInterval(60.0/Double(tempo))
        beatTimer = Timer(timeInterval: timeInterval, target: self, selector: #selector(Metronome.startTimer(_:)), userInfo: nil, repeats: false)
//        print("Expected Fire Date \(beatTimer.fireDate.timeIntervalSinceNow)")
//        print("Prepared: \(beatTimer.timeInterval) seconds")
        
        self.beat = 1
        self.isPrepared = true
        
        //-- Debug
    }
    
    func start() {
        if (!self.isPrepared) {
            self.prepare()
        }
        self.isOn = true

        beatTimer.fireDate = Date()
        print(beatTimer.fireDate.timeIntervalSinceNow)
        RunLoop.current.add(beatTimer, forMode: RunLoopMode.commonModes)

//        beatTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "startTimer:", userInfo: nil, repeats: true)
        print("---Started---")
//        println("Next Fire Time: \(expectedBeatTime.timeIntervalSince1970)")
        
    }
    
    @objc func startTimer(_ timer: Timer!) {
        
        prepareForNextBeat()
        self.playBeat()
        updateTimer()
        
        
    // DEBUG -----
//        if (!playedLastBeat){
//            println("Skipped Click")
//        }
//        println("Fire Date Error: \(-beatTimer.fireDate.timeIntervalSinceNow)")
//        current_time = CFAbsoluteTimeGetCurrent()
//        error = timeInterval - (current_time - lastBeat)
//        total_error = total_error + error
//        avg_error = total_error/Double(total_beats)
//        println("Avg. Error: \(avg_error)")
//        lastBeat = current_time
    // -----------
    }
    
    func playBeat() {
        parentViewController.beatCircleView.animateBeatCircle(beat, beatDuration: timeInterval)
        //parentViewController.DEBUG_beatLabel.text = String(beat)
        playSound()
        incrementBeat()
        print("Time Interval: \(timeInterval)")
    }
    
    func playSound() {
        if (beat == 1) {
            downBeatClick.play()
            playedLastBeat = true
        }
        else if (beat == 4 && timeSignature == 6) {}
        else {
            beatClick.play()
            playedLastBeat = true
        }
        //println("*click* - Beat \(beat)")
    }
    
    func incrementBeat() {
        beat += 1
        if (beat > timeSignature) {
            beat = 1
        }
        total_beats += 1
        
        // Check how many beats have been played w/o manually tapping
        untappedBeats += 1
        if untappedBeats >= 4
        {
            if loggedTaps.count > 0 {
                // remove the oldest logget tap time
                print("Removing oldest Tap")
                loggedTaps.remove(at: 0)
            }
        }
    }
    
    func prepareForNextBeat() {
        downBeatClick.pause()
        downBeatClick.currentTime = 0
        beatClick.pause()
        beatClick.currentTime = 0
        
        //--
        playedLastBeat = false
        if (newTempoSet) {
            parentViewController.tempoLabel.text = String(tempo)
            parentViewController.tempoSlider.setValue(Float(tempo), animated: true)
        }
    }

    func stop() {
        self.beatTimer.invalidate()
        print(" ---- Stopping Metronome ---- ")
        print("Average Error = \(avg_error)")
        print("Expected Error = \(1.0/Double(tempo*tempo))")
        // Mark the metronome as off.
        self.isPrepared = false
        self.isOn = false
        self.beat = 1
        self.prepare()
        self.loggedTaps.removeAll()
        
        //-- Debug
        total_beats = 0
        error = 0
        total_error = 0
        avg_error = 0
    }
    
    // Beat Logging
    
    var loggedTaps = [CFAbsoluteTime]()
    var untappedBeats: Int = 0
    var newTempoSet: Bool = false
    
    func logTap() {
        print("Logging Tap")
        loggedTaps.append(CFAbsoluteTimeGetCurrent())
        if loggedTaps.count >= 4 {
            var total_diff = 0.0
            for t in (max(1,loggedTaps.count - 8)...loggedTaps.count-1).reversed() {
                var diff = loggedTaps[t] - loggedTaps[t-1]
                print("index \(t), diff \(diff)")
                if diff < 1.0 {
                    total_diff += diff
                }
            }
            // weight the tap diff with the current tempo
            print(total_diff)
            let avg_tap_diff = (total_diff)/Double(min(loggedTaps.count - 2, 8))
            print(avg_tap_diff)
            setTimeInterval(newInterval: TimeInterval(avg_tap_diff))
        }
    }
    
    func setTempo(newTempo: Int){
        tempo = newTempo
        timeInterval = TimeInterval(60.0/Double(tempo))
        print("New Tempo: \(tempo)")
        newTempoSet = true
    }
    
    func setTimeInterval(newInterval: TimeInterval){
        timeInterval = newInterval
        tempo = Int(60.0/Double(timeInterval))
        print("New Time Interval \(timeInterval)")
        print("New Tempo: \(tempo)")
        newTempoSet = true
    }
    
    func updateTimer() {
        beatTimer = Timer(timeInterval: timeInterval, target: self, selector: #selector(Metronome.startTimer(_:)), userInfo: nil, repeats: false)
        RunLoop.current.add(beatTimer, forMode: RunLoopMode.commonModes)
    }
    
    
    
    
    
    
    
}
