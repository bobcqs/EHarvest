//
//  SettingsViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 5/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var tabDelegate: SwitchTabProtocol?
    var isFromLogout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if isFromLogout{
           self.tabDelegate?.switchTab(selectIndex: 0)
        }
    }

   
    @IBAction func logOutButtonDidPress(_ sender: Any) {
        isFromLogout = true
        UserManager.shared.logOut()
        self.navigationController?.popToRootViewController(animated: true)
    }
}
