//
//  TimerApplication.swift
//  Clinic Check in
//
//  Created by Satabhisha on 06/07/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

class TimerApplication: UIApplication {
    // the timeout in seconds, after which should perform custom actions
    // such as disconnecting the user
    private var timeoutInSeconds: TimeInterval {
        // 2 minutes
        return 10
    }
    
    private var idleTimer: Timer?
    
    // resent the timer because there was user interaction
    private func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
        
        idleTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds,
                                         target: self,
                                         selector: #selector(TimerApplication.timeHasExceeded),
                                         userInfo: nil,
                                         repeats: false
        )
    }
    
    // if the timer reaches the limit as defined in timeoutInSeconds, post this notification
    @objc private func timeHasExceeded() {
        print("session timeout777")
//        NotificationCenter.default.post(name: .appTimeout,
//                                        object: nil
//        )
    }
    
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        print("Event: ")
        if idleTimer != nil {
            self.resetIdleTimer()
        }
        
        if let touches = event.allTouches {
            for touch in touches where touch.phase == UITouchPhase.began {
                self.resetIdleTimer()
            }
        }
    }
}

