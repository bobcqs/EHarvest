//
//  ForgotPasswordViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 28/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView(){
        setupKeyboard()
        emailField.delegate = self
        emailField.addBorder(toSide: .Bottom, withColor: UIColor.black.cgColor, andThickness: 1.3)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        guard let email = emailField.text else {
            logger.info("Email address is not valid")
            return
        }
        
        UserManager.shared.forgotPasswordWithEmail(email: email) { (result) in
            if result == LoginResult.success{
                logger.info("Forgot email is sent successfully")
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
