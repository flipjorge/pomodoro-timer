//  MIT License
//
//  Copyright (c) 2020 Filipe Jorge
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import SecondsTimer

public class PomodoroTimer {
    
    // MARK: - Initializers
    public init() {
        _timer = STimer()
        _timer.delegate = self
    }
    
    public convenience init?(focus: Int, short: Int, long: Int) {
        guard focus > 0, short > 0, long > 0 else {
            return nil
        }
        
        self.init()
        
        _focusDuration = focus
        _shortBreakDuration = short
        _longBreakDuration = long
    }
    
    public convenience init?(focusMinutes: Int, shortMinutes: Int, longMinutes: Int) {
        guard focusMinutes > 0, shortMinutes > 0, longMinutes > 0 else {
            return nil
        }
        
        self.init()
        
        _focusDuration = focusMinutes*60
        _shortBreakDuration = shortMinutes*60
        _longBreakDuration = longMinutes*60
    }
    
    // MARK: - Delegate
    public var delegate: PomodoroTimerDelegate?
    
    // MARK: - Properties
    private var _focusDuration: Int = 25*60
    
    public var focusDuration: Int {
        return _focusDuration
    }
    
    public var focusMinutesDuration: Int {
        return _focusDuration/60
    }
    
    public var _shortBreakDuration: Int = 5*60
    
    public var shortBreakDuration: Int {
        return _shortBreakDuration
    }
    
    public var shortBreakMinutesDuration: Int {
        return _shortBreakDuration/60
    }
    
    private var _longBreakDuration: Int = 15*60
    
    public var longBreakDuration: Int {
        return _longBreakDuration
    }
    
    public var longBreakMinutesDuration: Int {
        return _longBreakDuration/60
    }
    
    // MARK: - Timer
    private var _timer: STimer
    
    public var isActive: Bool {
        return _timer.isActive
    }
    
    public var secondsRemaining: Int {
        if session == .Idle { return focusDuration }
        return _timer.secondsRemaining
    }
    
    // MARK: - Session
    public enum SessionType: Int {
        case Idle, Focus, ShortBreak, LongBreak
    }
    
    private var _session: SessionType = .Idle
    
    public var session: SessionType {
        return _session
    }
    
    // MARK: - Start Session
    public func startSession(session: SessionType) {
        let seconds: Int
        
        switch session {
        case .Focus:
            seconds = _focusDuration
        case .ShortBreak:
            seconds = _shortBreakDuration
        case .LongBreak:
            seconds = _longBreakDuration
        default:
            seconds = 0
        }
        
        startSession(seconds:seconds, session:session)
    }
    
    public func startSession(seconds: Int, session: SessionType) {
        
        if session != .Idle {
            _timer.start(seconds)
        } else {
            _timer.stop()
        }
        
        _session = session
        delegate?.pomodoroTimer(self, didStartSession: _session)
    }
    
    // MARK: - Start Focus
    public func startFocus() {
        startSession(seconds: _focusDuration, session: .Focus)
    }
    
    public func startFocus(seconds: Int) {
        startSession(seconds: seconds, session: .Focus)
    }
    
    // MARK: - Start Break
    public func startShortBreak() {
        startSession(seconds: _shortBreakDuration, session: .ShortBreak)
    }
    
    public func startShortBreak(seconds: Int) {
        startSession(seconds: seconds, session: .ShortBreak)
    }
    
    public func startLongBreak() {
        startSession(seconds: _longBreakDuration, session: .LongBreak)
    }
    
    public func startLongBreak(seconds: Int) {
        startSession(seconds: seconds, session: .LongBreak)
    }
    
    // MARK: - Pause
    public func pause() {
        _timer.pause()
        
        delegate?.pomodoroTimer(self, didPauseSession: _session)
    }
    
    // MARK: - Resume
    public func resume() {
        _timer.resume()
        
        delegate?.pomodoroTimer(self, didResumeSession: _session)
    }
    
    // MARK: - Cancel
    public func cancel() {
        _timer.stop()
        _session = .Idle
        
        delegate?.pomodoroTimerDidCancel(self)
    }
}

// MARK: - STimerDelegate
extension PomodoroTimer: STimerDelegate {

    public func clock(_ clock: STimer, didTickWithSeconds seconds: Int) {
        delegate?.pomodoroTimer(self, didTickWith: seconds)
    }
    
    public func clockDidEnd(_ clock: STimer) {
        delegate?.pomodoroTimer(self, didEndSession: _session)
    }
}
