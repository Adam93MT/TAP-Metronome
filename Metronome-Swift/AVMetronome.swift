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

struct GlobalConstants {
    static let kBipDurationSeconds: Float32 = 0.020
    static let kTempoChangeResponsivenessSeconds: Float32 = 0.250
}

@objc protocol MetronomeDelegate: class {
    @objc optional func metronomeTicking(_ metronome: AVMetronome, bar: Int32, beat: Int32)
}

//@available(iOS 10.0, *)
class AVMetronome: NSObject {
    var engine: AVAudioEngine = AVAudioEngine()
    var player: AVAudioPlayerNode = AVAudioPlayerNode()    // owned by engine
    var soundBuffer = [AVAudioPCMBuffer?]()
    
    var bufferNumber: Int = 0
    var bufferSampleRate: Float64 = 0.0
    
    var syncQueue: DispatchQueue? = nil

    var parentViewController: MetronomeViewController!
    weak var delegate: MetronomeDelegate?
    
    let minTempo: Int = 50
    let maxTempo: Int = 220
    let timebaseInfo = mach_timebase_info_data_t()
    
    var timeSignature: Int = 4 // default is 4:4
    var beat = 1
    var tempo: Int = 100
    var interval: Float = 0.6
    var nextBeatSampleTime: Float64 = 0.0
    var beatsToScheduleAhead: Int32 = 0     // controls responsiveness to tempo changes
    var beatsScheduled: Int32 = 0
    
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
    
    override init() {
        super.init()
        print("init AVMetronome")
        print(timebaseInfo)
        
        // Create a standard audio format deinterleaved float.
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)
        
        // How many audio frames?
        let bipFrames: UInt32 = UInt32(GlobalConstants.kBipDurationSeconds * Float(audioFormat.sampleRate))
        
        // Create the PCM buffers.
        soundBuffer.append(AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: bipFrames))
        soundBuffer.append(AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: bipFrames))
        
        // Fill in the number of valid sample frames in the buffers (required).
        soundBuffer[0]?.frameLength = bipFrames
        soundBuffer[1]?.frameLength = bipFrames
        
        // Generate the metronme bips, first buffer will be A440 and the second buffer Middle C.
        let wg1 = TriangleWaveGenerator(sampleRate: Float(audioFormat.sampleRate))                     // A 440
        let wg2 = TriangleWaveGenerator(sampleRate: Float(audioFormat.sampleRate), frequency: 261.6)   // Middle C
        wg1.render(soundBuffer[0]!)
        wg2.render(soundBuffer[1]!)
        
        // Connect player -> output, with the format of the buffers we're playing.
        let output: AVAudioOutputNode = engine.outputNode
        
        engine.attach(player)
        engine.connect(player, to: output, fromBus: 0, toBus: 0, format: audioFormat)
        
        bufferSampleRate = audioFormat.sampleRate
        
        // Create a serial dispatch queue for synchronizing callbacks.
        syncQueue = DispatchQueue(label: "Metronome")

        
        self.setTempo(newTempo: 120)
    }
    deinit {
        self.stop()
        
        engine.detach(player)
        soundBuffer[0] = nil
        soundBuffer[1] = nil
    }
    
    // Getter functions
    
    func getBeat() -> Int { return self.beat }
    
    func getBeatIndex() -> Int { return self.beat - 1 }
    
    func getTempo() -> Int { return self.tempo }
    
    func getInterval() -> Float { return self.interval }
    
    func getTimeSignature() -> Int { return self.timeSignature }
    
    private func absToNanos(_ abs: UInt64) -> UInt64 {
        return abs * UInt64(timebaseInfo.numer)/UInt64(timebaseInfo.denom)
    }
    private func nanosToAbs(_ nanos: UInt64) -> UInt64 {
        return nanos * UInt64(timebaseInfo.denom) / UInt64(timebaseInfo.numer)
    }
    
    @discardableResult func start() -> Bool {
        print("\n---Started---")
        do {
            try engine.start()
            
            self.isOn = true
            self.isFirstBeat = true
            self.nextBeatSampleTime = 0
            self.beat = 0
            bufferNumber = 0
            
            self.syncQueue!.sync() {
                self.scheduleBeats()
            }
            
            return true
        } catch {
            print("\(error)")
            return false
        }
    }

    
    func scheduleBeats() {
        if (!self.isOn) { return }
        
        while (beatsScheduled < beatsToScheduleAhead) {
            // Schedule the beat.
            self.interval = TimeFromTempo(bpm: self.tempo)
            let samplesPerBeat = Float(self.interval * Float(bufferSampleRate))
            let beatSampleTime: AVAudioFramePosition = AVAudioFramePosition(nextBeatSampleTime)
            let playerBeatTime: AVAudioTime = AVAudioTime(sampleTime: AVAudioFramePosition(beatSampleTime), atRate: bufferSampleRate)
            // This time is relative to the player's start time.
            
            player.scheduleBuffer(soundBuffer[bufferNumber]!, at: playerBeatTime, options: AVAudioPlayerNodeBufferOptions(rawValue: 0), completionHandler: {
                self.syncQueue!.sync() {
                    self.beatsScheduled -= 1
                    self.bufferNumber ^= 1
                    self.scheduleBeats()
                }
            })
            
            beatsScheduled += 1
            
            if (!self.isOn) {
                // We defer the starting of the player so that the first beat will play precisely
                // at player time 0. Having scheduled the first beat, we need the player to be running
                // in order for nodeTimeForPlayerTime to return a non-nil value.
                player.play()
                self.isOn = true
            }
            
            // Schedule the delegate callback (metronomeTicking:bar:beat:) if necessary.
            let callbackBeat = self.beat
            self.beat += 1
            if delegate?.metronomeTicking != nil {
                let nodeBeatTime: AVAudioTime = player.nodeTime(forPlayerTime: playerBeatTime)!
                let output: AVAudioIONode = engine.outputNode
                
                //                print(" \(playerBeatTime), \(nodeBeatTime), \(output.presentationLatency)")
                let latencyHostTicks: UInt64 = AVAudioTime.hostTime(forSeconds: output.presentationLatency)
                let dispatchTime = DispatchTime(uptimeNanoseconds: nodeBeatTime.hostTime + latencyHostTicks)
                
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: dispatchTime) {
                    if (self.isOn) {
                        self.delegate!.metronomeTicking!(self, bar: Int32((callbackBeat / 4) + 1), beat: Int32((callbackBeat % 4) + 1))
                    }
                }
            }
            
            self.nextBeatSampleTime += Float64(samplesPerBeat)
        }
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
        self.parentViewController.resetAllBeatCircles()
//        self.parentViewController.tapButton.setImage(UIImage(named: "Play"), for: .normal)
        
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
//            self.scheduleNextBeats()
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
        }
        self.lastTapTime = tapTime
    }
    
    func setTempofromTime(newTime: Float){
        self.interval = newTime
        self.tempo = TempoFromTime(time: newTime)
        print("New Tempo: \(self.tempo)")
        self.tempoChangeUpdateUI()
        self.untappedBeats = 0
    }
    
    func setTempo(newTempo: Int){
        self.tempo = newTempo
        self.interval = TimeFromTempo(bpm: newTempo)
        print("New Tempo: \(self.tempo)")
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
    
    // UI Stuff
    
    // a combination of playBeat and animateCircleInMainThread
    func signalBeatInMainThread() {
        DispatchQueue.main.async {
            if !self.tapOverride {
                self.parentViewController.containerView.animateBeatCircle(
                    beatIndex: self.getBeatIndex(), beatDuration: self.getInterval()
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
}
