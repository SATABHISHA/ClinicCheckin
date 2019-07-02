//
//  Inactive.swift
//  Clinic Check in
//
//  Created by Satabhisha on 06/07/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import UIKit

@objc(Inactive)

class Inactive: UIApplication {
    private var timeoutInSeconds: TimeInterval {
        // 2 minutes
        return 60
    }
    
    private var idleTimer: Timer?
    
    // resent the timer because there was user interaction
    private func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
        
        idleTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds,
                                         target: self,
                                         selector: #selector(Inactive.timeHasExceeded),
                                         userInfo: nil,
                                         repeats: false
        )
    }
    
    // if the timer reaches the limit as defined in timeoutInSeconds, post this notification
    @objc private func timeHasExceeded() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "InactiveMode"), object: nil)
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

