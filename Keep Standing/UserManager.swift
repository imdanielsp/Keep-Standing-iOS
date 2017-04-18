//
//  UserManager.swift
//  Keep Standing
//
//  Created by Daniel Santos on 4/17/17.
//  Copyright © 2017 Daniel Santos. All rights reserved.
//

import Foundation


class UserDataManager {
    let userDefaults: UserDefaults
    
    // Object key
    let weightKey: String = "WeightKey"
    let heightKey: String = "HeightKey"
    
    // Data+Observers+Setter+Getters
    private var userHeight: Double? {
        willSet {
            self.userDefaults.set(newValue, forKey: self.heightKey)
        }
    }
    
    var height: Double? {
        get {
            return self.userDefaults.double(forKey: self.heightKey)
        } set {
            self.userHeight = newValue
        }
    }
    
    private var userWeight: Double? {
        willSet {
            self.userDefaults.set(newValue, forKey: self.weightKey)
        }
    }
    
    var weight: Double? {
        get {
            return self.userDefaults.double(forKey: self.weightKey)
        } set {
            self.userWeight = newValue
        }
    }
    
    // Init
    init() {
        self.userDefaults = UserDefaults()
    }
    
    // Helpers
    var isWeightSet: Bool {
        return self.userDefaults.object(forKey: self.weightKey) != nil
    }
    
    var isHeightSet: Bool {
        return self.userDefaults.object(forKey: self.heightKey) != nil
    }
    
}
