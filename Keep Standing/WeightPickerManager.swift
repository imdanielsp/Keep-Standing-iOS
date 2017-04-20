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
    
    private let userDataManager: UserDataManager
    private weak var picker: UIPickerView?
    
    init(manager: UserDataManager, picker: UIPickerView? = nil) {
        self.userDataManager = manager
        self.picker = picker
        
        if let picker = self.picker {
            picker.selectRow(self.weights.count/2, inComponent: 0, animated: false)
        }
    }
    
    // MARK: - UIPickerViewDataSource Protocol
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data[component].count
    }
    
    // MARK: - UIPickerViewDelegate Protocol
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let data = self.data[component][row]
        let attrString = NSAttributedString(string: data,
                                            attributes: [
                                                NSForegroundColorAttributeName: UIColor.lightGray])
        return attrString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.userDataManager.weight = Double(self.weights[row]) ?? 0
    }

}
