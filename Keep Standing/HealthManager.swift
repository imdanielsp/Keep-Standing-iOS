//
//  HealthReporter.swift
//  Keep Standing
//
//  Created by Daniel Santos on 4/17/17.
//  Copyright © 2017 Daniel Santos. All rights reserved.
//

import HealthKit

typealias HealthManagerHandler = (_ success: Bool, _ error: Error?) ->Void
typealias HealthManagerSampleHandler = (_ sample: HKSample?, _ error: Error?) -> Void


enum HealthManagerError: Error {
    case noValueAvailable(String)
}

final class HealthManager {
    //
    // Singleton
    //
    private static var healthManager: HealthManager?
    
    static func getInstance() -> HealthManager {
        if self.healthManager == nil {
            self.healthManager = HealthManager()
        }
        return self.healthManager!  // For sure, healthManager no optional
    }

    //
    // HKHealStore instance
    //
    let healthStore = HKHealthStore()
    
    //
    // User Height
    //
    private var userHeight: HKSample? = nil
    
    var height: HKSample? {
        get {
            return self.userHeight
        }
    }
    
    //
    // User Weight
    //
    private var userWeight: HKSample? = nil
    
    var weight: HKSample? {
        get {
            return self.userHeight
        }
    }
    
    // 
    // Authorization
    //
    
    var weightAuthStatus: HKAuthorizationStatus {
        return self.healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .bodyMass)!)
    }
    
    func authorizeHealthKit(completion: HealthManagerHandler? = nil) {
        let healthDataToRead = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!)
        
        let healthDataToWrite = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier:
            .activeEnergyBurned)!)
        
        if !HKHealthStore.isHealthDataAvailable() {
            if let completion = completion {
                completion(false, NSError(domain: "us.danielsantos.keepstanding", code: 2,
                                          userInfo: [
                                            NSLocalizedDescriptionKey:
                                            "Health data is not available in this device"]))
            }
            return
        }
        
        self.healthStore.requestAuthorization(toShare: healthDataToWrite, read: healthDataToRead) { success, error in
            if let completion = completion {
                completion(success, error)
            }
        }
    }
    
    //
    // Get User's data from registered reading
    //
    private func getData(sampleType: HKSampleType, completion: HealthManagerSampleHandler? = nil) {
        let distantPastValue = Date.distantPast
        let currentDate = Date()
        let lastValuePredicate = HKQuery.predicateForSamples(withStart: distantPastValue,
                                                              end: currentDate, options: [])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        let query = HKSampleQuery(sampleType: sampleType, predicate: lastValuePredicate, limit: 1, sortDescriptors: [sortDescriptor]) { sampleQuery, results, error in
            // If error, try completion and return
            if let error = error {
                if let completion = completion {
                    completion(nil, error)
                }
                return
            }
            
            // Check that the is a value for sure, otherwise send an .noValueFound
            guard let lastValue = results?.first else {
                if let completion = completion {
                    completion(nil, HealthManagerError.noValueAvailable("\(sampleType.identifier) no available in HealthKit"))
                }
                return
            }
            
            // Everything is good, we got value from HealthKit, error == nil
            if let completion = completion {
                completion(lastValue, nil)
            }
        }
        self.healthStore.execute(query)
    }
    
    //
    // Gets the weight of the user using the getData helper function.
    //
    func getWeight(completion: HealthManagerSampleHandler? = nil) {
        let sampleType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        self.getData(sampleType: sampleType) { result, error in
            if error != nil {
                if let completion = completion {
                    completion(nil, error)
                }
                return
            }
            
            self.userWeight = result
            
            if let completion = completion {
                completion(result, nil)
            }
        }
    }
    
    //
    // Gets the height of the user using the getData helper function.
    //
    func getHeight(completion: HealthManagerSampleHandler? = nil) {
        let sampleType = HKObjectType.quantityType(forIdentifier: .height)!
        self.getData(sampleType: sampleType) { result, error in
            if error != nil {
                if let completion = completion {
                    completion(nil, error)
                }
                return
            }
            
            self.userHeight = result
            
            if let completion = completion {
                completion(result, nil)
            }
        }
    }
    
}
