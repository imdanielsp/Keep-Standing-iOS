//
//  UserManager.swift
//  Keep Standing
//
//  Created by Daniel Santos on 4/17/17.
//  Copyright © 2017 Daniel Santos. All rights reserved.
//

import Foundation

extension Date {
    func daysBetween(date: Date) -> Int {
        let componets = Calendar.current.dateComponents([.day], from: self, to: date)
        return componets.day ?? 0
    }
    
    func isPastRelative(to date: Date) -> Bool {
        return self.daysBetween(date: date) > 0
    }
    
}

enum DataMangerKey: String {
    case weight = "WeightKey"
    case height = "HeightKey"
    case lastSaved = "LastSaved"
    case calories = "CaloriesKey"
}

typealias UserDataManagerHanlder = (_ calories: Double, _ date: Date) -> Void

class UserDataManager {
    let userDefaults: UserDefaults
    
    // Object key
    let weightKey: String = "WeightKey"
    let heightKey: String = "HeightKey"
    let lastSavedKey: String = "LastSaved"
    
    // Data+Observers+Setter+Getters
    private var userHeight: Double? {
        willSet {
            self.userDefaults.set(newValue, forKey: DataMangerKey.height.rawValue)
        }
    }
    
    var height: Double? {
        get {
            return self.userDefaults.double(forKey: DataMangerKey.height.rawValue)
        } set {
            self.userHeight = newValue
        }
    }
    
    private var userWeight: Double? {
        willSet {
            self.userDefaults.set(newValue, forKey: DataMangerKey.weight.rawValue)
        }
    }
    
    var weight: Double? {
        get {
            return self.userDefaults.double(forKey: DataMangerKey.weight.rawValue)
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
        return self.userDefaults.object(forKey: DataMangerKey.weight.rawValue) != nil
    }
    
    var isHeightSet: Bool {
        return self.userDefaults.object(forKey: DataMangerKey.height.rawValue) != nil
    }
    
    // Save Calories Burned
    func save(calories: Double, completion: UserDataManagerHanlder? = nil) {
        let lastSavedKey = DataMangerKey.lastSaved.rawValue
        let caloriesKey = DataMangerKey.calories.rawValue
        let now = Date()
        
        if let lastSaved = self.userDefaults.object(forKey: lastSavedKey) as? Date {
            
            if lastSaved.isPastRelative(to: now) {
                // Saved Yesterday, new calories!
                self.userDefaults.set(calories, forKey: caloriesKey)
            } else {
                // Saved Today
                let oldCalories = self.userDefaults.double(forKey: caloriesKey)
                let deltaCalories = calories - oldCalories
                let newCalories = oldCalories + deltaCalories
                
                if let completion = completion  {
                    completion(newCalories, now)
                }
                
                self.userDefaults.set(newCalories, forKey: caloriesKey)
            }
            
        } else {
            // Never saved
            self.userDefaults.set(calories, forKey: caloriesKey)
        }
        
        self.userDefaults.set(now, forKey: DataMangerKey.lastSaved.rawValue)
        
        if let completion = completion {
            completion(calories, now)
        }
    }
}
