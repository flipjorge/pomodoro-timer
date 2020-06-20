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

final class PomodoroTimerSettingsTests: XCTestCase {

    // MARK: - Initializers
    func test_initWithEmptyArgs_initWithDefaultValues() {
        let settings = PomodoroTimer.Settings()
        
        XCTAssertEqual(settings.focusDuration, 25*60)
        XCTAssertEqual(settings.shortBreakDuration, 5*60)
        XCTAssertEqual(settings.longBreakDuration, 15*60)
        XCTAssertEqual(settings.streaksToLongBreak, 4)
    }
    
    func test_initWithCustomArgs_initWithCustomValues() {
        let settings = PomodoroTimer.Settings(focusDuration: 40, shortBreakDuration: 7, longBreakDuration: 20, streaksToLongBreak: 6)
        
        XCTAssertEqual(settings?.focusDuration, 40)
        XCTAssertEqual(settings?.shortBreakDuration, 7)
        XCTAssertEqual(settings?.longBreakDuration, 20)
        XCTAssertEqual(settings?.streaksToLongBreak, 6)
    }
    
    func test_initWithNegativeValue_failsInit() {
        let settings = PomodoroTimer.Settings(focusDuration: -25, shortBreakDuration: -5, longBreakDuration: -15, streaksToLongBreak: -2)
        
        XCTAssertNil(settings)
    }
    
    // MARK: - Equatable
    func test_compareEqualSettings_returnsTrue() {
        let settings1 = PomodoroTimer.Settings()
        let settings2 = PomodoroTimer.Settings()
        
        XCTAssertEqual(settings1, settings2)
    }
    
    func test_compareDifferentSettings_returnsFalse() {
        let settings1 = PomodoroTimer.Settings()
        let settings2 = PomodoroTimer.Settings(focusDuration: 344, shortBreakDuration: 55, longBreakDuration: 96, streaksToLongBreak: 6)
        
        XCTAssertNotEqual(settings1, settings2)
    }
    
    // MARK: - Codable
    func test_encodingAndDecoding_match() throws {
        let settings = PomodoroTimer.Settings()
        
        let encodedData = try JSONEncoder().encode(settings)
        let decodedSettings = try JSONDecoder().decode(PomodoroTimer.Settings.self, from: encodedData) as PomodoroTimer.Settings
        
        XCTAssertEqual(settings, decodedSettings)
    }
    
    func test_decodingFromJsonString() throws {
        
        let json = Data("""
        {
            "fd" : 45,
            "sbd" : 4,
            "lbd" : 16,
            "slb" : 5
        }
        """.utf8)
        
        let decodedSettings = try JSONDecoder().decode(PomodoroTimer.Settings.self, from: json) as PomodoroTimer.Settings
        
        XCTAssertEqual(decodedSettings.focusDuration, 45)
        XCTAssertEqual(decodedSettings.shortBreakDuration, 4)
        XCTAssertEqual(decodedSettings.longBreakDuration, 16)
        XCTAssertEqual(decodedSettings.streaksToLongBreak, 5)
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
