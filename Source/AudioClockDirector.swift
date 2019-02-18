//
//  AudioClockDirector.swift
//  SwiftAudioPlayer
//
//  Created by Tanha Kabir on 2019-01-29.
//  Copyright © 2019 Tanha Kabir, Jon Mercer
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import CoreMedia

class AudioClockDirector {
    static let shared = AudioClockDirector()
    
    private var needleClosures: DirectorThreadSafeClosures<Needle> = DirectorThreadSafeClosures()
    private var durationClosures: DirectorThreadSafeClosures<Duration> = DirectorThreadSafeClosures()
    private var playingStatusClosures: DirectorThreadSafeClosures<IsPlaying> = DirectorThreadSafeClosures()
    private var bufferClosures: DirectorThreadSafeClosures<AudioAvailabilityRange> = DirectorThreadSafeClosures()
    
    private init() {}
    
    func create() {}
    
    func clear() {
        needleClosures.clear()
        durationClosures.clear()
        playingStatusClosures.clear()
        bufferClosures.clear()
    }
    
    // MARK: - Attaches
    
    // Needle
    func attachToChangesInNeedle(closure: @escaping (Key, Needle) throws -> Void) -> UInt {
        return needleClosures.attach(closure: closure)
    }
    
    
    // Duration
    func attachToChangesInDuration(closure: @escaping (Key, Duration) throws -> Void) -> UInt {
        return durationClosures.attach(closure: closure)
    }
    
    
    // Playing status
    func attachToChangesInPlayingStatus(closure: @escaping (Key, IsPlaying) throws -> Void) -> UInt{
        return playingStatusClosures.attach(closure: closure)
    }
    
    
    // Buffer
    func attachToChangesInBufferedRange(closure: @escaping (Key, AudioAvailabilityRange) throws -> Void) -> UInt{
        return bufferClosures.attach(closure: closure)
    }
    
    
    // MARK: - Detaches
    func detachFromChangesInNeedle(withID id: UInt) {
        needleClosures.detach(id: id)
    }
    
    func detachFromChangesInDuration(withID id: UInt) {
        durationClosures.detach(id: id)
    }
    
    func detachFromChangesInPlayingStatus(withID id: UInt) {
        playingStatusClosures.detach(id: id)
    }
    
    func detachFromChangesInBufferedRange(withID id: UInt) {
        bufferClosures.detach(id: id)
    }
}

// MARK: - Receives notifications from AudioEngine on ticks
extension AudioClockDirector {
    func needleTick(_ key: Key, needle: Needle) {
        needleClosures.broadcast(key: key, payload: needle)
    }
}

extension AudioClockDirector {
    func durationWasChanged(_ key: Key, duration: Duration) {
        durationClosures.broadcast(key: key, payload: duration)
    }
}

extension AudioClockDirector {
    func audioPaused(_ key: Key) {
        playingStatusClosures.broadcast(key: key, payload: false)
    }
    
    func audioPlaying(_ key: Key) {
        playingStatusClosures.broadcast(key: key, payload: true)
    }
}

extension AudioClockDirector {
    func changeInAudioBuffered(_ key: Key, buffered: AudioAvailabilityRange) {
        bufferClosures.broadcast(key: key, payload: buffered)
    }
}