# Pomodoro Timer

![Swift](https://github.com/flipjorge/pomodoro-timer/workflows/Swift/badge.svg)
![SPM](https://img.shields.io/badge/spm-compatible-red)
![GitHub](https://img.shields.io/github/license/flipjorge/pomodoro-timer)


## What it does

Provides a layer on top on swift Timer to help implement a Pomodoro timer.


## How to use it

### Basic usage

```swift
class BasicUsage {
    
    init() {
        let timer = PomodoroTimer()
        timer.delegate = self
        timer.startFocus()
    }
}

extension BasicUsage: PomodoroTimerDelegate {
    func pomodoroTimer(_ timer: PomodoroTimer, didStartSession session: PomodoroTimer.SessionType) {
        print("\(session) session started with \(timer.secondsRemaining) seconds remaining")
    }
    
    func pomodoroTimer(_ timer: PomodoroTimer, didTickWith seconds: Int) {
        print("\(timer.secondsRemaining) seconds remaining")
    }
    
    func pomodoroTimer(_ timer: PomodoroTimer, didEndSession session: PomodoroTimer.SessionType) {
        print("\(session) session ended")
    }
}
```

### Initializers

```swift
PomodoroTimer()  //initializes with default pomodoro values (25m, 5m, 15m)
PomodoroTimer(focus: 25*60, short: 5*60, long: 15*60)  //initializes with given seconds
PomodoroTimer(focusMinutes: 25, shortMinutes: 5, longMinutes: 15)  //initializes with given minutes
```

### Starting a Session

```swift
timer.startSession(session: .Focus)  //start a focus session with the duration setted at initialization
timer.startSession(seconds: 120, session: .Focus) //start a focus session with 120 seconds
timer.startSession(session: .ShortBreak)  //start a short break session
timer.startSession(session: .LongBreak)  //start a long break session
        
//alternatives
        
timer.startFocus()
timer.startFocus(seconds: 120)
timer.startShortBreak()
timer.startLongBreak()
```

### Controlling a Session

```swift
timer.pause()
timer.resume()
timer.cancel()  // set session type to .Idle and resets seconds remaining to focus duration
```

### Available Get Properties

```swift
timer.focusDuration  // in seconds
timer.focusMinutesDuration

timer.shortBreakDuration  // in seconds
timer.shortBreakMinutesDuration

timer.longBreakDuration  // in seconds
timer.longBreakMinutesDuration

timer.secondsRemaining
timer.session  // .Idle, .Focus, .ShortBreak, .LongBreak
```
