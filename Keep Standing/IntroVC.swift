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
        
        self.weightPicker.dataSource = weightPickerManager
        self.weightPicker.delegate = weightPickerManager
    
    }

}
