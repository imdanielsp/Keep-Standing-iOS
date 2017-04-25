//
//  SettingsVC.swift
//  Keep Standing
//
//  Created by Daniel Santos on 4/21/17.
//  Copyright © 2017 Daniel Santos. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {
    
    let userDataManager: UserDataManager = UserDataManager()
    
    @IBOutlet weak var notifyMeSwitch: UISwitch!
    @IBOutlet weak var standingValueLabel: UILabel!
    @IBOutlet weak var sittingValueLabel: UILabel!
    @IBOutlet weak var weightValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doneButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
