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
    case standingTime = "StandingTimeKey"
    case sittingTime = "SittingTimeKey"
}

typealias UserDataManagerHanlder = (_ calories: Double, _ date: Date) -> Void

struct RestorePackage {
    let calories: Double
    let standingTime: Double
    let sittingTime: Double
    let lastSaved: Date?
}

class UserDataManager {
    let userDefaults: UserDefaults
    
    // Object key
    let weightKey: String = "WeightKey"
    let heightKey: String = "HeightKey"
    let lastSavedKey: String = "LastSaved"
    
    // Data+Observers+Setter+Getters
    private var userHeight: Double?
    
    var height: Double {
        get {
            return self.userDefaults.double(forKey: DataMangerKey.height.rawValue)
        } set {
            self.userDefaults.set(newValue, forKey: DataMangerKey.height.rawValue)
            self.userHeight = newValue
        }
    }
    
    private var userWeight: Double?
    
    var weight: Double {
        get {
            return self.userDefaults.double(forKey: DataMangerKey.weight.rawValue)
        } set {
            self.userDefaults.set(newValue, forKey: DataMangerKey.weight.rawValue)
            self.userWeight = newValue
        }
    }
    
    private var userStandingTime: Double?
    
    var standingTime: Double {
        get {
            return self.userDefaults.double(forKey: DataMangerKey.standingTime.rawValue)
        } set {
            self.userDefaults.set(newValue, forKey: DataMangerKey.standingTime.rawValue)
            self.userStandingTime = newValue
        }
    }
    
    private var userSittingTime: Double?
    
    var sittingTime: Double {
        get {
            return self.userDefaults.double(forKey: DataMangerKey.sittingTime.rawValue)
        } set {
            self.userDefaults.set(newValue, forKey: DataMangerKey.sittingTime.rawValue)
            self.userSittingTime = newValue
        }
    }
    
    private var userCalories: Double?
    
    var calories: Double {
        get {
            return self.userDefaults.double(forKey: DataMangerKey.calories.rawValue)
        } set {
            self.userDefaults.set(newValue, forKey: DataMangerKey.calories.rawValue)
            self.userCalories = newValue
        }
    }
    
    private var lastSaved: Date? {
        get {
            return self.userDefaults.object(forKey: DataMangerKey.lastSaved.rawValue) as? Date
        } set {
            self.userDefaults.set(newValue, forKey: DataMangerKey.lastSaved.rawValue)
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
    func save(calories: Double? = nil, standingTime: Double? = nil, sittingTime: Double? = nil,
              completion: UserDataManagerHanlder? = nil) {
        
        self.save(timeStanding: standingTime, sitting: sittingTime)
        
        if let calories = calories {
            self.save(calories: calories, completion: completion)
        }
    }
    
    private func save(calories: Double, completion: UserDataManagerHanlder? = nil) {
        let now = Date()
        
        if let lastSaved = self.lastSaved {
            
            if lastSaved.isPastRelative(to: now) {
                // Saved Yesterday, new calories!
                self.calories = calories
            } else {
                // Saved Today
                let oldCalories = self.calories
                let deltaCalories = calories - oldCalories
                let newCalories = oldCalories + deltaCalories
                
                if let completion = completion  {
                    completion(newCalories, now)
                }
                
                self.calories = newCalories
            }
            
        } else {
            // Never saved
            self.calories = calories
        }
        
        self.lastSaved = now
        
        if let completion = completion {
            completion(calories, now)
        }
    }
    
    private func save(timeStanding: Double?, sitting: Double?) {
        if let standingTime = timeStanding {
            self.standingTime = standingTime
        }
        
        if let sittingTime = sitting {
            self.sittingTime = sittingTime
        }
    }
    
    // Restore
    func buildRestorePacakge() -> RestorePackage? {
        guard let lastSaved = self.lastSaved, !lastSaved.isPastRelative(to: Date())  else {
            return nil
        }
        
        return RestorePackage(calories: self.calories,
                              standingTime: self.standingTime,
                              sittingTime: self.sittingTime,
                              lastSaved: self.lastSaved)
    }
}
