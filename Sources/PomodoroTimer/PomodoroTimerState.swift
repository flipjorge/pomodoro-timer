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

public extension PomodoroTimer {
    
    struct State: Codable, Equatable {
        
        // MARK: - Values
        public let type: SessionType
        public let active: Bool
        public let streak: Int
        public let endTime: Date?
        public let secondsRemaining: Double?
        
        // MARK: - Init
        public init(activeWithType type: SessionType, streak: Int, endTime: Date) {
            self.type = type
            self.active = true
            self.streak = streak
            self.endTime = endTime
            self.secondsRemaining = nil
        }
        
        public init(inactiveWithType type: SessionType, streak: Int, secondsRemaining: Double) {
            self.type = type
            self.active = false
            self.streak = streak
            self.endTime = nil
            self.secondsRemaining = secondsRemaining
        }
        
        // MARK: - Coding Keys
        enum CodingKeys: String, CodingKey {
            case type = "t"
            case active = "a"
            case streak = "st"
            case endTime = "et"
            case secondsRemaining = "sr"
        }
        
        // MARK: - Equatable
        public static func == (lhs: State, rhs: State) -> Bool {
            return lhs.type == rhs.type &&
                lhs.active == rhs.active &&
                lhs.streak == rhs.streak &&
                lhs.endTime?.timeIntervalSince1970.rounded() == rhs.endTime?.timeIntervalSince1970.rounded() &&
                lhs.secondsRemaining == rhs.secondsRemaining
        }
    }
}
