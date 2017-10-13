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
import AudioToolbox

@available(iOS 10.0, *)
class MachMetronome {
//    let metronomeSoundURL = URL(fileURLWithPath: Bundle.main.path(forResource: "metronomeClick", ofType: "mp3")!)
    let metronomeSoundURL = URL(fileURLWithPath: Bundle.main.path(forResource: "beatClick", ofType: "wav")!)
//    let downBeatSoundURL = URL(fileURLWithPath: Bundle.main.path(forResource: "downBeatClick", ofType: "mp3")!)
    
    var beatClick: AVAudioPlayer!
//    var downBeatClick: AVAudioPlayer!

    var parentViewController: MetronomeViewController!
    
    let minTempo: Int = 50
    let maxTempo: Int = 220
    var timeSignature: Int = 4 // default is 4:4
    var beat = 1
    var tempo: Int = 100
    var interval: Float = 0.6
    var nextWhen: UInt64!
    var nextNextWhen: UInt64!
    
    var isPrepared: Bool = false
    var isOn: Bool = false
    var newTempoIsSet: Bool = false
    var playedLastBeat: Bool = false
    var tapOverride: Bool = false
    var isFirstBeat: Bool = true
    
    // Beat Logging
    var loggedDiffs = [Float]()
    var lastTapTime = mach_absolute_time()
    var untappedBeats: Int = 0
    let beatsToHideUI: Int = 16
    
    // DEBUG ------
    var lastBeat: UInt64 = 0
    var last_fire_time: UInt64 = 0
    var expected_fire_time: UInt64 = 0
    var current_time: UInt64 = 0
    
    var total_beats = 0
    var error: UInt64 = 0
    var total_error: UInt64 = 0
    var avg_error: Double = 0
    // ------------
    
    init() {
        print("init metronome")
        self.configureThread()
    }
    
    // Getter functions
    
    func getBeat() -> Int {
        return self.beat
    }
    
    func getBeatIndex() -> Int {
        return self.beat - 1
    }
    
    func getTempo() -> Int {
        return self.tempo
    }
    
    func getInterval() -> Float {
        return self.interval
    }
    
    func getTimeSignature() -> Int {
        return self.timeSignature
    }
    
    // Configure High-Priority Timer
    var timebaseInfo = mach_timebase_info_data_t()
    
    func configureThread() {
        mach_timebase_info(&timebaseInfo)
        let clock2abs = Double(timebaseInfo.denom) / Double(timebaseInfo.numer) * Double(NSEC_PER_SEC)
        let period      = UInt32(0.00 * clock2abs)
        let computation = UInt32(0.03 * clock2abs) // 30 ms of work
        let constraint  = UInt32(0.05 * clock2abs)
        
        let THREAD_TIME_CONSTRAINT_POLICY_COUNT = mach_msg_type_number_t(MemoryLayout<thread_time_constraint_policy>.size / MemoryLayout<integer_t>.size)
        
        var policy = thread_time_constraint_policy()
        var ret: Int32
        let thread: thread_port_t = pthread_mach_thread_np(pthread_self())
        
        policy.period = period
        policy.computation = computation
        policy.constraint = constraint
        policy.preemptible = 0
        
        ret = withUnsafeMutablePointer(to: &policy) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(THREAD_TIME_CONSTRAINT_POLICY_COUNT)) {
                thread_policy_set(thread, UInt32(THREAD_TIME_CONSTRAINT_POLICY), $0, THREAD_TIME_CONSTRAINT_POLICY_COUNT)
            }
        }
        
        if ret != KERN_SUCCESS {
            mach_error("thread_policy_set:", ret)
            exit(1)
        }
    }
    
    private func absToNanos(_ abs: UInt64) -> UInt64 {
        return abs * UInt64(timebaseInfo.numer)/UInt64(timebaseInfo.denom)
    }
    private func nanosToAbs(_ nanos: UInt64) -> UInt64 {
        return nanos * UInt64(timebaseInfo.denom) / UInt64(timebaseInfo.numer)
    }
    
    private func startMachTimer() {
        Thread.detachNewThread {
            autoreleasepool {
//                self.configureThread()
                var when = mach_absolute_time()
                self.current_time = when
                self.expected_fire_time = when
                // We only loop if the timer is on
                // we only play a beat if there has not just been a tap
                print(self.timebaseInfo)
                while self.isOn {
                    print("\nNext Beat: \(self.beat) - at \(self.tempo) bpm")
                    // if there has been a logged tempo tap since the last timer firing
                    // we skip playing this beat, and use the rescheduled beat
                    if (self.tapOverride){
                        self.tapOverride = false // reset tapOverride
                        when = self.getNextBeatTime()
                    }
                    // if we just set a new tempo (tapping or otherwise)
                    // we'll skip this beat, and use the rescheduled beat
                    else if (self.newTempoIsSet) {
                        self.newTempoIsSet = false
                        when = self.getNextBeatTime()
                    }
                    // if this is the first beat since starting
                    // the tap to start played beat 1,
                    // so we don't play anthing, and wait till the next beat
                    else if (self.isFirstBeat) {
                        self.isFirstBeat = false
                        when += self.nanosToAbs(
                            UInt64(self.interval * Float(NSEC_PER_SEC))
                        )
                    }
                    // otherwise we play a beat normally
                    else {
                        self.untappedBeats += 1
                        self.signalBeatInMainThread()
                        // hide UI if there have been a lot of beats since tempo change
                        if (self.untappedBeats >= self.beatsToHideUI) {
                            self.hideUIinMainThread()
                        }
                        when += self.nanosToAbs(
                            UInt64(self.interval * Float(NSEC_PER_SEC))
                        )
                        self.last_fire_time = mach_absolute_time()
                    }
                    
//                    self.current_time = mach_absolute_time()
//                    self.error = self.current_time - self.expected_fire_time
//                    self.total_error += self.error
//                    self.total_beats += 1
//                    let err_ms = Double(self.absToNanos(self.error))/Double(NSEC_PER_MSEC)
//                    print("Error: \(err_ms) msec")
//                    print("Error: \(err_ms/Double(self.interval * 1000))%")
                    
//                    self.expected_fire_time = when
                    
                    print("Waiting...")
                    mach_wait_until(when) // wait until fire time
                    
                    self.current_time = mach_absolute_time()
                    let actual = Float(self.absToNanos(self.current_time - self.last_fire_time))/Float(NSEC_PER_MSEC)
                    print("\(actual) ms interval")
                    let expect = self.interval * 1000
                    let err_ms = expect - actual
                    print("Error: \(err_ms) msec")
                    
                    
                    self.prepareForNextBeat()
                    // if the metronome is still on after the timer has fired
                    // we increment to the next beat
                    if (self.isOn && !self.isFirstBeat) {
                        self.incrementBeat()
                    }
                }
            }
        }
    }
    
    func animateCircleInMainThread() {
        DispatchQueue.main.async {
            self.parentViewController.containerView.animateBeatCircle(
                beatIndex: self.getBeatIndex(), beatDuration: Float(self.getInterval())
            )
        }
    }
    
    // a combination of playBeat and animateCircleInMainThread
    func signalBeatInMainThread() {
        DispatchQueue.main.async {
            self.playBeat()
            if !self.tapOverride {
                self.parentViewController.containerView.animateBeatCircle(
                    beatIndex: self.getBeatIndex(), beatDuration: Float(self.getInterval())
                )
            }
        }
    }
    
    func tempoChangeUpdateUI() {
        DispatchQueue.main.async {
            self.parentViewController.tempoSlider.value = Float(self.tempo)
            self.parentViewController.tempoTextField.text = String(self.tempo)
        }
    }
    
    func hideUIinMainThread(){
        DispatchQueue.main.async {
            self.parentViewController.hideUI()
        }
    }
    
    func showUIinMainThread(){
        DispatchQueue.main.async {
            self.parentViewController.showUI()
        }
    }
    
    func getNextBeatTime() -> UInt64{
        let now = mach_absolute_time()
        print("Using Rescheduled Click")
        if (self.nextWhen <= now) {
            return self.nextWhen
        } else {
            print("Skipping beat")
            self.playedLastBeat = false
            return self.nextNextWhen
        }
    }
    
    func prepare() {
        self.beatClick = try? AVAudioPlayer(contentsOf: metronomeSoundURL as URL)
//        self.downBeatClick = try? AVAudioPlayer(contentsOf: downBeatSoundURL)
        self.beatClick.prepareToPlay()
//        self.downBeatClick.prepareToPlay()
        self.beat = 1
        self.isPrepared = true
        self.prepareForNextBeat()
//        self.setVibrationPattern()
        
        if parentViewController != nil {
            parentViewController.containerView.initAllBeatCircles(timeSignature)
        }
    }
    
    func start() {
        if (!self.isPrepared) {
            self.prepare()
        }
        self.isOn = true
        self.isFirstBeat = true
        self.startMachTimer()
        print("\n---Started---")
    }
    
    func prepareForNextBeat() {
//        self.downBeatClick.pause()
//        self.downBeatClick.currentTime = 0
        self.beatClick.pause()
        self.beatClick.currentTime = 0
    }
    
    func playBeat() {
//        print("Play Beat \(self.beat)")
        self.playSound()
        self.playedLastBeat = true
    }
    
    func playSound() {
//        print("Playing Sound...")
//        if (self.beat == 1) {
//            self.downBeatClick.play()
//            self.playedLastBeat = true
//        }
//        else if (self.beat == 4 && self.timeSignature == 6) {
//            // play a different sound
//        }
//        else {
            self.beatClick.play()
            self.playedLastBeat = true
//        }
    }
    
    func incrementBeat() {
        self.beat += 1
        if (self.beat > self.timeSignature) {
            self.beat = 1
        }
        self.total_beats += 1
        print("Incrementing Beat to \(self.beat)")
        
        // Check how many beats have been played w/o manually tapping
//        self.beatsSinceLastReset += 1
    }

    func stop() {
        print(" ---- Stopping Metronome ---- ")
        // Mark the metronome as off.
        self.isPrepared = false
        self.isOn = false
        self.isFirstBeat = true
        self.beat = 1
        self.prepare()
        self.parentViewController.resetAllBeatCircles()
//        self.parentViewController.tapButton.setImage(UIImage(named: "Play"), for: .normal)
        self.avg_error = (Double(self.absToNanos(self.total_error))/Double(NSEC_PER_MSEC))/Double(self.total_beats)
        print("Avg. Error: \(self.avg_error) msec")
        
        //-- Debug
        self.total_beats = 0
        self.error = 0
        self.total_error = 0
        self.avg_error = 0
        //
    }
    
    func toggle() {
        if (self.isOn){
            self.stop()
        }
        else {
            self.start()
        }
    }
    
    func logTap() {
        print("\nLogging Tap")
        let tapTime = mach_absolute_time()
        self.untappedBeats = 0
//        self.showUIinMainThread() // handled in ViewController
        
        // on iPhones etc. mach_absolute_time does not return nanos, but something else
        // see https://shiftedbits.org/2008/10/01/mach_absolute_time-on-the-iphone/
        let lastDiff = Float(self.absToNanos(tapTime - lastTapTime)) / Float(NSEC_PER_SEC)
        
        print("Immediate Tempo: \(self.TempoFromTime(time: lastDiff))")
        
        if (lastDiff < TimeFromTempo(bpm: self.maxTempo)) {
            // Double tap means toggle
            self.toggle()
        }
        else if (
            // if the tap interval is in tempo range
            (lastDiff > TimeFromTempo(bpm: self.maxTempo))
            && (lastDiff < TimeFromTempo(bpm: self.minTempo))
        ) {
            self.tapOverride = true
            self.scheduleNextBeats()
//            self.animateCircleInMainThread() // handled in ViewController
            
            self.loggedDiffs.append(lastDiff)
            
            // limit array to length of 2 bars
            if (self.loggedDiffs.count > self.timeSignature * 2) {
                self.loggedDiffs.remove(at: 0)
            }
            
            // only change tempo when 2 beats have been tapped
            if (self.loggedDiffs.count >= 2) {
                var sum: Float = 0.0
                let len = Float(self.loggedDiffs.count)
                for t in self.loggedDiffs {
                    sum += Float(t)
                }
                let avgDiff = sum/len // calculate new interval
                self.setTempo(newTempo: self.TempoFromTime(time: avgDiff))
            }
        }
        else {
            // too long between taps
            self.loggedDiffs.removeAll()
            self.scheduleNextBeats()
        }
        self.lastTapTime = tapTime
    }
    
    func scheduleNextBeats() {
        self.nextWhen = mach_absolute_time() + self.nanosToAbs(UInt64(self.interval * Float(NSEC_PER_SEC)))
        self.nextNextWhen = self.nextWhen + self.nanosToAbs(UInt64(self.interval * Float(NSEC_PER_SEC)))
    }
    
    func setTempofromTime(newTime: Float){
        self.interval = newTime
        self.tempo = TempoFromTime(time: newTime)
        print("New Tempo: \(self.tempo)")
        if self.isOn {
            self.newTempoIsSet = true
            self.scheduleNextBeats()
        }
        self.tempoChangeUpdateUI()
        self.untappedBeats = 0
    }
    
    func setTempo(newTempo: Int){
        self.tempo = newTempo
        self.interval = TimeFromTempo(bpm: newTempo)
        print("New Tempo: \(self.tempo)")
        if self.isOn {
            self.newTempoIsSet = true
            self.scheduleNextBeats()
        }
        self.tempoChangeUpdateUI()
        self.untappedBeats = 0
    }

    func TimeFromTempo(bpm: Int) -> Float {
        return Float(60.0/Float(bpm))
    }

    func TempoFromTime(time: Float) -> Int {
        return Int(60.0/time)
    }
    
    func decrementTempo() {
        if (self.tempo > self.minTempo) {
            self.setTempo(newTempo: self.tempo - 1)
        }
    }
    
    func incrementTempo() {
        if (self.tempo < self.maxTempo) {
            self.setTempo(newTempo: self.tempo + 1)
        }
    }
    
//    func setVibrationPattern() {
//        self.vibrateArray.add(NSNumber(value: true)) //vibrate
//        self.vibrateArray.add(NSNumber(value: self.interval/2.0))
//        self.vibrateArray.add(NSNumber(value: false)) //stop
//        self.vibrateArray.add(NSNumber(value: self.interval/2.0))
//
//        self.vibratePattern.setObject(vibrateArray, forKey: "VibePattern" as NSCopying)
//        self.vibratePattern.setObject(NSNumber(value: 0.5), forKey: "Intensity" as NSCopying)
//    }
}
