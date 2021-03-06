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

import XCTest
import PomodoroTimer

final class PomodoroTimerTests: XCTestCase {
    
    // MARK: - Properties
    private let _secondsPerMinute = 60.0
    private let _defaultFocusMinutes = 25.0
    private let _defaultShortBreakMinutes = 5.0
    private let _defaultLongBreakMinutes = 15.0
    private let _defaultStreaks = 4
    
    // MARK: - Setup
    var timer: PomodoroTimer!
    
    override func setUp() {
        super.setUp()
        timer = PomodoroTimer()
    }
    
    override func tearDown() {
        super.tearDown()
        timer?.delegate = nil
        timer?.cancel()
        timer = nil
    }
    
    // MARK: - Init
    func test_init_givenNoArgs_setDefaultProperties() {
        XCTAssertEqual(timer.settings.focusDuration, _defaultFocusMinutes*_secondsPerMinute)
        XCTAssertEqual(timer.settings.shortBreakDuration, _defaultShortBreakMinutes*_secondsPerMinute)
        XCTAssertEqual(timer.settings.longBreakDuration, _defaultLongBreakMinutes*_secondsPerMinute)
        
        XCTAssertEqual(timer.settings.focusMinutesDuration, _defaultFocusMinutes)
        XCTAssertEqual(timer.settings.shortBreakMinutesDuration, _defaultShortBreakMinutes)
        XCTAssertEqual(timer.settings.longBreakMinutesDuration, _defaultLongBreakMinutes)
        
        XCTAssertEqual(timer.settings.streaksToLongBreak, _defaultStreaks)
        XCTAssertEqual(timer.session, PomodoroTimer.SessionType.Idle)
        XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
        XCTAssertTrue(timer.settings.autoBreak)
    }
    
    func test_initWithSettings_initsWithSettingsValues() {
        let settings = PomodoroTimer.Settings()
        timer = PomodoroTimer(settings: settings)
        
        XCTAssertEqual(timer.settings, settings)
    }
    
    func test_init_givenValidArgsInSeconds_initializesWithCorrectValues() {
        timer = PomodoroTimer(focus: _defaultFocusMinutes*_secondsPerMinute, short: _defaultShortBreakMinutes*_secondsPerMinute, long: _defaultLongBreakMinutes*_secondsPerMinute, streaks: _defaultStreaks, autoBreak: false)
        
        XCTAssertEqual(timer.settings.focusDuration, _defaultFocusMinutes*_secondsPerMinute)
        XCTAssertEqual(timer.settings.shortBreakDuration, _defaultShortBreakMinutes*_secondsPerMinute)
        XCTAssertEqual(timer.settings.longBreakDuration, _defaultLongBreakMinutes*_secondsPerMinute)
        
        XCTAssertEqual(timer.settings.focusMinutesDuration, _defaultFocusMinutes)
        XCTAssertEqual(timer.settings.shortBreakMinutesDuration, _defaultShortBreakMinutes)
        XCTAssertEqual(timer.settings.longBreakMinutesDuration, _defaultLongBreakMinutes)
        
        XCTAssertEqual(timer.settings.streaksToLongBreak, _defaultStreaks)
        XCTAssertEqual(timer.session, PomodoroTimer.SessionType.Idle)
        XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
        XCTAssertFalse(timer.settings.autoBreak)
    }
    
    func test_init_given90Seconds_minutePropertiesReturnOneAndHalf() {
        timer = PomodoroTimer(focus: 90, short: 90, long: 90, streaks: 6, autoBreak: true)
        
        XCTAssertEqual(timer.settings.focusDuration, 90)
        XCTAssertEqual(timer.settings.shortBreakDuration, 90)
        XCTAssertEqual(timer.settings.longBreakDuration, 90)
        
        XCTAssertEqual(timer.settings.focusMinutesDuration, 1.5)
        XCTAssertEqual(timer.settings.shortBreakMinutesDuration, 1.5)
        XCTAssertEqual(timer.settings.longBreakMinutesDuration, 1.5)
        
        XCTAssertEqual(timer.settings.streaksToLongBreak, 6)
    }
    
    func test_init_givenValidArgsInMinutes_initializesWithCorrectValues() {
        timer = PomodoroTimer(focusMinutes: 40, shortMinutes: 10, longMinutes: 25, streaks: 7, autoBreak: true)
        
        XCTAssertEqual(timer.settings.focusDuration, 40*_secondsPerMinute)
        XCTAssertEqual(timer.settings.shortBreakDuration, 10*_secondsPerMinute)
        XCTAssertEqual(timer.settings.longBreakDuration, 25*_secondsPerMinute)
        
        XCTAssertEqual(timer.settings.focusMinutesDuration, 40)
        XCTAssertEqual(timer.settings.shortBreakMinutesDuration, 10)
        XCTAssertEqual(timer.settings.longBreakMinutesDuration, 25)
        
        XCTAssertEqual(timer.settings.streaksToLongBreak, 7)
        XCTAssertEqual(timer.session, PomodoroTimer.SessionType.Idle)
        XCTAssertEqual(timer.secondsRemaining, 40*_secondsPerMinute)
    }
    
    func test_init_givenInvalidArgs_failsInit() {
        timer = PomodoroTimer(focus: -10, short: _defaultShortBreakMinutes, long: _defaultLongBreakMinutes, streaks: _defaultStreaks, autoBreak: true)
        
        XCTAssertNil(timer)
    }
    
    func test_init_givenInvalidArgsInMinutes_failsInit() {
        timer = PomodoroTimer(focusMinutes: -10, shortMinutes: _defaultShortBreakMinutes, longMinutes: _defaultShortBreakMinutes, streaks: _defaultStreaks, autoBreak: true)
        
        XCTAssertNil(timer)
    }
    
    // MARK: - Settings
    func test_setSettingsDefaultValues_updateSettingsWithDefaultValues() {
        timer.settings = PomodoroTimer.Settings()
        
        XCTAssertEqual(timer.settings.focusDuration, 25*60)
        XCTAssertEqual(timer.settings.shortBreakDuration, 5*60)
        XCTAssertEqual(timer.settings.longBreakDuration, 15*60)
        XCTAssertEqual(timer.settings.streaksToLongBreak, 4)
        XCTAssertTrue(timer.settings.autoBreak)
    }
    
    func test_setSettingsCustomValues_updateSettingsWithCustomValues() {
        timer.settings = PomodoroTimer.Settings(focusDuration: 43, shortBreakDuration: 12, longBreakDuration: 23, streaksToLongBreak: 6, autoBreak: false) ?? PomodoroTimer.Settings()
        
        XCTAssertEqual(timer.settings.focusDuration, 43)
        XCTAssertEqual(timer.settings.shortBreakDuration, 12)
        XCTAssertEqual(timer.settings.longBreakDuration, 23)
        XCTAssertEqual(timer.settings.streaksToLongBreak, 6)
        XCTAssertFalse(timer.settings.autoBreak)
    }
    
    // MARK: - Start Session
    func test_startSession_givenIdleSession_keepsInactive() {
        timer.startSession(session: .Idle)
        XCTAssertFalse(timer.isActive)
        XCTAssertEqual(timer.session, .Idle)
    }
    
    func test_startSession_givenIdleSession_setSecondsToFocusDuration() {
        timer.startSession(session: .Idle)
        XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
    }
    
    func test_startSession_givenIdleSessionAfterStartedFocusSession_cancel() {
        timer.startFocus()
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .Focus)
        
        timer.startSession(session: .Idle)
        XCTAssertFalse(timer.isActive)
        XCTAssertEqual(timer.session, .Idle)
    }
    
    func test_startSession_givenIdleSessionWithSeconds_ignoresSecondsAndUsesFocusDuration() {
        timer.startSession(seconds: 6, session: .Idle)
        XCTAssertFalse(timer.isActive)
        XCTAssertEqual(timer.session, .Idle)
        XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
    }
    
    func test_startSession_givenSession_startCountingWithGivenSession() {
        timer.startSession(session: .Focus)
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .Focus)
        XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
        
        timer.startSession(session: .ShortBreak)
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .ShortBreak)
        XCTAssertEqual(timer.secondsRemaining, _defaultShortBreakMinutes*_secondsPerMinute)
        
        timer.startSession(session: .LongBreak)
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .LongBreak)
        XCTAssertEqual(timer.secondsRemaining, _defaultLongBreakMinutes*_secondsPerMinute)
    }
    
    func test_startSession_givenSessionAndSeconds_startCountingWithGivenSessionAndSeconds() {
        timer.startSession(seconds: 93, session: .Focus)
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .Focus)
        XCTAssertEqual(timer.secondsRemaining, 93)
        
        timer.startSession(seconds: 61, session: .ShortBreak)
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .ShortBreak)
        XCTAssertEqual(timer.secondsRemaining, 61)
        
        timer.startSession(seconds: 99, session: .LongBreak)
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .LongBreak)
        XCTAssertEqual(timer.secondsRemaining, 99)
    }
    
    // MARK: - Start Focus
    func test_startFocus_startsAndKeepsCounting() {
        timer.startFocus()
        
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .Focus)
        XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
        
        let exp = expectation(description:"Time counts")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertTrue(timer.isActive)
            XCTAssertEqual(timer.session, .Focus)
            XCTAssertLessThan(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
            XCTAssertGreaterThan(timer.secondsRemaining, 0)
        }
    }
    
    func test_startFocus_givenSeconds_startsAndKeepsCounting() {
        timer.startFocus(seconds:93)
        
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .Focus)
        XCTAssertEqual(timer.secondsRemaining, 93)
        
        let exp = expectation(description: "Timer counts")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertTrue(timer.isActive)
            XCTAssertEqual(timer.session, .Focus)
            XCTAssertLessThan(timer.secondsRemaining, 93)
            XCTAssertGreaterThan(timer.secondsRemaining, 0)
        }
    }
    
    // MARK: - Break
    func test_startShortBreak_startsAndKeepsCounting() {
        timer.startShortBreak()
        
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .ShortBreak)
        XCTAssertEqual(timer.secondsRemaining, _defaultShortBreakMinutes*_secondsPerMinute)
        
        let exp = expectation(description:"Time counts")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertTrue(timer.isActive)
            XCTAssertEqual(timer.session, .ShortBreak)
            XCTAssertLessThan(timer.secondsRemaining, _defaultShortBreakMinutes*_secondsPerMinute)
            XCTAssertGreaterThan(timer.secondsRemaining, _defaultShortBreakMinutes*_secondsPerMinute - 5)
        }
    }
    
    func test_startShortBreak_givenSeconds_startsAndKeepsCounting() {
        timer.startShortBreak(seconds: 46)
        
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.secondsRemaining, 46)
        XCTAssertEqual(timer.session, .ShortBreak)
        
        let exp = expectation(description:"Time counts")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertTrue(timer.isActive)
            XCTAssertEqual(timer.session, .ShortBreak)
            XCTAssertLessThan(timer.secondsRemaining, 46)
            XCTAssertGreaterThan(timer.secondsRemaining, 0)
        }
    }
    
    func test_startLongBreak_startsAndKeepsCounting() {
        timer.startLongBreak()
        
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .LongBreak)
        XCTAssertEqual(timer.secondsRemaining, _defaultLongBreakMinutes*_secondsPerMinute)
        
        let exp = expectation(description:"Time counts")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertTrue(timer.isActive)
            XCTAssertLessThan(timer.secondsRemaining, _defaultLongBreakMinutes*_secondsPerMinute)
            XCTAssertGreaterThan(timer.secondsRemaining, _defaultLongBreakMinutes*_secondsPerMinute - 5)
        }
    }
    
    func test_startLongBreak_givenSeconds_startsAndKeepsCounting() {
        timer.startLongBreak(seconds: 149)
        
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.secondsRemaining, 149)
        XCTAssertEqual(timer.session, .LongBreak)
        
        let exp = expectation(description:"Time counts")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertTrue(timer.isActive)
            XCTAssertEqual(timer.session, .LongBreak)
            XCTAssertLessThan(timer.secondsRemaining, 149)
            XCTAssertGreaterThan(timer.secondsRemaining, 0)
        }
    }
    
    func test_startShortBreakWhileFocusSessionIsRunning_startsCountingBreak() {
        timer.startFocus()
        timer.startShortBreak()
        
        let exp = expectation(description:"Time counts")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertTrue(timer.isActive)
            XCTAssertLessThan(timer.secondsRemaining, _defaultShortBreakMinutes*_secondsPerMinute)
            XCTAssertGreaterThan(timer.secondsRemaining, _defaultShortBreakMinutes*_secondsPerMinute - 5)
        }
    }
    
    func test_getNextBreakOnIdle_returnsShortBreak() {
        let sessionType = timer.getNextBreakType()
        
        XCTAssertEqual(sessionType, .ShortBreak)
    }
    
    func test_getNextBreakOnFocusAndThreeStreaks_returnsShortBreak() {
        timer.streaksCount = timer.settings.streaksToLongBreak - 1
        timer.startFocus()
        let sessionType = timer.getNextBreakType()
        
        XCTAssertEqual(sessionType, .ShortBreak)
    }
    
    func test_getNextBreakOnFocusAndFourStreaks_returnsLongBreak() {
        timer.streaksCount = timer.settings.streaksToLongBreak
        timer.startFocus()
        let sessionType = timer.getNextBreakType()
        
        XCTAssertEqual(sessionType, .LongBreak)
    }
    
    func test_startBreak_whenStreaksCountIsZero_startsShortBreak() {
        timer.startBreak()
        
        XCTAssertEqual(timer.session, .ShortBreak)
    }
    
    func test_startBreak_whenStreaksIsThree_startsShortBreak() {
        timer.streaksCount = timer.settings.streaksToLongBreak - 1
        timer.startBreak()
        
        XCTAssertEqual(timer.session, .ShortBreak)
    }
    
    func test_startBreak_whenStreaksIsFour_startsLongBreak() {
        timer.streaksCount = 4
        timer.startBreak()
        
        XCTAssertEqual(timer.session, .LongBreak)
    }
    
    // MARK: - Is Idle
    func test_whileIdle_isIdleReturnsFalse() {
        XCTAssertFalse(timer.session.isBreak())
    }
    
    func test_startFocusSession_isIdleReturnsFalse() {
        timer.startFocus()
        XCTAssertFalse(timer.session.isBreak())
    }
    
    func test_startShortSession_isIdleReturnsTrue() {
        timer.startShortBreak()
        XCTAssertTrue(timer.session.isBreak())
    }
    
    func test_startLongSession_isIdleReturnsTrue() {
        timer.startLongBreak()
        XCTAssertTrue(timer.session.isBreak())
    }
    
    // MARK: - Pause
    func test_pause_stopsCounting() {
        timer.startFocus()
        timer.pause()
        
        let exp = expectation(description:"Time counts")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertFalse(timer.isActive)
            XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
        }
    }
    
    // MARK: - Resume
    func test_resumeAfterPause_resumesCounting() {
        timer.startFocus()
        timer.pause()
        timer.resume()
        
        let exp = expectation(description:"Time counts")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertTrue(timer.isActive)
            XCTAssertLessThan(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
            XCTAssertGreaterThan(timer.secondsRemaining, 0)
        }
    }
    
    func test_resumeOnIdle_staysIdle() {
        timer.resume()
        
        XCTAssertFalse(timer.isActive)
    }
    
    func test_resumeWithIdleSession_doesNothing() {
        timer.resumeSession(seconds: 45, session: .Idle)
        
        XCTAssertFalse(timer.isActive)
    }
    
    func test_resumeWithFocusSession_resumesFocusSession() {
        timer.resumeSession(seconds: 76, session: .Focus)
        
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .Focus)
        XCTAssertEqual(timer.secondsRemaining, 76)
    }
    
    func test_resumeBreakSessionWhileRunningFocusSessions_resumesBreakSession() {
        timer.startFocus()
        timer.resumeSession(seconds: 67, session: .ShortBreak)
        
        XCTAssertTrue(timer.isActive)
        XCTAssertEqual(timer.session, .ShortBreak)
        XCTAssertEqual(timer.secondsRemaining, 67)
    }
    
    // MARK: - Finish
    func test_finishFocus_shouldIncreaseStreaksAndGoBreak() {
        timer.streaksCount = 2
        timer.startFocus()
        timer.finish()
        
        XCTAssertEqual(timer.streaksCount, 3)
        XCTAssertTrue(timer.session.isBreak())
    }
    
    func test_finishShortBreak_shouldGoIdleAndKeepStreaks() {
        timer.streaksCount = 2
        timer.startShortBreak()
        timer.finish()
        
        XCTAssertEqual(timer.streaksCount, 2)
        XCTAssertEqual(timer.session, .Idle)
    }
    
    func test_finishLongBreak_shouldGoIdleAndResetStreaks() {
        timer.streaksCount = 4
        timer.startLongBreak()
        timer.finish()
        
        XCTAssertEqual(timer.streaksCount, 0)
        XCTAssertEqual(timer.session, .Idle)
    }
    
    func test_finish_notifies() {
        timer.startFocus()
        
        let exp = expectation(description: "notifies")
        let delegate = PomodoroTimerMockDelegate()
        delegate.didEndSession = { timer, session in
            XCTAssertEqual(session, .Focus)
            exp.fulfill()
        }
        
        timer.delegate = delegate
        timer.finish()
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Cancel
    func test_cancel_stopsRunningAndResetsTime() {
        timer.startFocus()
        timer.cancel()
        
        XCTAssertFalse(timer.isActive)
        XCTAssertEqual(timer.session, .Idle)
        XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
        
        let exp = expectation(description:"Time counts")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertFalse(timer.isActive)
            XCTAssertEqual(timer.session, .Idle)
            XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
        }
    }
    
    // MARK: - Delegate
    func test_startFocusSession_notifiesStartFocusSession() {
        
        let exp = expectation(description: "Notifies")
        
        let delegate = PomodoroTimerMockDelegate()
        delegate.didStartSession = { timer, session in
            XCTAssertTrue(timer.isActive)
            XCTAssertEqual(session, .Focus)
            exp.fulfill()
        }
        timer.delegate = delegate
        timer.startFocus()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_startShortSession_notifiesStartShortSession() {
        
        let exp = expectation(description: "Notifies")
        
        let delegate = PomodoroTimerMockDelegate()
        delegate.didStartSession = { timer, session in
            XCTAssertTrue(timer.isActive)
            XCTAssertEqual(session, .ShortBreak)
            exp.fulfill()
        }
        timer.delegate = delegate
        timer.startShortBreak()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_startLongSession_notifiesStartLongSession() {
        
        let exp = expectation(description: "Notifies")
        
        let delegate = PomodoroTimerMockDelegate()
        delegate.didStartSession = { timer, session in
            XCTAssertTrue(timer.isActive)
            XCTAssertEqual(session, .LongBreak)
            exp.fulfill()
        }
        timer.delegate = delegate
        timer.startLongBreak()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_pauses_notifiesPause() {
        
        let exp = expectation(description: "Notifies")
        
        let delegate = PomodoroTimerMockDelegate()
        delegate.didPauseSession = { timer, session in
            XCTAssertFalse(timer.isActive)
            exp.fulfill()
        }
        timer.delegate = delegate
        timer.startFocus()
        timer.pause()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_resume_notifiesResume() {
        
        let exp = expectation(description: "Notifies")
        
        let delegate = PomodoroTimerMockDelegate()
        delegate.didResumeSession = { timer, session in
            XCTAssertTrue(timer.isActive)
            XCTAssertEqual(session, .Focus)
            exp.fulfill()
        }
        timer.delegate = delegate
        timer.startFocus()
        timer.pause()
        timer.resume()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_cancel_notifiesCancel() {
        
        let exp = expectation(description: "Notifies")
        
        let delegate = PomodoroTimerMockDelegate()
        delegate.didCancel = { timer in
            XCTAssertFalse(timer.isActive)
            XCTAssertEqual(timer.session, .Idle)
            exp.fulfill()
        }
        timer.delegate = delegate
        timer.startFocus()
        timer.cancel()
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_start_notifiesTick() {
        
        let exp = expectation(description: "Notifies")
        
        let delegate = PomodoroTimerMockDelegate()
        delegate.didTick = { timer, seconds in
            XCTAssertTrue(timer.isActive)
            XCTAssertLessThan(seconds, self._defaultFocusMinutes*self._secondsPerMinute)
            exp.fulfill()
        }
        timer.delegate = delegate
        timer.startFocus()
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_start_notifiesEnd() {
        
        let exp = expectation(description: "Notifies")
        
        let delegate = PomodoroTimerMockDelegate()
        delegate.didEndSession = { timer, session in
            XCTAssertFalse(timer.isActive)
            XCTAssertEqual(timer.secondsRemaining, 0)
            XCTAssertEqual(timer.session, .Focus)
            exp.fulfill()
        }
        timer = PomodoroTimer(focus: 3, short: 2, long: 2, streaks: _defaultStreaks, autoBreak: true)
        timer.delegate = delegate
        timer.startFocus()
        
        wait(for: [exp], timeout: 5)
    }
    
    func test_resumeFocusSession_notifiesResume() {
        
        let exp = expectation(description: "Notifies")
        let delegate = PomodoroTimerMockDelegate()
        delegate.didResumeSession = { timer, session in
            XCTAssertTrue(timer.isActive)
            XCTAssertEqual(timer.session, .Focus)
            exp.fulfill()
        }
        timer.delegate = delegate
        timer.resumeSession(seconds: 44, session: .Focus)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_resumeIdleSession_notifiesResume() {
        
        let exp = expectation(description: "Does not notifies")
        let delegate = PomodoroTimerMockDelegate()
        delegate.didResumeSession = { timer, session in
            XCTAssertFalse(timer.isActive)
            XCTAssertEqual(timer.session, .Idle)
            exp.fulfill()
        }
        timer.delegate = delegate
        timer.resumeSession(seconds: 45, session: .Idle)
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_changeSettings_notifiesChange() {
        
        let exp = expectation(description: "Notifies")
        let delegate = PomodoroTimerMockDelegate()
        delegate.didChangedSettings = { timer, settings in
            exp.fulfill()
        }
        timer.delegate = delegate
        timer.settings = PomodoroTimer.Settings()
        
        wait(for: [exp], timeout: 1)
    }
    
    
    // MARK: - Mock Delegate
    class PomodoroTimerMockDelegate: PomodoroTimerDelegate {
        
        var didStartSession: (( PomodoroTimer, PomodoroTimer.SessionType ) -> Void)?
        var didPauseSession: (( PomodoroTimer, PomodoroTimer.SessionType ) -> Void)?
        var didResumeSession: (( PomodoroTimer, PomodoroTimer.SessionType ) -> Void)?
        var didEndSession: (( PomodoroTimer, PomodoroTimer.SessionType ) -> Void)?
        var didTick: (( PomodoroTimer, Double ) -> Void)?
        var didCancel: (( PomodoroTimer ) -> Void)?
        var didChangedSettings: (( PomodoroTimer, PomodoroTimer.Settings ) -> Void)?
        var didResetStreaks: ((PomodoroTimer) -> Void)?
        
        func pomodoroTimer(_ timer: PomodoroTimer, didStartSession session: PomodoroTimer.SessionType) {
            didStartSession?(timer, session)
        }
        
        func pomodoroTimer(_ timer: PomodoroTimer, didTickWith seconds: Double) {
            didTick?(timer, timer.secondsRemaining)
        }
        
        func pomodoroTimer(_ timer: PomodoroTimer, didPauseSession session: PomodoroTimer.SessionType) {
            didPauseSession?(timer, session)
        }
        
        func pomodoroTimer(_ timer: PomodoroTimer, didResumeSession session: PomodoroTimer.SessionType) {
            didResumeSession?(timer, session)
        }
        
        func pomodoroTimer(_ timer: PomodoroTimer, didEndSession session: PomodoroTimer.SessionType) {
            didEndSession?(timer, session)
        }
        
        func pomodoroTimerDidCancel(_ timer: PomodoroTimer) {
            didCancel?(timer)
        }
        
        func pomodoroTimer(_ timer: PomodoroTimer, didChangedSettings settings: PomodoroTimer.Settings) {
            didChangedSettings?(timer, settings)
        }
        
        func pomodoroTimerDidResetStreaks(_ timer: PomodoroTimer) {
            didResetStreaks?(timer)
        }
    }
    
    // MARK: - Streaks
    func test_setStreaks_withPositiveValue_updatesStreaksValue() {
        timer.streaksCount = 3
        
        XCTAssertEqual(timer.streaksCount, 3)
    }
    
    func test_setStreaks_withNegativeValue_setZero() {
        timer.streaksCount = -4
        
        XCTAssertEqual(timer.streaksCount, 0)
    }
    
    func test_startFocus_shouldntIncreaseStreaks() {
        timer.startFocus()
        
        XCTAssertEqual(timer.streaksCount, 0)
    }
    
    func test_endFocus_shouldIncreaseStreaks() {
        timer.startFocus(seconds: 2)
        
        let exp = expectation(description: "Increase Streaks")
        let result = XCTWaiter.wait(for: [exp], timeout: 3)
        if result == .timedOut {
            XCTAssertGreaterThan(timer.streaksCount, 0)
        }
    }
    
    func test_endBreak_shouldntIncreaseStreaks() {
        timer.startShortBreak(seconds: 2)
        
        let exp = expectation(description: "Shouldn't increase streaks")
        let result = XCTWaiter.wait(for: [exp], timeout: 3)
        if result == .timedOut {
            XCTAssertEqual(timer.streaksCount, 0)
        }
    }
    
    func test_endLongBreak_resetsStreaks() {
        timer.streaksCount = 4
        timer.startLongBreak(seconds: 2)
        
        let exp = expectation(description: "Resets streaks")
        let result = XCTWaiter.wait(for: [exp], timeout: 3)
        if result == .timedOut {
            XCTAssertEqual(timer.streaksCount, 0)
        }
    }
    
    func test_resetStreaks_setZero() {
        timer.streaksCount = 3
        timer.resetStreaks()
        
        XCTAssertEqual(timer.streaksCount, 0)
    }
    
    func test_resetStreaks_dispatchNotification() {
        
        let exp = expectation(description: "Notifies")
        let delegate = PomodoroTimerMockDelegate()
        delegate.didResetStreaks = { timer in
            exp.fulfill()
        }
        
        timer.delegate = delegate
        timer.streaksCount = 3
        timer.resetStreaks()
        
        wait(for: [exp], timeout: 1)
    }
    
    
    // MARK: - Get End Time
    func test_getEndTime_onIdle_returnsNil() {
        let endTime = timer.getCurrentSessionEndTime()
        
        XCTAssertNil(endTime)
    }
    
    func test_getEndTime_onFocus_returnsEndTime() {
        timer.startFocus()
        let endTime = timer.getCurrentSessionEndTime()
        
        XCTAssertEqual(endTime?.timeIntervalSinceNow.rounded(), 25*60)
    }
    
    func test_getEndTime_onFocusCustomSeconds_returnsEndTime() {
        timer.startFocus(seconds: 44)
        let endTime = timer.getCurrentSessionEndTime()
        
        XCTAssertEqual(endTime?.timeIntervalSinceNow.rounded(), 44)
    }
    
    func test_getEndTime_onBreak_returnsEndTime() {
        timer.startShortBreak(seconds: 56)
        let endTime = timer.getCurrentSessionEndTime()
        
        XCTAssertEqual(endTime?.timeIntervalSinceNow.rounded(), 56)
    }
    
    func test_getEndTime_onPause_returnNil() {
        timer.startFocus()
        timer.pause()
        let endTime = timer.getCurrentSessionEndTime()
        
        XCTAssertNil(endTime?.timeIntervalSinceNow.rounded())
    }
    
    func test_getBreakEndTime_onIdle_returnsNil() {
        let endTime = timer.getBreakEndTime()
        
        XCTAssertNil(endTime?.timeIntervalSinceNow.rounded())
    }
    
    func test_getBreakEndTime_onFocus_returnsEndTime() {
        timer.startFocus()
        let endTime = timer.getBreakEndTime()
        
        XCTAssertEqual(endTime?.timeIntervalSinceNow.rounded(), (25+5)*60)
    }
    
    func test_getBreakEndTime_onBreak_returnEndTimer() {
        timer.startShortBreak()
        let endTime = timer.getBreakEndTime()
        
        XCTAssertEqual(endTime?.timeIntervalSinceNow.rounded(), 5*60)
    }
    
    // MARK: - State
    func test_getCurrentState_whileFocusActive_matchValues() {
        timer.startFocus()
        let state = timer.getCurrentState()
        
        XCTAssertEqual(state.type, .Focus)
        XCTAssertEqual(state.active, timer.isActive)
        XCTAssertEqual(state.streak, 0)
        XCTAssertNil(state.secondsRemaining)
        XCTAssertEqual(state.endTime?.timeIntervalSinceNow.rounded(), Date(timeIntervalSinceNow: _defaultFocusMinutes*_secondsPerMinute).timeIntervalSinceNow.rounded())
    }
    
    func test_getCurrentState_whileIdle_matchValues() {
        let state = timer.getCurrentState()
        
        XCTAssertEqual(state.type, .Idle)
        XCTAssertEqual(state.active, false)
        XCTAssertEqual(state.streak, 0)
        XCTAssertEqual(state.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
        XCTAssertNil(state.endTime)
    }
    
    func test_getCurrentState_whileFocusAndPaused_matchValues() {
        timer.startFocus()
        timer.pause()
        let state = timer.getCurrentState()
        
        XCTAssertEqual(state.type, .Focus)
        XCTAssertEqual(state.active, false)
        XCTAssertEqual(state.streak, 0)
        XCTAssertEqual(state.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
        XCTAssertNil(state.endTime)
    }
    
    func test_setState_withFocusActive_startsFocusSession() {
        timer.startFocus()
        let state = timer.getCurrentState()
        timer.cancel()
        
        let exp = expectation(description: "Set state")
        let result = XCTWaiter.wait(for: [exp], timeout: 3)
        if result == .timedOut {
            timer.setState(state)
            
            XCTAssertEqual(timer.session, .Focus)
            XCTAssertTrue(timer.isActive)
            XCTAssertLessThan(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute - 1)
        }
    }
    
    func test_setState_withFocusPause_pausesFocusSession() {
        timer.startFocus()
        timer.pause()
        let state = timer.getCurrentState()
        timer.cancel()
        
        let exp = expectation(description: "Set state")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if result == .timedOut {
            timer.setState(state)
            
            XCTAssertEqual(timer.session, .Focus)
            XCTAssertFalse(timer.isActive)
            XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
        }
    }
    
    func test_setState_withIdle_staysIdle() {
        let state = timer.getCurrentState()
        timer.startFocus()
        
        let exp = expectation(description: "Set state")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if result == .timedOut {
            timer.setState(state)
            
            XCTAssertEqual(timer.session, .Idle)
            XCTAssertFalse(timer.isActive)
            XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
        }
    }
    
    func test_setState_withAutoBreak_expiredFocusSession_startsBreak() {
        timer.startFocus(seconds: 1)
        let state = timer.getCurrentState()
        timer.cancel()
        
        let exp = expectation(description: "Set state")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if result == .timedOut {
            timer.setState(state)
            
            XCTAssertEqual(timer.session, .ShortBreak)
            XCTAssertTrue(timer.isActive)
            XCTAssertLessThanOrEqual(timer.secondsRemaining, _defaultShortBreakMinutes*_secondsPerMinute)
            XCTAssertGreaterThan(timer.secondsRemaining, _defaultShortBreakMinutes*_secondsPerMinute - 3)
        }
    }
    
    func test_setState_withoutAutoBreak_expiredFocusSession_startsBreak() {
        timer = PomodoroTimer(focus: 25, short: 5, long: 15, streaks: 4, autoBreak: false)
        timer.startFocus(seconds: 1)
        let state = timer.getCurrentState()
        timer.cancel()
        
        let exp = expectation(description: "Set state")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if result == .timedOut {
            timer.setState(state)
            
            XCTAssertEqual(timer.session, .Idle)
            XCTAssertFalse(timer.isActive)
        }
    }
    
    func test_setState_withExpiredBreakSession_staysIdle() {
        timer.startShortBreak(seconds: 1)
        let state = timer.getCurrentState()
        timer.cancel()
        
        let exp = expectation(description: "Set state")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if result == .timedOut {
            timer.setState(state)
            
            XCTAssertEqual(timer.session, .Idle)
            XCTAssertFalse(timer.isActive)
        }
    }
    
    func test_setState_withExpiredFocusAndBreakSessions_staysIdle() {
        timer = PomodoroTimer(focus: 1, short: 1, long: 1, streaks: 4, autoBreak: true)
        timer.startFocus()
        let state = timer.getCurrentState()
        timer.cancel()
        
        let exp = expectation(description: "Set state")
        let result = XCTWaiter.wait(for: [exp], timeout: 3)
        if result == .timedOut {
            timer.setState(state)
            
            XCTAssertEqual(timer.session, .Idle)
            XCTAssertFalse(timer.isActive)
        }
    }
    
    // MARK: Auto Break
    func test_startFocus_startsBreakAfter() {
        timer.startFocus(seconds: 1)
        
        let exp = expectation(description: "starts break")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if result == .timedOut {
            XCTAssertEqual(timer.session, .ShortBreak)
            XCTAssertTrue(timer.isActive)
        }
    }
    
    func test_startFocusWithoutAutoBreak_staysInactiveAtFocus() {
        guard let settings = PomodoroTimer.Settings(focusDuration: 25, shortBreakDuration: 5, longBreakDuration: 15, streaksToLongBreak: 4, autoBreak: false) else {
            XCTFail()
            return
        }
        
        timer = PomodoroTimer(settings: settings)
        timer.startFocus(seconds: 1)
        
        let exp = expectation(description: "stays inactive at focus")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if result == .timedOut {
            XCTAssertEqual(timer.session, .Focus)
            XCTAssertFalse(timer.isActive)
        }
    }
    
    func test_startBreak_staysIdleAtEnd() {
        timer.startShortBreak(seconds: 1)
        
        let exp = expectation(description: "starts break")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if result == .timedOut {
            XCTAssertEqual(timer.session, .Idle)
            XCTAssertFalse(timer.isActive)
        }
    }
}
