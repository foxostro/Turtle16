//
//  Oscillator.swift
//  ToneGeneratorTest
//
//  Created by Andrew Fox on 5/13/20.
//  Copyright © 2020 Andrew Fox. All rights reserved.
//

import Foundation
import AudioToolbox

private func callback(
  inRefCon:UnsafeMutableRawPointer,
  ioActionFlags:UnsafeMutablePointer<AudioUnitRenderActionFlags>,
  inTimeStamp:UnsafePointer<AudioTimeStamp>,
  inBusNumber:UInt32,
  inNumberFrames:UInt32,
  ioData:UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
    let audioBufferList = UnsafeMutableAudioBufferListPointer(ioData)!
    let audioBuffer = audioBufferList[0]
    let count = Int(audioBuffer.mDataByteSize) / MemoryLayout<Float>.size
    let start = audioBuffer.mData!.bindMemory(to: Float.self, capacity: count)
    let samples = UnsafeMutableBufferPointer<Float>(start: start, count: count)
    let opaqueContext: UnsafeMutablePointer<Oscillator> = inRefCon.assumingMemoryBound(to: Oscillator.self)
    let context: Oscillator = Unmanaged<Oscillator>.fromOpaque(opaqueContext).takeUnretainedValue()
    context.render(inNumberFrames, samples)
    return noErr;
}

final class Oscillator {
    var audioComponent: AudioComponentInstance!
    let sampleRate = 8000.0
    var theta = 0.0
    let lock = NSLock()
    var isRunning = false
    var _frequency = 0.0
    public var frequency: Double {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _frequency
        }
        set (value) {
            lock.lock()
            defer { lock.unlock() }
            _frequency = value
        }
    }
    public typealias TransferFunction = (Double) -> Double
    var _transferFunction: TransferFunction = { theta in
        return sin(theta)
    }
    public var transferFunction: TransferFunction {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _transferFunction
        }
        set (value) {
            lock.lock()
            defer { lock.unlock() }
            _transferFunction = value
        }
    }
    
    deinit {
        if audioComponent != nil {
            AudioUnitUninitialize(audioComponent)
            AudioComponentInstanceDispose(audioComponent)
        }
    }
    
    func start() {
        guard false == isRunning else { return }
        
        if nil == audioComponent {
            createAudioComponent()
        }
        
        let err = AudioOutputUnitStart(audioComponent)
        assert(err == noErr, "AudioOutputUnitStart: \(err)")
        
        isRunning = true
    }
    
    func stop() {
        guard true == isRunning else { return }
        let err = AudioOutputUnitStop(audioComponent)
        assert(err == noErr, "AudioOutputUnitStop: \(err)")
        isRunning = false
    }
    
    func render(_ inNumberFrames: UInt32, _ samples: UnsafeMutableBufferPointer<Float>) {
        lock.lock()
        defer { lock.unlock() }
        
        let theta_increment = 2.0 * .pi * _frequency / sampleRate
        
        for frame in 0..<inNumberFrames {
            samples[Int(frame)] = Float(_transferFunction(theta))
            
            theta += theta_increment
            if (theta > 2.0 * .pi) {
                theta -= 2.0 * .pi
            }
        }
    }
    
    private func createAudioComponent() {
        var defaultOutputDescription = AudioComponentDescription(componentType: kAudioUnitType_Output,
                                                                 componentSubType: kAudioUnitSubType_DefaultOutput,
                                                                 componentManufacturer: kAudioUnitManufacturer_Apple,
                                                                 componentFlags: 0,
                                                                 componentFlagsMask: 0)
        
        let defaultOutput = AudioComponentFindNext(nil, &defaultOutputDescription)
        assert(defaultOutput != nil, "Can't find default output");
        
        let err1 = AudioComponentInstanceNew(defaultOutput!, &audioComponent);
        assert(audioComponent != nil, "Error creating unit: \(err1)");
        
        // Provide a callback for rendering audio.
        let unmanaged = Unmanaged.passRetained(self)
        var input = AURenderCallbackStruct(inputProc: callback, inputProcRefCon: unmanaged.toOpaque())
        let err2 = AudioUnitSetProperty(audioComponent,
                                        kAudioUnitProperty_SetRenderCallback,
                                        kAudioUnitScope_Input,
                                        0,
                                        &input,
                                        UInt32(MemoryLayout.size(ofValue: input)))
        assert(err2 == noErr, "Error setting callback: \(err2)")
        
        var streamFormat = AudioStreamBasicDescription(mSampleRate: sampleRate,
                                                       mFormatID: kAudioFormatLinearPCM,
                                                       mFormatFlags: kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved,
                                                       mBytesPerPacket: UInt32(MemoryLayout<Float>.size),
                                                       mFramesPerPacket: 1,
                                                       mBytesPerFrame: UInt32(MemoryLayout<Float>.size),
                                                       mChannelsPerFrame: 1,
                                                       mBitsPerChannel: UInt32(MemoryLayout<Float>.size * 8),
                                                       mReserved: 0)
        let err3 = AudioUnitSetProperty(audioComponent,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &streamFormat,
                                        UInt32(MemoryLayout.size(ofValue: streamFormat)))
        assert(err3 == noErr, "Error setting stream format: \(err3)")
        
        let err4 = AudioUnitInitialize(audioComponent)
        assert(err4 == noErr, "AudioUnitInitialize: \(err4)")
    }
}
