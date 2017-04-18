//
//  WieghtPickerViewDataSource.swift
//  Keep Standing
//
//  Created by Daniel Santos on 4/18/17.
//  Copyright © 2017 Daniel Santos. All rights reserved.
//

import UIKit

class WeightPickerManager: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private var weights: [String] = (50...350).map{ String($0) }
    private var units: [String] = ["Pounds"]
    
    lazy private var data: [[String]] = [self.weights, self.units]
    
    let userDataManager: UserDataManager
    
    init(manager: UserDataManager) {
        self.userDataManager = manager
    }
    
    // MARK: - UIPickerViewDataSource Protocol
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data[component].count
    }
    
    // MARK: - UIPickerViewDelegate Protocol
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.data[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
                
        self.userDataManager.weight = Double(self.weights[row])
    }
    
}
