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
@testable import PomodoroTimer

final class PomodoroTimerTests: XCTestCase {
    
    // MARK: - Setup
    var timer: PomodoroTimer!
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
        timer = nil
    }
    
    // MARK: - Init
    func test_init_givenNoArgs_setDefaultProperties() {
        timer = PomodoroTimer()
        
        XCTAssertEqual(timer.focusDuration, 25)
        XCTAssertEqual(timer.shortBreakDuration, 5)
        XCTAssertEqual(timer.longBreakDuration, 15)
    }
    
    func test_init_givenValidArgs_initializesWithCorrectValues() {
        timer = PomodoroTimer(focus: 40, short: 10, long: 25)
        
        XCTAssertEqual(timer.focusDuration, 40)
        XCTAssertEqual(timer.shortBreakDuration, 10)
        XCTAssertEqual(timer.longBreakDuration, 25)
    }
    
    func test_init_givenInvalidArgs_failsInit() {
        timer = PomodoroTimer(focus: -10, short: 5, long: 15)
        
        XCTAssertNil(timer)
    }
    
    // MARK: - Start Focus
    func test_start_startsCounting() {
        timer = PomodoroTimer()
        timer.startFocus()
        
        let exp = expectation(description:"Time counts")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertTrue(timer.isActive)
            XCTAssertLessThan(timer.secondsRemaining, 25*60)
            XCTAssertGreaterThan(timer.secondsRemaining, 0)
        } else {
            XCTFail()
        }
    }
    
    // MARK: - Pause
    func test_pause_stopsCounting() {
        timer = PomodoroTimer()
        timer.startFocus()
        timer.pause()
        
        let exp = expectation(description:"Time counts")
        let result = XCTWaiter.wait(for: [exp], timeout: 2)
        if(result == XCTWaiter.Result.timedOut) {
            XCTAssertFalse(timer.isActive)
            XCTAssertEqual(timer.secondsRemaining, 25*60)
        } else {
            XCTFail()
        }
    }
}
