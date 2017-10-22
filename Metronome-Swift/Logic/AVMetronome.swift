//
//  MetronomeLogic.swift
//  Metronome-Swift
//
//  Created by Adam Thompson on 2017-10-14.
//  Copyright (c) 2017 Adam Thompson. All rights reserved.
//
// https://developer.apple.com/library/content/samplecode/HelloMetronome/Listings/HelloMetronome_main_m.html
//

import Foundation
import AVFoundation

@objc protocol MetronomeDelegate: class {
    @objc optional func metronomeTicking(_ metronome: AVMetronome, bar: Int, beat: Int)
}

class AVMetronome : NSObject {
    
    // Sound playing & timing -----
    var engine: AVAudioEngine = AVAudioEngine()
    var player: AVAudioPlayerNode = AVAudioPlayerNode()    // owned by engine
    var soundBuffer = [AVAudioPCMBuffer?]()
    
    var bufferNumber: Int = 0
    var bufferSampleRate: Float64 = 0.0
    
    var syncQueue: DispatchQueue? = nil
    
    var isOn: Bool = false
    var playerStarted: Bool = false
    
    // Tempo control -----
    let minTempo: Int = 50
    let maxTempo: Int = 220
    var timeSignature: Int = 4 // default is 4:4
    var tempoBPM: Int = 0
    var tempoInterval: Double = 0
    var beatNumber: Int = 0
    var nextBeatSampleTime: AVAudioFramePosition = AVAudioFramePosition(0)
    var beatsToScheduleAhead: Int = 0     // controls responsiveness to tempo changes
    var beatsScheduled: Int = 0
    
    // Beat Logging
    var didRegisterTap: Bool = false
    var loggedDiffs = [Double]()
    var lastTapTime = mach_absolute_time()
    var untappedBeats: Int = 0
    let beatsToHideUI: Int = 16
    
    // UI -----
    weak var vc: MetronomeViewController!
    
    // DEBUG vars ------
    var timebaseInfo = mach_timebase_info_data_t()
    var last_fire_time: UInt64 = 0
    var expected_fire_time: UInt64 = 0
    var current_time: UInt64 = 0
    
    var total_beats = 0
    var error: UInt64 = 0
    var error_ms: Float = 0
    var max_error: Float = 0
    var total_error: Float = 0
    var avg_error: Float = 0
    // ------------
    
    override init() {
        super.init()
        // Use two triangle waves which are generate for the metronome bips.
        
        // Create a standard audio format deinterleaved float.
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)
        
        // How many audio frames?
        let bipFrames: UInt32 = UInt32(Globals.kBipDurationSeconds * Double(format.sampleRate))
        
        // Create the PCM buffers.
        soundBuffer.append(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bipFrames))
        soundBuffer.append(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bipFrames))
        
        // Fill in the number of valid sample frames in the buffers (required).
        soundBuffer[0]?.frameLength = bipFrames
        soundBuffer[1]?.frameLength = bipFrames
        
        // Generate the metronme bips, first buffer will be A440 and the second buffer Middle C.
        let wg1 = TriangleWaveGenerator(sampleRate: Float(format.sampleRate))                     // A 440
        let wg2 = TriangleWaveGenerator(sampleRate: Float(format.sampleRate), frequency: 261.6)   // Middle C
        wg1.render(soundBuffer[0]!)
        wg2.render(soundBuffer[1]!)
        
        // Connect player -> output, with the format of the buffers we're playing.
        let output: AVAudioOutputNode = engine.outputNode
        
        engine.attach(player)
        engine.connect(player, to: output, fromBus: 0, toBus: 0, format: format)
        
        bufferSampleRate = format.sampleRate
        
        // Create a serial dispatch queue for synchronizing callbacks.
        syncQueue = DispatchQueue(label: "Metronome")
        
        self.setTempo(120)
    }
    
    deinit {
        self.stop()
        
        engine.detach(player)
        soundBuffer[0] = nil
        soundBuffer[1] = nil
    }
    
    private func absToNanos(_ abs: UInt64) -> UInt64 {
        mach_timebase_info(&timebaseInfo)
        // https://shiftedbits.org/2008/10/01/mach_absolute_time-on-the-iphone/
        return abs * UInt64(timebaseInfo.numer)/UInt64(timebaseInfo.denom)
    }
    
    // Getters
    
    func getAbsoluteBeat() -> Int { return self.beatNumber }
    func getBeatInTimeSignature() -> Int { return (self.beatNumber + 1) % self.timeSignature}
    func getBeatIndex() -> Int { return self.beatNumber % self.timeSignature }
    func getTempo() -> Int { return self.tempoBPM }
    func getInterval() -> Double { return self.tempoInterval }
    func getTimeSignature() -> Int { return self.timeSignature }
    func getTimeGivenTempo(_ bpm: Int) -> Double { return Double(60.0/Double(bpm)) }
    func getTempoGivenTime(_ time: Double) -> Int { return Int(60.0/time) }
    
    func scheduleBeats() {
        if (!isOn) { return }
        
        while (beatsScheduled < beatsToScheduleAhead) {
            print("\nNext Beat \(self.getAbsoluteBeat()) - at \(self.tempoBPM) bpm")
            
            // Schedule the beat.
            let secondsPerBeat = self.getInterval()
            let samplesPerBeat = AVAudioFramePosition(secondsPerBeat * Double(bufferSampleRate))
            let beatSampleTime: AVAudioFramePosition = AVAudioFramePosition(nextBeatSampleTime)
            let playerBeatTime: AVAudioTime = AVAudioTime(sampleTime: AVAudioFramePosition(beatSampleTime), atRate: bufferSampleRate)
            // This time is relative to the player's start time.
            
            player.scheduleBuffer(soundBuffer[0]!, at: playerBeatTime, options: AVAudioPlayerNodeBufferOptions(rawValue: 0), completionHandler: {
                self.syncQueue!.sync() {
                    self.beatsScheduled -= 1
                    self.bufferNumber ^= 1
                    self.scheduleBeats()
                    
                    // Error logging 
                    self.current_time = mach_absolute_time()
                    let actual_ms = Float(self.absToNanos(self.current_time - self.last_fire_time)) / Float(NSEC_PER_MSEC)
                    let expect_ms = Float(secondsPerBeat * 1000)
                    self.last_fire_time = mach_absolute_time()
//                    print("actual time: \(actual_ms) msec")
//                    print("expected time \(expect_ms) msec")
                    self.error_ms = actual_ms - expect_ms
                    self.max_error = max(self.max_error, abs(self.error_ms))
                    print("Error: \(self.error_ms) msec")
                    self.total_error += abs(self.error_ms)
                    self.total_beats += 1
                }
            })
            
            beatsScheduled += 1
            untappedBeats += 1
            
            if (!playerStarted) {
                // We defer the starting of the player so that the first beat will play precisely
                // at player time 0. Having scheduled the first beat, we need the player to be running
                // in order for nodeTimeForPlayerTime to return a non-nil value.
                player.play()
                playerStarted = true
            }
            
            // Schedule the delegate callback
            let callbackBeat = self.getBeatIndex()
            let callbackInterval = self.getInterval()
            
            if (vc?.animateBeatCircle != nil && vc?.hideControls != nil) {
                let nodeBeatTime: AVAudioTime = player.nodeTime(forPlayerTime: playerBeatTime)!
                let output: AVAudioIONode = engine.outputNode

                let latencyHostTicks: UInt64 = AVAudioTime.hostTime(forSeconds: output.presentationLatency)
                let dispatchTime = DispatchTime(uptimeNanoseconds: nodeBeatTime.hostTime + latencyHostTicks)
                
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: dispatchTime) {
                    if (self.isOn) {
                        if !self.didRegisterTap && self.beatNumber > 0 {
                            self.vc!.animateBeatCircle(self, beatIndex: (callbackBeat), beatDuration: (callbackInterval))
                        }
                        if (self.untappedBeats > self.beatsToHideUI && !tempoModalisVisible){
                            self.vc!.hideControls(self)
                        }
                        self.didRegisterTap = false
                    }
                }
            }
            
            self.incrementBeat()
            if !self.didRegisterTap {
                scheduleNextBeatTime(samplesFromLastBeat: samplesPerBeat)
            }
        }
    }
    
    func scheduleNextBeatTime(samplesFromLastBeat: AVAudioFramePosition) {
        self.nextBeatSampleTime += AVAudioFramePosition(samplesFromLastBeat)
    }
    
    func scheduleNextBeatTime(samplesFromNow: AVAudioFramePosition) {
        let now = AVAudioFramePosition((player.playerTime(forNodeTime: player.lastRenderTime!)?.sampleTime)!)
//        print("Now: \(now)")
        self.nextBeatSampleTime = now + samplesFromNow
    }
    
    @discardableResult func start() -> Bool {
        // Start the engine without playing anything yet.
        do {
            try engine.start()
            
            isOn = true
            nextBeatSampleTime = 0
            beatNumber = 0
            bufferNumber = 0
            
            self.syncQueue!.sync() {
                self.last_fire_time = mach_absolute_time()
                self.scheduleBeats()
            }
            
            return true
        } catch {
            print("\(error)")
            return false
        }
    }
    
    func stop() {
        print("Stopping")
        isOn = false;
        
        player.stop()
        player.reset()
        
        engine.stop()
        
        playerStarted = false
        
        self.avg_error = self.total_error/Float(self.total_beats)
        print("Avg. Error: \(self.avg_error) msec")
        print("Max Error: \(self.max_error)")
    }
    
    func playNow() {
        player.play()
    }
    
    func logTap() {
        print("\nLogging Tap")
        let tapTime = mach_absolute_time()
        self.untappedBeats = 0
        self.didRegisterTap = true
        self.incrementBeat()
        
        let lastDiff = Double(self.absToNanos(tapTime - lastTapTime)) / Double(NSEC_PER_SEC)
        
//        print("Immediate Tempo: \(self.getTempoGivenTime(lastDiff))")
        
        // Double tap means stop
        if (lastDiff < self.getTimeGivenTempo(self.maxTempo)) {
            self.stop()
            self.loggedDiffs.removeAll()
        }
        // if the tap interval is in tempo range
        else if (
        (lastDiff > getTimeGivenTempo(self.maxTempo))
            && (lastDiff < getTimeGivenTempo(self.minTempo))
        )
        {
            self.loggedDiffs.append(lastDiff)

            // limit array to length of 2 bars
            if (self.loggedDiffs.count > self.timeSignature * 2) {
                self.loggedDiffs.remove(at: 0)
            }

            // Here we actually change the tempo
            if (self.loggedDiffs.count >= 2) {
                // find the average of all logged diffs
                var sum = 0.0
                let len = Double(self.loggedDiffs.count)
                for t in self.loggedDiffs {
                    sum += Double(t)
                }
                let avgDiff = sum/len
                self.setTempo(self.getTempoGivenTime(avgDiff))
                
                // reschedule the beat click
                let samplesPerBeat = AVAudioFramePosition(self.getInterval() * Double(bufferSampleRate))
                scheduleNextBeatTime(samplesFromNow: samplesPerBeat)
            }
        }
        
        // too long between taps
        else {
            self.loggedDiffs.removeAll()
        }
        
        self.lastTapTime = tapTime
    }
    
    func setTempo(_ tempo: Int) {
        self.tempoBPM = tempo
        
        self.tempoInterval = 60.0 / Double(tempoBPM)
        beatsToScheduleAhead = Int(Int32(Globals.kTempoChangeResponsivenessSeconds / self.tempoInterval))
        if (beatsToScheduleAhead < 1) { beatsToScheduleAhead = 1 }
        self.tempoChangeUpdateUI()
    }
    
    func decrementTempo() {
        if (self.tempoBPM > self.minTempo) {
            print("tempo--")
            self.setTempo(self.tempoBPM - 1)
        }
    }
    
    func incrementTempo() {
        if (self.tempoBPM < self.maxTempo) {
            print("tempo++")
            self.setTempo(self.tempoBPM + 1)
        }
    }
    
    func incrementBeat() {
        self.beatNumber += 1
    }
    
    func tempoChangeUpdateUI() {
        if (vc?.tempoButton) != nil {
            DispatchQueue.main.async {
                self.vc.tempoButton.setTitle(String(self.tempoBPM), for: .normal)
            }
        }
    }
    
}
