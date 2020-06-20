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

public extension PomodoroTimer {
    
    struct Settings: Codable, Equatable {
        
        // MARK: - Value
        public let focusDuration: Double
        public let shortBreakDuration: Double
        public let longBreakDuration: Double
        public let streaksToLongBreak: Int
        
        // MARK: - Initializers
        public init() {
            focusDuration = 25*60
            shortBreakDuration = 5*60
            longBreakDuration = 15*60
            streaksToLongBreak = 4
        }
        
        public init?(focusDuration: Double, shortBreakDuration: Double, longBreakDuration: Double, streaksToLongBreak: Int) {
            
            guard focusDuration > 0, shortBreakDuration > 0, longBreakDuration > 0, streaksToLongBreak > 0 else {
                return nil
            }
            
            self.focusDuration = focusDuration
            self.shortBreakDuration = shortBreakDuration
            self.longBreakDuration = longBreakDuration
            self.streaksToLongBreak = streaksToLongBreak
        }
        
        // MARK: - Properties
        public var focusMinutesDuration: Double {
            return focusDuration/60
        }
        
        public var shortBreakMinutesDuration: Double {
            return shortBreakDuration/60
        }
        
        public var longBreakMinutesDuration: Double {
            return longBreakDuration/60
        }
        
        
        // MARK: - Coding Keys
        enum CodingKeys: String, CodingKey {
            case focusDuration = "fd"
            case shortBreakDuration = "sbd"
            case longBreakDuration = "lbd"
            case streaksToLongBreak = "slb"
        }
    }
}
