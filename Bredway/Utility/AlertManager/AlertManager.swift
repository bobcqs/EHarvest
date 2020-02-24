//
//  AlertManager.swift
//  Bredway
//
//  Created by Xudong Chen on 7/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class AlertManager{
    
    // MARK: - Varaibles
    
    private init() { }
    
    static let shared = AlertManager()
    
    func showAlert(message: String, timeInterval: Int, viewController: UIViewController) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        viewController.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + .seconds(timeInterval)
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
}

