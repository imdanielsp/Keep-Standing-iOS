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
//    static var secondInHour: Double = 60.0 * 60.0
    static var secondInHour: Double = 5.0
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var burnedCaloriesLabel: UILabel!
    @IBOutlet weak var standingTimeLabel: UILabel!
    @IBOutlet weak var sittingTimeLabel: UILabel!
    @IBOutlet weak var sitButton: UIButton!
    @IBOutlet weak var standButton: UIButton!
    @IBOutlet weak var progressBar: UICircularProgressRingView!
    
    // State
    var tracking: StateType = .none {
        willSet {
            self.userDataManager.currentState = newValue.form
        }
    }
    
    // Timer and current data
    var timer: Timer = Timer()
    
    var currentTime: Int = 0 {
        willSet {
            self.userDataManager.currentTime = newValue
        }
    }
    
    var currentBurnedCalories: Double = 0.0 {
        willSet {
            self.burnedCaloriesLabel.text = String(format: "%0.1f", newValue)
        }
    }
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
 
    var currentProgress: (value: CGFloat, interval: Double) = (0.0 , 0.0) {
        willSet {
            self.progressBar.setProgress(value: newValue.value,
                                         animationDuration: newValue.interval)
        }
    }

    // MARK: - Health Manager
    let healthManager = HealthManager.getInstance()
    
    
    // MARK: - UserData Manager
    let userDataManager = UserDataManager()
    
    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViews()
        
        // Try to restore data if possible when first enter the app
        self.restoreData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.restoreData),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveCurrentData),
                                               name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveCurrentData),
                                               name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    func restoreData() {
        if let restorePackage = self.userDataManager.buildRestorePacakge() {
            self.currentBurnedCalories = restorePackage.calories
            self.currentStandingTime = restorePackage.standingTime
            self.currentSittingTime = restorePackage.sittingTime
            
            if restorePackage.isTimeStampValid { // We were running, lets catch up
                let lastCurrentTime = restorePackage.currentTime
                let lastProgress = restorePackage.currentProgress
                let lastTimeStamp = restorePackage.lastTimeStamp
                
                self.currentTime = lastCurrentTime + Int(lastTimeStamp.timeIntervalSinceNow)
                self.updateBurnedCaloriesIn(form: restorePackage.lastState)
                
                let newProgressBarValue = 100.0 * (Double(self.currentTime) / MainVC.secondInHour)
                let currentProgressBarValue = newProgressBarValue + lastProgress
                self.updateProgressBar(with: CGFloat(currentProgressBarValue), interval: 0.5)
                
            }
        }
    }
    
    // MARK: - Helper Methods
    func initViews() {
        self.initProgressBar()
    }
    
    func initProgressBar() {
        self.progressBar.value = 0.0
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
    
    func saveCurrentData() {
        self.userDataManager.save(calories: self.currentBurnedCalories,
                                  standingTime: self.currentStandingTime,
                                  sittingTime: self.currentSittingTime) { [weak self] calories, date in
                                    
            self?.healthManager.report(calories: calories, date: Date()) { success, error in
                if error != nil {
                    let message = "Couldn't save data to Health Kit"
                    let alertController = UIAlertController(title: "Error", message: message,
                                                            preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(action)
                    
                    DispatchQueue.main.async {
                        self?.present(alertController, animated: true)
                    }
                }
            }
        }
    }
    
    func calculateBurnedCalories(with weight: Double, met factor: Double) -> Double {
        return (weight * (1.0/MainVC.secondInHour) * factor) / 100
    }
    
    func updateBurnedCaloriesIn(form: FormType) {
        let weight = self.userDataManager.weight
        if weight != 0 {
            let burnedCalories = self.calculateBurnedCalories(with: weight, met: form.rawValue)
            switch form {
            case .sitting:
                self.currentBurnedCalories += burnedCalories
            case .standing:
                self.currentBurnedCalories += burnedCalories
            case .none:
                break
            }
            
            // Save and report
            self.saveCurrentData()
        } else {
            self.timer.invalidate()
            self.currentTime = 0
            // TODO: - Show error that can't calculate calories
            print("Weight is zero or no set!")
        }
    }
    
    func updateProgressBar(with value: CGFloat, interval: Double) {
        self.currentProgress = (value, interval)
        
        // Store the value
        self.userDataManager.currentProgress = Double(value)
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
                
                self?.updateBurnedCaloriesIn(form: .sitting)
                    
                if progress >= 100.0 { // Done, stop the timer
                    self?.updateProgressBar(with: 0.0, interval: 1.0)
                    timer.invalidate()
                    self?.currentTime = 0
                    self?.changeStatusTo(active: false)
                    self?.tracking = .none
                } else {  // Keep going
                    self?.updateProgressBar(with: progress, interval: 0.5)
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
                
                self?.updateBurnedCaloriesIn(form: .standing)
                
                if progress >= 100.0 { // Done, stop the timer
                    self?.updateProgressBar(with: 0.0, interval: 1.0)
                    timer.invalidate()
                    self?.currentTime = 0
                    self?.changeStatusTo(active: false)
                    self?.tracking = .none
                } else {  // Keep going cool :)
                    self?.updateProgressBar(with: progress, interval: 0.5)
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

