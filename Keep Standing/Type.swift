//
//  File.swift
//  Keep Standing
//
//  Created by Daniel Santos on 4/17/17.
//  Copyright © 2017 Daniel Santos. All rights reserved.
//

import Foundation

enum FormType: Double {
    // This are METS values, check this Harvard's Measuring Physical Activity table for more
    // https://www.hsph.harvard.edu/nutritionsource/mets-activity-table/
    case none = 0.0
    case standing = 2.0
    case sitting = 1.2
}

enum StateType{
    case none
    case trackingStanding
    case trackingSitting
    
    var form: FormType {
        switch self {
        case .none:
            return .none
        case .trackingSitting:
            return .sitting
        case .trackingStanding:
            return .standing
        }
    }
}
