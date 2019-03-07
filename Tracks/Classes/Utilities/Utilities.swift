//
//  Utilities.swift
//  Tracks
//
//  Created by David Ross on 10/07/2018.
//  Copyright © 2018 David Ross. All rights reserved.
//

import UIKit

class Utilities: NSObject {
    
    static let shared = Utilities()
    
    func formatTime(time: CMTime) -> String {
        
        let totalSeconds = Int(CMTimeGetSeconds(time))
        
        return self.formatTime(time: totalSeconds)
    }
    
    func formatTime(time: Float) -> String {
        
        let totalSeconds = Int(time)
        
        return self.formatTime(time: totalSeconds)
    }
    
    func formatTime(time: TimeInterval) -> String {
        
        let totalSeconds = Int(time)
        
        return self.formatTime(time: totalSeconds)
    }
    
    func formatTime(time: Int) -> String {
        
        let hours = time / 3600
        let minutes = time % 3600 / 60
        let seconds = time % 3600 % 60

        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
}
