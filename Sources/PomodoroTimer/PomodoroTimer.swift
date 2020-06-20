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

import Foundation
import SecondsTimer

// MARK: - PomodoroTimer
public class PomodoroTimer {
    
    // MARK: - Init
    public init() {
        _timer = STimer()
        _timer.delegate = self
    }
    
    // MARK: - Properties
    private var _timer: STimer
    private var _session: SessionType = .Idle
    private var _focusDuration: Int = 25*60
    private var _shortBreakDuration: Int = 5*60
    private var _longBreakDuration: Int = 15*60
    private var _streaks: Int = 0
    
    // MARK: - Delegate
    public var delegate: PomodoroTimerDelegate?
}

// MARK: - Convenience Initializers
public extension PomodoroTimer {
    
    convenience init?(focus: Int, short: Int, long: Int) {
        guard focus > 0, short > 0, long > 0 else {
            return nil
        }
        
        self.init()
        
        _focusDuration = focus
        _shortBreakDuration = short
        _longBreakDuration = long
    }
    
    convenience init?(focusMinutes: Int, shortMinutes: Int, longMinutes: Int) {
        guard focusMinutes > 0, shortMinutes > 0, longMinutes > 0 else {
            return nil
        }
        
        self.init()
        
        _focusDuration = focusMinutes*60
        _shortBreakDuration = shortMinutes*60
        _longBreakDuration = longMinutes*60
    }
}

// MARK: - STimerDelegate
extension PomodoroTimer: STimerDelegate {

    public func clock(_ clock: STimer, didTickWithSeconds seconds: Int) {
        delegate?.pomodoroTimer(self, didTickWith: seconds)
    }
    
    public func clockDidEnd(_ clock: STimer) {
        if _session == .Focus { _streaks += 1 }
        else if _session == .LongBreak { resetStreaks() }
        
        delegate?.pomodoroTimer(self, didEndSession: _session)
    }
}

// MARK: - Timer
public extension PomodoroTimer {
    var isActive: Bool {
        return _timer.isActive
    }
    
    var secondsRemaining: Int {
        if session == .Idle { return focusDuration }
        return _timer.secondsRemaining
    }
}

// MARK: - Sessions
public extension PomodoroTimer {
    
    // MARK: - Type
    enum SessionType: Int {
        case Idle, Focus, ShortBreak, LongBreak
    }
    
    // MARK: - Session
    var session: SessionType {
        return _session
    }
    
    func startSession(session: SessionType) {
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
    
    func startSession(seconds: Int, session: SessionType) {
        
        if session != .Idle {
            _timer.start(seconds)
        } else {
            _timer.stop()
        }
        
        _session = session
        delegate?.pomodoroTimer(self, didStartSession: _session)
    }
    
    // MARK: - Focus
    var focusDuration: Int {
        return _focusDuration
    }
    
    var focusMinutesDuration: Int {
        return _focusDuration/60
    }
    
    func startFocus() {
        startSession(seconds: _focusDuration, session: .Focus)
    }
    
    func startFocus(seconds: Int) {
        startSession(seconds: seconds, session: .Focus)
    }
    
    // MARK: - Break
    var shortBreakDuration: Int {
        return _shortBreakDuration
    }
    
    var shortBreakMinutesDuration: Int {
        return _shortBreakDuration/60
    }
    
    var longBreakDuration: Int {
        return _longBreakDuration
    }
    
    var longBreakMinutesDuration: Int {
        return _longBreakDuration/60
    }
    
    func startShortBreak() {
        startSession(seconds: _shortBreakDuration, session: .ShortBreak)
    }
    
    func startShortBreak(seconds: Int) {
        startSession(seconds: seconds, session: .ShortBreak)
    }
    
    func startLongBreak() {
        startSession(seconds: _longBreakDuration, session: .LongBreak)
    }
    
    func startLongBreak(seconds: Int) {
        startSession(seconds: seconds, session: .LongBreak)
    }
    
    func startBreak() {
        if getNextBreakType() == .ShortBreak {
            startShortBreak()
        } else {
            startLongBreak()
        }
    }
    
    func getNextBreakType() -> SessionType {
        return _streaks < 4 ? .ShortBreak : .LongBreak
    }
    
    // MARK: - Pause
    func pause() {
        _timer.pause()
        
        delegate?.pomodoroTimer(self, didPauseSession: _session)
    }
    
    // MARK: - Resume
    func resume() {
        _timer.resume()
        
        delegate?.pomodoroTimer(self, didResumeSession: _session)
    }
    
    // MARK: - Cancel
    func cancel() {
        _timer.stop()
        _session = .Idle
        
        delegate?.pomodoroTimerDidCancel(self)
    }
}

// MARK: - Streaks
public extension PomodoroTimer {
    
    var streaksCount: Int {
        get { _streaks }
        set { _streaks = max(newValue, 0) }
    }
    
    func resetStreaks() {
        _streaks = 0
    }
}

// MARK: - Get End Time
public extension PomodoroTimer {
    
    func getCurrentSessionEndTime() -> Date? {
        guard _session != .Idle, isActive else { return nil }
        return Date(timeIntervalSinceNow: TimeInterval(secondsRemaining))
    }
    
    func getBreakEndTime() -> Date? {
        guard _session != .Idle, isActive else { return nil }
        
        if _session == .ShortBreak || _session == .LongBreak {
            return Date(timeIntervalSinceNow: TimeInterval(secondsRemaining))
        }
        
        let nextBreakType = getNextBreakType()
        let breakDuration = nextBreakType == .ShortBreak ? shortBreakDuration : longBreakDuration
        
        return Date(timeIntervalSinceNow: TimeInterval(secondsRemaining+breakDuration))
    }
}
