//
//  IntroVC.swift
//  Keep Standing
//
//  Created by Daniel Santos on 4/18/17.
//  Copyright © 2017 Daniel Santos. All rights reserved.
//

import UIKit

class IntroVC: UIViewController {

    @IBOutlet weak var weightPicker: UIPickerView!
    
    private let userDataManager = UserDataManager()
    
    lazy private var weightPickerManager: WeightPickerManager = {
        return WeightPickerManager(manager: self.userDataManager)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPickers()
    }

    func setupPickers() {
        self.weightPicker.dataSource = weightPickerManager
        self.weightPicker.delegate = weightPickerManager
        
        self.weightPicker.selectRow(100, inComponent: 0, animated: true)

    }
    
    @IBAction func startButtonPressed() {
        if self.userDataManager.isWeightSet {
            performSegue(withIdentifier: "toMainVC", sender: nil)
        } else {
            let alertController = UIAlertController(title: "Please selet your weight", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true)
        }
    }
}
