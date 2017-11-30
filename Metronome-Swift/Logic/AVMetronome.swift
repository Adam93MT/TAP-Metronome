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
    
    
    // Flags
    var isOn: Bool = false
    var isFirstBeat: Bool = false
    var playerStarted: Bool = false
    var didRegisterTap: Bool = false
    
    // Tempo control -----
    let minTempo: Int = 50
    let maxTempo: Int = 220
    let possibleTimeSignatures = [2,3,4,6]
    
    var timeSignature: Int =  0 //Defaults.integer(forKey: "timeSignature")
    var tempoBPM: Int = 0
    var tempoInterval: Double = 0
    var beatNumber: Int = 0
    var nextBeatSampleTime: AVAudioFramePosition = AVAudioFramePosition(0)
    var beatsToScheduleAhead: Int = 0     // controls responsiveness to tempo changes
    var beatsScheduled: Int = 0
    
    // Beat Logging
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
        
//        // How many audio frames?
//        let bipFrames: UInt32 = UInt32(Globals.kBipDurationSeconds * Double(format.sampleRate))
        
        // Set beep frequencies
        let freq1 = 440.0
        let freq2 = 261.6
        let freq3 = 220.0
        // how many periods of the frequency can fit into the alloted time?
        let periods1 = Int(Globals.kBipDurationSeconds * freq1)
        let periods2 = Int(Globals.kBipDurationSeconds * freq2)
        let periods3 = Int(Globals.kBipDurationSeconds * freq3)
        
        // How many frames will that make?
        let bipFrames1 = UInt32(Double(periods1) * 1/freq1 * Double(format.sampleRate))
        let bipFrames2 = UInt32(Double(periods2) * 1/freq2 * Double(format.sampleRate))
        let bipFrames3 = UInt32(Double(periods3) * 1/freq3 * Double(format.sampleRate))

        // Create the PCM buffers.
        soundBuffer.append(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bipFrames1)) //0
        soundBuffer.append(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bipFrames2)) //1
        soundBuffer.append(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bipFrames3)) //2
        
        // Fill in the number of valid sample frames in the buffers (required).
        soundBuffer[0]?.frameLength = bipFrames1
        soundBuffer[1]?.frameLength = bipFrames2
        soundBuffer[2]?.frameLength = bipFrames3
        
        // Generate the metronme bips, first buffer will be A440 and the second buffer Middle C.
        let wg1 = TriangleWaveGenerator(sampleRate: Float(format.sampleRate))                     // A 440
        let wg2 = TriangleWaveGenerator(sampleRate: Float(format.sampleRate), frequency: 261.6)   // Middle C
        let wg3 = TriangleWaveGenerator(sampleRate: Float(format.sampleRate), frequency: 220.0)   // A3
        wg1.render(soundBuffer[0]!)
        wg2.render(soundBuffer[1]!)
        wg3.render(soundBuffer[2]!)
        
        // Connect player -> output, with the format of the buffers we're playing.
        let output: AVAudioOutputNode = engine.outputNode
        
        engine.attach(player)
        engine.connect(player, to: output, fromBus: 0, toBus: 0, format: format)
        
        bufferSampleRate = format.sampleRate
        
        // Create a serial dispatch queue for synchronizing callbacks.
        syncQueue = DispatchQueue(label: "Metronome")
        
        if (UserDefaults.standard.integer(forKey: "tempo") >= 1) {
            self.setTempo(UserDefaults.standard.integer(forKey: "tempo"))
        } else { self.setTempo(120) }
        
        if (UserDefaults.standard.integer(forKey: "timeSignature") >= 1) {
            self.setTimesignature(UserDefaults.standard.integer(forKey: "timeSignature"))
        }
        else { self.setTimesignature(4) }
    }
    
    deinit {
        self.stop()
        
        engine.detach(player)
        soundBuffer[0] = nil
        soundBuffer[1] = nil
        soundBuffer[2] = nil
    }
    
    private func absToNanos(_ abs: UInt64) -> UInt64 {
        mach_timebase_info(&timebaseInfo)
        // https://shiftedbits.org/2008/10/01/mach_absolute_time-on-the-iphone/
        return abs * UInt64(timebaseInfo.numer)/UInt64(timebaseInfo.denom)
    }
    
    // Getters
    
    func getAbsoluteBeat() -> Int { return self.beatNumber }
    func getBeatInTimeSignature() -> Int { return self.beatNumber % self.timeSignature + 1}
    func getBeatIndex() -> Int { return self.beatNumber % self.timeSignature }
    func getTempo() -> Int { return self.tempoBPM }
    func getInterval() -> Double { return self.tempoInterval }
    func getTimeSignature() -> Int { return self.timeSignature }
    func getTimeGivenTempo(_ bpm: Int) -> Double { return Double(60.0/Double(bpm)) }
    func getTempoGivenTime(_ time: Double) -> Int { return Int(60.0/time) }
    
    func scheduleBeats() {
        if (!isOn) { return }
        
        while (beatsScheduled < beatsToScheduleAhead) {
            
            // Schedule the beat.
            let secondsPerBeat = self.getInterval()
            let samplesPerBeat = AVAudioFramePosition(secondsPerBeat * Double(bufferSampleRate))
            let beatSampleTime: AVAudioFramePosition = AVAudioFramePosition(nextBeatSampleTime)
            let playerBeatTime: AVAudioTime = AVAudioTime(sampleTime: AVAudioFramePosition(beatSampleTime), atRate: bufferSampleRate)
            // This time is relative to the player's start time.
            
            player.scheduleBuffer(soundBuffer[self.bufferNumber]!, at: playerBeatTime, options: AVAudioPlayerNodeBufferOptions(rawValue: 0), completionHandler: {
                self.syncQueue!.sync() {
                    print("\nPlay beat \(self.getBeatInTimeSignature()) at time \(beatSampleTime)")
                    
                    self.beatsScheduled -= 1
                    
                    // self.incrementBeat()
                    
                    // for beat 0, play buffer[0], else play buffer[1]
                    self.bufferNumber = min(self.getBeatInTimeSignature()%self.timeSignature, 1)
                    if (self.timeSignature == 6 && self.getBeatInTimeSignature() == 3) { self.bufferNumber = 2 }
                    
                    // Error logging 
                    self.current_time = mach_absolute_time()
                    let actual_ms = Float(self.absToNanos(self.current_time - self.last_fire_time)) / Float(NSEC_PER_MSEC)
                    let expect_ms = Float(secondsPerBeat * 1000)
                    self.last_fire_time = mach_absolute_time()
                    self.error_ms = actual_ms - expect_ms
                    self.max_error = max(self.max_error, abs(self.error_ms))
                    self.total_error += abs(self.error_ms)
                    self.total_beats += 1
                    
                    // print("actual time: \(actual_ms) msec")
                    // print("expected time \(expect_ms) msec")
                     print("Timing Error: \(self.error_ms) msec")
                    
                    self.incrementBeat()
                    self.scheduleBeats()
                }
            })
            
            beatsScheduled += 1
            
            if (!playerStarted) {
                
                /*
                // We defer the starting of the player so that the first beat will play precisely
                // at player time 0. Having scheduled the first beat, we need the player to be running
                // in order for nodeTimeForPlayerTime to return a non-nil value.
                 */
                
                player.play()
                playerStarted = true
            }
            
            // Schedule the delegate callback
//            let callbackBeat = self.getBeatIndex()
            let callbackBeat = self.getAbsoluteBeat() % self.possibleTimeSignatures.max()!
            let callbackInterval = self.getInterval()
            
            // Here's where we do all the UI animating
            if (vc?.animateBeatCircle != nil && vc?.hideControls != nil) {
                let nodeBeatTime: AVAudioTime = player.nodeTime(forPlayerTime: playerBeatTime)!
//                let output: AVAudioIONode = engine.outputNode
//                let latencyHostTicks: UInt64 = AVAudioTime.hostTime(forSeconds: output.presentationLatency)
                let dispatchTime = DispatchTime(uptimeNanoseconds: nodeBeatTime.hostTime ) //+ latencyHostTicks)
                
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: dispatchTime) {
                    if (self.isOn) {
                        
                        // Animate the next beat circle if applicable
                        if (self.beatNumber > 0 && !self.didRegisterTap) {
                            self.vc!.animateBeatCircle(self, beatIndex: (callbackBeat), beatDuration: (callbackInterval))
                        } else {  }
                        
                        // Hide the controls after enough beats have passed
                        if (self.untappedBeats > self.beatsToHideUI && !tempoModalisVisible && !onSettingsPage){
                            self.vc!.hideControls(self)
                        }
                        
                        self.didRegisterTap = false
                        self.isFirstBeat = false
                    }
                }
            }
            
            // keep track of the number of beats without interaction
            if !tempoModalisVisible && !onSettingsPage {
                untappedBeats += 1
            } else {untappedBeats = 0}
            
            scheduleNextBeatTime(samplesFromLastBeat: samplesPerBeat)
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
            print("\nSTARTING")
            
            isOn = true
            isFirstBeat = true
            
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
        playerStarted = false
        didRegisterTap = false
        
        player.stop()
        player.reset()
        engine.stop()
        
        nextBeatSampleTime = 0
        beatNumber = 0
        bufferNumber = 0
        
        self.avg_error = self.total_error/Float(self.total_beats)
        print("Avg. Error: \(self.avg_error) msec")
//        print("Max Error: \(self.max_error)")
        
        let avg_animation_delay = (self.vc.containerView.total_error/Float(self.total_beats))
        print("\nAvg. Animation Delay: \(avg_animation_delay)")
    }
    
    func playNow() {
        player.play()
    }
    
    func logTap() {
        if (self.beatNumber <= 0) { return }
        
        print("\nLogging Tap")
        let tapTime = mach_absolute_time()
        self.untappedBeats = 0
        self.didRegisterTap = true
        
        let lastDiff = Double(self.absToNanos(tapTime - lastTapTime)) / Double(NSEC_PER_SEC)
        
        // Double tap means stop
        if (lastDiff < self.getTimeGivenTempo(self.maxTempo)) {
            self.stop()
            
            // Will want to broadcast this later
            vc.stopMetronome()
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
        print("Set Tempo to \(tempo)")
        self.tempoInterval = 60.0 / Double(tempoBPM)
        beatsToScheduleAhead = Int(Int32(Globals.kTempoChangeResponsivenessSeconds / self.tempoInterval))
        if (beatsToScheduleAhead < 1) { beatsToScheduleAhead = 1 }
        self.tempoChangeUpdateUI()
        UserDefaults.standard.set(tempo, forKey: "tempo")
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
//         print("beat++")
        self.beatNumber += 1
    }
    
    func tempoChangeUpdateUI() {
        if (vc?.tempoButton) != nil {
            DispatchQueue.main.async {
                self.vc.tempoButton.setTitle(String(self.tempoBPM), for: .normal)
            }
        }
    }
    
    func setTimesignature(_ newTS: Int) {
        // TODO:
        // We need to reinit the beat circles if we increase the time signature
        print("Set timeSignature to \(newTS)")
        self.timeSignature = newTS
        UserDefaults.standard.set(newTS, forKey: "timeSignature")
    }
    
}
