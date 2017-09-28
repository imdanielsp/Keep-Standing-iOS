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
    
    func hoursBetween(date: Date) -> Int {
        let componets = Calendar.current.dateComponents([.hour], from: self, to: date)
        return componets.hour ?? 0
    }
    
    func isPastRelative(to date: Date) -> Bool {
        return self.daysBetween(date: date) > 0
    }
    
    func isValidRelative(to date: Date, hours: Int = 2) -> Bool {
        return self.hoursBetween(date: date) > hours
    }
}

// UserDataManager type alias for function handler
typealias UserDataManagerHanlder = (_ calories: Double, _ date: Date) -> Void

class UserDataManager {
    let userDefaults: UserDefaults

    // Data+Observers+Setter+Getters
    private var userHeight: Double?
    
    var height: Double {
        get {
            return self.userDefaults.double(forKey: DataMangerKey.height.key)
        } set {
            self.userDefaults.set(newValue, forKey: DataMangerKey.height.key)
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
    
    private var timerCurrentTime: Int?
    
    var currentTime: Int {
        get {
            return self.userDefaults.integer(forKey: DataMangerKey.currentTime.key)
        } set {
            self.userDefaults.set(newValue, forKey: DataMangerKey.currentTime.key)
            self.timerCurrentTime = newValue
        }
    }
    
    private var timerCurrentProgress: Double?
    
    var currentProgress: Double {
        get {
            return self.userDefaults.double(forKey: DataMangerKey.currentProgress.key)
        } set {
            self.userDefaults.set(newValue, forKey: DataMangerKey.currentProgress.key)
            self.timerCurrentProgress = newValue
        }
    }
    
    private var backgroundLastTimeStamp: Date?
    
    var backgroundTimeStamp: Date {
        get {
            return self.userDefaults.object(forKey:
                DataMangerKey.backgroundStateTimeStap.key) as! Date
        } set {
            self.userDefaults.set(newValue, forKey: DataMangerKey.backgroundStateTimeStap.key)
            self.backgroundLastTimeStamp = newValue
        }
    }
    
    private var timerCurrentState: FormType?
    
    var currentState: FormType {
        get {
            return self.userDefaults.object(forKey: DataMangerKey.currentState.key) as! FormType
        } set {
            self.userDefaults.set(newValue, forKey: DataMangerKey.currentState.key)
            self.timerCurrentState = newValue
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
    
    var isTimeStampValid: Bool {
        return (self.backgroundLastTimeStamp != nil)
            && self.backgroundLastTimeStamp!.isValidRelative(to: Date())
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
                              lastSaved: self.lastSaved,
                              isTimeStampValid: self.isTimeStampValid,
                              lastTimeStamp: self.backgroundTimeStamp,
                              lastState: self.currentState,
                              currentTime: self.currentTime,
                              currentProgress: self.currentProgress)
    }
}
