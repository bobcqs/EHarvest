//
//  RegisterViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 20/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView(){
        setupKeyboard()
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        usernameField.addBorder(toSide: .Bottom, withColor: UIColor.black.cgColor, andThickness: 1.3)
        emailField.addBorder(toSide: .Bottom, withColor: UIColor.black.cgColor, andThickness: 1.3)
        passwordField.addBorder(toSide: .Bottom, withColor: UIColor.black.cgColor, andThickness: 1.3)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
       // self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        guard let name = usernameField.text, let email = emailField.text, let password = passwordField.text else {
            print("Registeration entry is not valid")
            return
        }
        
        UserManager.shared.registerByEmail(username: name, email: email, password: password) { (result) in
            if result == LoginResult.success{
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
