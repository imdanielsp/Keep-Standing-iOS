//
//  ViewController.swift
//  Keep Standing
//
//  Created by Daniel Santos on 4/8/17.
//  Copyright © 2017 Daniel Santos. All rights reserved.
//

import Foundation
import UIKit
import UICircularProgressRing
import HealthKit


class MainVC: UIViewController {
    static var secondInHour = Double(5) // Change to 60 * 60
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var burnedCaloriesLabel: UILabel!
    @IBOutlet weak var standingTimeLabel: UILabel!
    @IBOutlet weak var sittingTimeLabel: UILabel!
    @IBOutlet weak var sitButton: UIButton!
    @IBOutlet weak var standButton: UIButton!
    @IBOutlet weak var progressBar: UICircularProgressRingView!
    
    // State
    var tracking: StateType = .none
    
    // User
    var user = User()
    
    // Timer and current data
    var timer: Timer = Timer()
    var currentTime = 0
    var currentBurnedCalories = 0.0
    var currentStandingTime = 0.0 {
        didSet {
            self.standingTimeLabel.text = String(format: "%0.1f", self.currentStandingTime)
        }
    }
    var currentSittingTime = 0.0 {
        didSet {
            self.sittingTimeLabel.text = String(format: "%0.1f", self.currentSittingTime)
        }
    }
 
    // MARK: - Health Manager
    let healthManager = HealthManager.getInstance()
    
    
    // MARK: - UserData Manager
    let userDataManager = UserDataManager()
    
    // MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViews()
        self.configUserData()
    }
    
    
    // MARK: - Helper Methods
    func initViews() {
        self.makeRoundedButtons()
        self.initProgressBar()
    }
    
    func initProgressBar() {
        self.progressBar.value = 0.0
    }

    func makeRoundedButtons() {
        self.sitButton.layer.cornerRadius = 5
        self.standButton.layer.cornerRadius = 5
    }
    
    func updateStandingTime() {
        self.currentStandingTime += 1.0/MainVC.secondInHour
    }
    
    func updateSittingTime() {
        self.currentSittingTime += 1.0/MainVC.secondInHour
    }
    
    func changeStatusTo(active value: Bool) {
        if value {
            self.statusLabel.text = "TRACKING..."
        } else {
            self.statusLabel.text = "CURRENTLY NOT TRACKING"
        }
    }
    
    func updateBurnedCaloriesIn(form: FormType) throws {
        guard let userWeight = self.user.weight else {
            throw DataError.userDataNotAvailable
        }
        
        switch form {
        case .sitting:
            self.currentBurnedCalories += userWeight * (1.0/MainVC.secondInHour) * form.rawValue
        case .standing:
            self.currentBurnedCalories += userWeight * (1.0/MainVC.secondInHour) * form.rawValue
        }
        
        self.burnedCaloriesLabel.text = String(format: "%0.0f", self.currentBurnedCalories)
    }
    
    func displayValueGetterModal(title: String?, message: String?, actionTitle: String? = "OK",
                                   textFieldPlaceholder: String?,
                                   completion: @escaping (Double) -> Void) {
        
        // Builds a UIAlerController that gets data from the user
        let alertController = UIAlertController(title: title,
                                                message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default) { [weak alertController] _ in
            if let alertController = alertController,
                let textFields = alertController.textFields, let text = textFields[0].text,
                let height = Double(text) {
                // Calls completion
                completion(height)
            }
            
        }
        alertController.addTextField { textField in
            textField.placeholder = textFieldPlaceholder
        }
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    // TODO: - Consider for refactoring because getting height and weight are similar operation
    func configUserData() {
        // Try to load data from UserDataManager, otherwise, try to find it in Health,
        // if none are available get input from user
        
        // User data not set, get it
        // Height
        if !self.userDataManager.isHeightSet {
            // Get height form Health Kit
            self.healthManager.getHeight { [weak self] result, error in
                if let error = error {
                    // Error getting data from HealthKit,
                    // TODO: - Display error
                    print("\(error.localizedDescription)")
                    return
                }
                
                if let result = result {
                    // Got data from HealthKit, good
                    let height = (result as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.meter())
                    self?.user.height = height
                    self?.userDataManager.height = height
                } else {
                    // Data is not set in HealthKit, get it from user
                    self?.displayValueGetterModal(title: "Provide your height", message: "We need your height to calculate the burned calories", textFieldPlaceholder: "Enter height in meters") { [weak self] height in
                        self?.user.height = height
                        self?.userDataManager.height = height
                    }
                }
            }
        } else {
            // Data is avialable from UserDataManager
            self.user.height = self.userDataManager.height!
        }
        
        // Weight
        if !self.userDataManager.isWeightSet {
            // Get height form Health Kit
            self.healthManager.getWeight { [weak self] result, error in
                if let error = error {
                    // Error getting data from HealthKit,
                    // TODO: - Display error
                    print("\(error.localizedDescription)")
                    return
                }
                
                if let result = result {
                    // Got data from HealthKit, good
                    let weight = (result as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.pound())
                    self?.user.weight = weight
                    self?.userDataManager.weight = weight
                } else {
                    // Data is not set in HealthKit, get it from user
                    self?.displayValueGetterModal(title: "Provide your weight",
                                                 message: "We need your weight to calculate the burned calories",
                                                 textFieldPlaceholder: "Enter weight in lbs") { [weak self] weight in
                        self?.user.weight = weight
                        self?.userDataManager.weight = weight
                    }
                }
            }
        } else {
            // Data is avialable from UserDataManager
            self.user.weight = self.userDataManager.weight!
        }
        
    }
    
    // MARK: - Button Actions
    @IBAction func sitButtonPressed() {
        if self.tracking != .trackingSitting {
            if self.timer.isValid {
                // If a timer is running, stop it
                self.timer.invalidate()
                self.currentTime = 0
            }
            
            // Make a timer.
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                // Increment time
                self?.currentTime += 1
                
                // Set progress bar
                let timeNow = Double((self?.currentTime)!)/MainVC.secondInHour
                var progress = CGFloat(timeNow)
                progress *= 100.0  // Convert progress to percentage
                
                // Update label
                self?.updateSittingTime()
                
                do {
                    try self?.updateBurnedCaloriesIn(form: .sitting)
                } catch DataError.userDataNotAvailable {
                    self?.configUserData()
                    do {
                        try self?.updateBurnedCaloriesIn(form: .sitting)
                    } catch {
                        // TODO: - Display Error
                    }
                } catch {
                    // TODO: - Make sure to save current data before quit
                    print("Unkown error in sitButtonPressed")
                    fatalError()
                }
                
                if progress >= 100.0 { // Done, stop the timer
                    self?.progressBar.setProgress(value: 0.0, animationDuration: 1.0)
                    timer.invalidate()
                    self?.currentTime = 0
                    self?.changeStatusTo(active: false)
                    self?.tracking = .none
                } else {  // Keep going
                    self?.progressBar.setProgress(value: progress, animationDuration: 0.5)
                }
            }
            
            // Start the timer
            self.timer.fire()
            self.changeStatusTo(active: true)
            self.tracking = .trackingSitting
        }
    }
    
    @IBAction func standButtonPressed() {
        if self.tracking != .trackingStanding {
            if self.timer.isValid {
                // If a timer is running, stop it
                self.timer.invalidate()
                self.currentTime = 0
            }
            
            // Make a timer.
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                // Increment time
                self?.currentTime += 1
                
                // Set progress bar
                let timeNow = Double((self?.currentTime)!)/MainVC.secondInHour
                var progress = CGFloat(timeNow)
                progress *= 100.0  // Convert progress to percentage
                
                // Update label
                self?.updateStandingTime()
                
                do {
                    try self?.updateBurnedCaloriesIn(form: .standing)
                } catch DataError.userDataNotAvailable {
                    self?.configUserData()
                    do {
                        try self?.updateBurnedCaloriesIn(form: .standing)
                    } catch {
                        // TODO: - Display Error
                    }
                } catch {
                    // TODO: - Make sure to save current data before quit
                    print("Unkown error in standButtonPressed")
                    fatalError()
                }
                
                if progress >= 100.0 { // Done, stop the timer
                    self?.progressBar.setProgress(value: 0.0, animationDuration: 1.0)
                    timer.invalidate()
                    self?.currentTime = 0
                    self?.changeStatusTo(active: false)
                    self?.tracking = .none
                } else {  // Keep going
                    self?.progressBar.setProgress(value: progress, animationDuration: 0.5)
                }
            }
            
            // Start the timer
            self.timer.fire()
            self.changeStatusTo(active: true)
            self.tracking = .trackingStanding
        }
    }
    
    @IBAction func settingButtonPressed() {
    }
}

