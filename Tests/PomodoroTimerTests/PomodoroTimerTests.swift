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
    private let _secondsPerMinute = 60
    private let _defaultFocusMinutes = 25
    private let _defaultShortBreakMinutes = 5
    private let _defaultLongBreakMinutes = 15
    
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
        XCTAssertEqual(timer.focusDuration, _defaultFocusMinutes*_secondsPerMinute)
        XCTAssertEqual(timer.shortBreakDuration, _defaultShortBreakMinutes*_secondsPerMinute)
        XCTAssertEqual(timer.longBreakDuration, _defaultLongBreakMinutes*_secondsPerMinute)
        
        XCTAssertEqual(timer.focusMinutesDuration, _defaultFocusMinutes)
        XCTAssertEqual(timer.shortBreakMinutesDuration, _defaultShortBreakMinutes)
        XCTAssertEqual(timer.longBreakMinutesDuration, _defaultLongBreakMinutes)
        
        XCTAssertEqual(timer.session, PomodoroTimer.SessionType.Idle)
        XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
    }
    
    func test_init_givenValidArgsInSeconds_initializesWithCorrectValues() {
        timer = PomodoroTimer(focus: _defaultFocusMinutes*_secondsPerMinute, short: _defaultShortBreakMinutes*_secondsPerMinute, long: _defaultLongBreakMinutes*_secondsPerMinute)
        
        XCTAssertEqual(timer.focusDuration, _defaultFocusMinutes*_secondsPerMinute)
        XCTAssertEqual(timer.shortBreakDuration, _defaultShortBreakMinutes*_secondsPerMinute)
        XCTAssertEqual(timer.longBreakDuration, _defaultLongBreakMinutes*_secondsPerMinute)
        
        XCTAssertEqual(timer.focusMinutesDuration, _defaultFocusMinutes)
        XCTAssertEqual(timer.shortBreakMinutesDuration, _defaultShortBreakMinutes)
        XCTAssertEqual(timer.longBreakMinutesDuration, _defaultLongBreakMinutes)
        
        XCTAssertEqual(timer.session, PomodoroTimer.SessionType.Idle)
        XCTAssertEqual(timer.secondsRemaining, _defaultFocusMinutes*_secondsPerMinute)
    }
    
    func test_init_given90Seconds_minutePropertiesCeilRoundsTo1Minute() {
        timer = PomodoroTimer(focus: 90, short: 90, long: 90)
        
        XCTAssertEqual(timer.focusDuration, 90)
        XCTAssertEqual(timer.shortBreakDuration, 90)
        XCTAssertEqual(timer.longBreakDuration, 90)
        
        XCTAssertEqual(timer.focusMinutesDuration, 1)
        XCTAssertEqual(timer.shortBreakMinutesDuration, 1)
        XCTAssertEqual(timer.longBreakMinutesDuration, 1)
    }
    
    func test_init_givenValidArgsInMinutes_initializesWithCorrectValues() {
        timer = PomodoroTimer(focusMinutes: 40, shortMinutes: 10, longMinutes: 25)
        
        XCTAssertEqual(timer.focusDuration, 40*_secondsPerMinute)
        XCTAssertEqual(timer.shortBreakDuration, 10*_secondsPerMinute)
        XCTAssertEqual(timer.longBreakDuration, 25*_secondsPerMinute)
        
        XCTAssertEqual(timer.focusMinutesDuration, 40)
        XCTAssertEqual(timer.shortBreakMinutesDuration, 10)
        XCTAssertEqual(timer.longBreakMinutesDuration, 25)
        
        XCTAssertEqual(timer.session, PomodoroTimer.SessionType.Idle)
        XCTAssertEqual(timer.secondsRemaining, 40*_secondsPerMinute)
    }
    
    func test_init_givenInvalidArgs_failsInit() {
        timer = PomodoroTimer(focus: -10, short: _defaultShortBreakMinutes, long: _defaultLongBreakMinutes)
        
        XCTAssertNil(timer)
    }
    
    func test_init_givenInvalidArgsInMinutes_failsInit() {
        timer = PomodoroTimer(focusMinutes: -10, shortMinutes: _defaultShortBreakMinutes, longMinutes: _defaultShortBreakMinutes)
        
        XCTAssertNil(timer)
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
        timer.streaksCount = 3
        timer.startFocus()
        let sessionType = timer.getNextBreakType()
        
        XCTAssertEqual(sessionType, .ShortBreak)
    }
    
    func test_getNextBreakOnFocusAndFourStreaks_returnsLongBreak() {
        timer.streaksCount = 4
        timer.startFocus()
        let sessionType = timer.getNextBreakType()
        
        XCTAssertEqual(sessionType, .LongBreak)
    }
    
    func test_startBreak_whenStreaksCountIsZero_startsShortBreak() {
        timer.startBreak()
        
        XCTAssertEqual(timer.session, .ShortBreak)
    }
    
    func test_startBreak_whenStreaksIsThree_startsShortBreak() {
        timer.streaksCount = 3
        timer.startBreak()
        
        XCTAssertEqual(timer.session, .ShortBreak)
    }
    
    func test_startBreak_whenStreaksIsFour_startsLongBreak() {
        timer.streaksCount = 4
        timer.startBreak()
        
        XCTAssertEqual(timer.session, .LongBreak)
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
    func test_resume_resumesCounting() {
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
        timer = PomodoroTimer(focus: 3, short: 2, long: 2)
        timer.delegate = delegate
        timer.startFocus()
        
        wait(for: [exp], timeout: 5)
    }
    
    class PomodoroTimerMockDelegate: PomodoroTimerDelegate {
        
        var didStartSession: (( PomodoroTimer, PomodoroTimer.SessionType ) -> Void)?
        var didPauseSession: (( PomodoroTimer, PomodoroTimer.SessionType ) -> Void)?
        var didResumeSession: (( PomodoroTimer, PomodoroTimer.SessionType ) -> Void)?
        var didEndSession: (( PomodoroTimer, PomodoroTimer.SessionType ) -> Void)?
        var didTick: (( PomodoroTimer, Int ) -> Void)?
        var didCancel: (( PomodoroTimer ) -> Void)?
        
        func pomodoroTimer(_ timer: PomodoroTimer, didStartSession session: PomodoroTimer.SessionType) {
            didStartSession?(timer, session)
        }
        
        func pomodoroTimer(_ timer: PomodoroTimer, didTickWith seconds: Int) {
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
}
