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

public final class PomodoroTimerStateTests: XCTestCase {
    
    // MARK: - Init
    func test_initActive_initWithRightValues() {
        let state = PomodoroTimer.State(activeWithType: .Focus, streak: 2, endTime: Date(timeIntervalSinceNow: 20))
        
        XCTAssertEqual(state.type, .Focus)
        XCTAssertTrue(state.active)
        XCTAssertEqual(state.streak, 2)
        XCTAssertEqual(state.endTime?.timeIntervalSince1970.rounded(), Date(timeIntervalSinceNow: 20).timeIntervalSince1970.rounded())
        XCTAssertNil(state.secondsRemaining)
    }
    
    func test_initInactive_initWithRightValues() {
        let state = PomodoroTimer.State(inactiveWithType: .Idle, streak: 0, secondsRemaining: 58)
        
        XCTAssertEqual(state.type, .Idle)
        XCTAssertFalse(state.active)
        XCTAssertEqual(state.streak, 0)
        XCTAssertNil(state.endTime)
        XCTAssertEqual(state.secondsRemaining, 58)
    }
    
    // MARK: - Equatable
    func test_compareEqualStates_returnsTrue() {
        let state1 = PomodoroTimer.State(activeWithType: .Focus, streak: 2, endTime: Date(timeIntervalSinceNow: 43))
        let state2 = PomodoroTimer.State(activeWithType: .Focus, streak: 2, endTime: Date(timeIntervalSinceNow: 43))
        
        XCTAssertEqual(state1, state2)
    }
    
    func test_compareDifferentStates_returnsFalse() {
        let state1 = PomodoroTimer.State(activeWithType: .LongBreak, streak: 4, endTime: Date(timeIntervalSinceNow: 13))
        let state2 = PomodoroTimer.State(activeWithType: .Focus, streak: 2, endTime: Date(timeIntervalSinceNow: 44))
        
        XCTAssertNotEqual(state1, state2)
    }
    
    // MARK: - Codable
    func test_encodingAndDecoding_match() throws {
        let state = PomodoroTimer.State(activeWithType: .Focus, streak: 1, endTime: Date(timeIntervalSinceNow: 36))
        
        let encodedData = try JSONEncoder().encode(state)
        let decodedData = try JSONDecoder().decode(PomodoroTimer.State.self, from: encodedData) as PomodoroTimer.State
        
        XCTAssertEqual(state, decodedData)
    }
    
    func test_decodingFromJsonString() throws {
        
        let json = Data("""
        {
            "t" : 1,
            "a" : true,
            "st" : 2,
            "et" : 100000,
            "sr" : 34
        }
        """.utf8)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let decodedData = try decoder.decode(PomodoroTimer.State.self, from: json) as PomodoroTimer.State
        
        XCTAssertEqual(decodedData.type, .Focus)
        XCTAssertTrue(decodedData.active)
        XCTAssertEqual(decodedData.streak, 2)
        XCTAssertEqual(decodedData.endTime?.timeIntervalSince1970.rounded(), 100000)
        XCTAssertEqual(decodedData.secondsRemaining, 34)
    }
    
    func test_decodingFromInvalidJsonString_throws() throws {
        
        let json = Data("""
        {
            "dafagc" : 45,
            "qweqerqwr" : 4,
            "asdwdw" : 16,
            "afasdf" : 5
        }
        """.utf8)
        
        XCTAssertThrowsError(try JSONDecoder().decode(PomodoroTimer.Settings.self, from: json) as PomodoroTimer.Settings)
    }
}
