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
    public init(settings: Settings = .init()) {
        _timer = STimer()
        _settings = settings
        _timer.delegate = self
    }
    
    // MARK: - Properties
    private var _timer: STimer
    private var _session: SessionType = .Idle
    private var _streaks: Int = 0
    private var _settings: Settings
    
    // MARK: - Delegate
    public var delegate: PomodoroTimerDelegate?
}

// MARK: - Convenience Initializers
public extension PomodoroTimer {
    
    convenience init?(focus: Double, short: Double, long: Double, streaks: Int) {
        let settings = Settings(focusDuration: focus, shortBreakDuration: short, longBreakDuration: long, streaksToLongBreak: streaks)
        
        guard let validSettings = settings else { return nil }
        
        self.init()
        _settings = validSettings
    }
    
    convenience init?(focusMinutes: Double, shortMinutes: Double, longMinutes: Double, streaks: Int) {
        self.init(focus:focusMinutes*60, short:shortMinutes*60, long:longMinutes*60, streaks:streaks)
    }
}

// MARK: - STimerDelegate
extension PomodoroTimer: STimerDelegate {

    public func clock(_ clock: STimer, didTickWithSeconds seconds: Double) {
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
    
    var secondsRemaining: Double {
        if session == .Idle { return _settings.focusDuration }
        return _timer.secondsRemaining
    }
}

// MARK: - Settings
public extension PomodoroTimer {
    
    var settings: Settings {
        get { _settings }
        set {
            _settings = newValue
            delegate?.pomodoroTimer(self, didChangedSettings: _settings)
        }
    }
}

// MARK: - Sessions
public extension PomodoroTimer {
    
    // MARK: - Type
    enum SessionType: Int, Codable {
        case Idle, Focus, ShortBreak, LongBreak
    }
    
    // MARK: - Session
    var session: SessionType {
        return _session
    }
    
    func startSession(session: SessionType) {
        let seconds: Double
        
        switch session {
        case .Focus:
            seconds = _settings.focusDuration
        case .ShortBreak:
            seconds = _settings.shortBreakDuration
        case .LongBreak:
            seconds = _settings.longBreakDuration
        default:
            seconds = 0
        }
        
        startSession(seconds:seconds, session:session)
    }
    
    func startSession(seconds: Double, session: SessionType) {
        
        if session != .Idle {
            _timer.start(seconds)
        } else {
            _timer.stop()
        }
        
        _session = session
        delegate?.pomodoroTimer(self, didStartSession: _session)
    }
    
    // MARK: - Focus
    func startFocus() {
        startSession(seconds: _settings.focusDuration, session: .Focus)
    }
    
    func startFocus(seconds: Double) {
        startSession(seconds: seconds, session: .Focus)
    }
    
    // MARK: - Break
    func startShortBreak() {
        startSession(seconds: _settings.shortBreakDuration, session: .ShortBreak)
    }
    
    func startShortBreak(seconds: Double) {
        startSession(seconds: seconds, session: .ShortBreak)
    }
    
    func startLongBreak() {
        startSession(seconds: _settings.longBreakDuration, session: .LongBreak)
    }
    
    func startLongBreak(seconds: Double) {
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
        return _streaks < _settings.streaksToLongBreak ? .ShortBreak : .LongBreak
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
    
    func resumeSession(seconds: Double, session: SessionType) {
        if session != .Idle { _timer.start(seconds) }
        _session = session
        
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
        let breakDuration = nextBreakType == .ShortBreak ? _settings.shortBreakDuration : _settings.longBreakDuration
        
        return Date(timeIntervalSinceNow: TimeInterval(secondsRemaining+breakDuration))
    }
}

// MARK: - State
public extension PomodoroTimer {
    
    func getCurrentState() -> State {
        
        if let endTime = getCurrentSessionEndTime() {
            return State(activeWithType: _session, streak: streaksCount, endTime: endTime)
        }
        
        return State(inactiveWithType: _session, streak: streaksCount, secondsRemaining: secondsRemaining)
    }
    
    func setState(_ state: State) {
        
        let duration: Double
        
        switch state.type {
        case .ShortBreak:
            duration = _settings.shortBreakDuration
        case .LongBreak:
            duration = _settings.longBreakDuration
        default:
            duration = _settings.focusDuration
        }
        
        let secondsRemaining = state.endTime?.timeIntervalSinceNow.rounded() ?? state.secondsRemaining ?? duration
        
        if secondsRemaining == duration {
            startSession(seconds: secondsRemaining, session: state.type)
        } else {
            resumeSession(seconds: secondsRemaining, session: state.type)
        }
        
        if !state.active { _timer.pause() }
    }
}
