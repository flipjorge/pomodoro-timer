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
    public init() { }
    
    public init?(focus: Int, short: Int, long: Int) {
        guard focus > 0, short > 0, long > 0 else {
            return nil
        }
        
        _focusDuration = focus
        _shortBreakDuration = short
        _longBreakDuration = long
    }
    
    // MARK: - Properties
    private var _focusDuration: Int = 25
    
    public var focusDuration: Int {
        return _focusDuration
    }
    
    public var _shortBreakDuration: Int = 5
    
    public var shortBreakDuration: Int {
        return _shortBreakDuration
    }
    
    private var _longBreakDuration: Int = 15
    
    public var longBreakDuration: Int {
        return _longBreakDuration
    }
    
    // MARK: - Timer
    private var _timer: STimer?
    
    public var isActive: Bool {
        return _timer?.isActive ?? false
    }
    
    public var secondsRemaining: Int {
        return _timer?.secondsRemaining ?? 0
    }
    
    // MARK: - Start Focus
    public func startFocus() {
        //stop current time
        
        _timer = STimer()
        guard let timer = _timer else { return }
        timer.start(_focusDuration*60)
    }
    
}
