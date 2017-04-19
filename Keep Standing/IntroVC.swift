    //
//  IntroVC.swift
//  Keep Standing
//
//  Created by Daniel Santos on 4/18/17.
//  Copyright © 2017 Daniel Santos. All rights reserved.
//

import UIKit
import HealthKit

class IntroVC: UIViewController {
    
    @IBOutlet weak var weightPicker: UIPickerView!
    
    private let userDataManager = UserDataManager()
    
    // MARK: - Health Manager
    let healthManager = HealthManager.getInstance()
    
    lazy private var weightPickerManager: WeightPickerManager = {
        return WeightPickerManager(manager: self.userDataManager)
    }()

    override func viewWillLayoutSubviews() {
        if userDataManager.isWeightSet {
            performSegue(withIdentifier: "toMainVC", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load user will perform a segue if got the data from HealthKit
        self.loadUserWeight()
        
        // This make the pickers and labels visiable if loadUserWeight() wasn't successful
        self.showPickers()
    }

    func showPickers() {
        self.weightPicker.dataSource = weightPickerManager
        self.weightPicker.delegate = weightPickerManager
        self.weightPicker.selectRow(100, inComponent: 0, animated: true)
    } 
    
    func loadUserWeight() {
        // Weight
        self.healthManager.authorizeHealthKit { [weak self] success, error in
            
            if let error = error {
                let alertController = UIAlertController(title: "Error", message: "We had an unkown problem. We are working on it.",
                                                        preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(action)
                self?.present(alertController, animated: true)
                
                fatalError("\(error.localizedDescription)")
            }
            
            // Auth success
            if success {
                self?.healthManager.getWeight { [weak self] result, error in
                    
                    if error != nil {
                        let alertController = UIAlertController(title: "Health Kit", message: "Please authorize this app in the Health app.",
                                                                preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(action)
                        
                        DispatchQueue.main.async {
                            self?.present(alertController, animated: true)
                        }
                    }
                    
                    if let result = result {
                        // Got data from HealthKit, good
                        let weight = (result as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.pound())
                        self?.userDataManager.weight = weight
                        DispatchQueue.main.async {
                            self?.performSegue(withIdentifier: "toMainVCAnimated", sender: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func startButtonPressed() {
        if self.userDataManager.isWeightSet {
            performSegue(withIdentifier: "toMainVCAnimated", sender: nil)
        } else {
            let alertController = UIAlertController(title: "Please selet your weight", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true)
        }
    }
}
