//
//  RestorePacket.swift
//  Keep Standing
//
//  Created by Daniel Santos on 4/24/17.
//  Copyright © 2017 Daniel Santos. All rights reserved.
//

import Foundation

struct RestorePackage {
    let calories: Double
    let standingTime: Double
    let sittingTime: Double
    let lastSaved: Date?
    
    // Used for restoring
    let isTimeStampValid: Bool
    let lastTimeStamp: Date
    let lastState: FormType
    let currentTime: Int
    let currentProgress: Double
}
