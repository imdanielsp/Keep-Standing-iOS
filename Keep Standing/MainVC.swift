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
    
    func updateBurnedCaloriesIn(form: FormType) {
        if let weight = self.userDataManager.weight {
            switch form {
            case .sitting:
                self.currentBurnedCalories += weight * (1.0/MainVC.secondInHour) * form.rawValue
            case .standing:
                self.currentBurnedCalories += weight * (1.0/MainVC.secondInHour) * form.rawValue
            }
            
            self.burnedCaloriesLabel.text = String(format: "%0.0f", self.currentBurnedCalories)
        }
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
                
                self?.updateBurnedCaloriesIn(form: .standing)
                
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

