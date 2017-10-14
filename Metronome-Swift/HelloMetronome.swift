/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 It's a Metronome!
*/

import Foundation
import AVFoundation

struct GlobalConstants {
    static let kBipDurationSeconds: Double = 0.020
    static let kTempoChangeResponsivenessSeconds: Double = 0.250
}

@objc protocol MetronomeDelegate: class {
    @objc optional func metronomeTicking(_ metronome: HelloMetronome, bar: Int, beat: Int)
}

class HelloMetronome : NSObject {
    
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
    var nextBeatSampleTime: Double = 0.0
    var beatsToScheduleAhead: Int = 0     // controls responsiveness to tempo changes
    var beatsScheduled: Int = 0
    
    // Beat Logging
    var tapOverride: Bool = false
    var loggedDiffs = [Double]()
    var lastTapTime = mach_absolute_time()
    var untappedBeats: Int = 0
    let beatsToHideUI: Int = 16
    
    // UI -----
    weak var delegate: MetronomeViewController!
    
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
        let bipFrames: UInt32 = UInt32(GlobalConstants.kBipDurationSeconds * Double(format.sampleRate))
        
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
            
            let secondsPerBeat = 60.0 / Double(tempoBPM)
            let samplesPerBeat = Double(secondsPerBeat * Double(bufferSampleRate))
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
                    print("actual time: \(actual_ms) msec")
                    print("expected time \(expect_ms) msec")
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
            
            if (delegate?.animateBeatCircle != nil && delegate?.hideControls != nil) {
                let nodeBeatTime: AVAudioTime = player.nodeTime(forPlayerTime: playerBeatTime)!
                let output: AVAudioIONode = engine.outputNode

                let latencyHostTicks: UInt64 = AVAudioTime.hostTime(forSeconds: output.presentationLatency)
                let dispatchTime = DispatchTime(uptimeNanoseconds: nodeBeatTime.hostTime + latencyHostTicks)
                
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: dispatchTime) {
                    if (self.isOn) {
                        if !self.tapOverride && self.beatNumber > 0 {
                            self.delegate!.animateBeatCircle(self, beatIndex: (callbackBeat), beatDuration: (callbackInterval))
                        }
                        if self.untappedBeats > self.beatsToHideUI {
                            self.delegate!.hideControls(self)
                        }
                        self.tapOverride = false
                    }
                }
            }
            
            beatNumber += 1
            nextBeatSampleTime += Float64(samplesPerBeat)
        }
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
        
        /* Note that pausing or stopping all AVAudioPlayerNode's connected to an engine does
         NOT pause or stop the engine or the underlying hardware.
         
         The engine must be explicitly paused or stopped for the hardware to stop.
        */
        player.stop()
        player.reset()
        
        /* Stop the audio hardware and the engine and release the resources allocated by the prepare method.
         
         Note that pause will also stop the audio hardware and the flow of audio through the engine, but
         will not deallocate the resources allocated by the prepare method.
         
         It is recommended that the engine be paused or stopped (as applicable) when not in use,
         to minimize power consumption.
        */
        engine.stop()
        
        playerStarted = false
        
        self.avg_error = self.total_error/Float(self.total_beats)
        print("Avg. Error: \(self.avg_error) msec")
        print("Max Error: \(self.max_error)")
    }
    
    func logTap() {
        print("\nLogging Tap")
        let tapTime = mach_absolute_time()
        self.untappedBeats = 0
        self.tapOverride = true
        
        let lastDiff = Double(self.absToNanos(tapTime - lastTapTime)) / Double(NSEC_PER_SEC)
        
        print("Immediate Tempo: \(self.getTempoGivenTime(lastDiff))")
        
        // Double tap means stop
        if (lastDiff < self.getTimeGivenTempo(self.maxTempo)) {
            self.stop()
        }
        // if the tap interval is in tempo range
        else if (
        (lastDiff > getTimeGivenTempo(self.maxTempo))
            && (lastDiff < getTimeGivenTempo(self.minTempo))
        )
        {
//            self.scheduleNextBeats()

            self.loggedDiffs.append(lastDiff)

        // limit array to length of 2 bars
            if (self.loggedDiffs.count > self.timeSignature * 2) {
                self.loggedDiffs.remove(at: 0)
            }

        // only change tempo when 2 beats have been tapped
            if (self.loggedDiffs.count >= 2) {
                var sum = 0.0
                let len = Double(self.loggedDiffs.count)
                for t in self.loggedDiffs {
                    sum += Double(t)
                }
                let avgDiff = sum/len // calculate new interval
                self.setTempo(self.getTempoGivenTime(avgDiff))
            }
        }
        
        // too long between taps
        else {
            self.loggedDiffs.removeAll()
        }
        
        self.lastTapTime = tapTime
    }
    
    func setTempo(_ tempo: Int) {
        tempoBPM = tempo
        
        let secondsPerBeat: Double = 60.0 / Double(tempoBPM)
        beatsToScheduleAhead = Int(Int32(GlobalConstants.kTempoChangeResponsivenessSeconds / secondsPerBeat))
        if (beatsToScheduleAhead < 1) { beatsToScheduleAhead = 1 }
    }
    
    func decrementTempo() {
        if (self.tempoBPM > self.minTempo) {
            self.setTempo(self.tempoBPM - 1)
        }
    }
    
    func incrementTempo() {
        if (self.tempoBPM < self.maxTempo) {
            self.setTempo(self.tempoBPM + 1)
        }
    }
    
    func incrementBeat() {
        self.beatNumber += 1
    }
    
}
