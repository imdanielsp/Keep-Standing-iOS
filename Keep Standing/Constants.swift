//
//  Contants.swift
//  Keep Standing
//
//  Created by Daniel Santos on 4/24/17.
//  Copyright © 2017 Daniel Santos. All rights reserved.
//

import Foundation

enum DataMangerKey: String {
    case weight = "WEIGHT"
    case height = "HEIGHT"
    case lastSaved = "LAST_SAVED"
    case calories = "CALORIES"
    case standingTime = "STANDING_TIME"
    case sittingTime = "SITTING_TIME"
    
    // Saving current progress for background state restorage
    case currentTime = "CURRENT_TIME"
    case currentProgress = "CURRENT_PROGRESS"
    case backgroundStateTimeStap = "BACKGROUND_STATE_TIME_STAMP"
    
    var key: String {
        return self.rawValue
    }
}
