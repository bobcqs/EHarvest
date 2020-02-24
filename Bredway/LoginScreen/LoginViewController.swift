//
//  LoginViewController.swift
//  Bredway
//
//  Created by Xudong Chen on 20/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FBSDKLoginKit
import NVActivityIndicatorView

protocol SwitchTabProtocol{
    func switchTab(selectIndex: Int)
}

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, NVActivityIndicatorViewable, UITextFieldDelegate {
    
    //IBOutlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var googleLoginView: LoginButtonView!
    @IBOutlet weak var facebookLoginView: LoginButtonView!
    @IBOutlet weak var termsTextView: UITextView!
    
    //Properties
    var selectedIndex: Int!
    var delegate: SwitchTabProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        FBSDKLoginManager().logOut()
//        GIDSignIn.sharedInstance().signOut()
//        
//        do{
//            try Auth.auth().signOut()
//        }catch let logOutError {
//            print(logOutError)
//        }
    }
    
    func setupView(){
        setupKeyboard()
        emailField.delegate = self
        passwordField.delegate = self
        termsTextView.delegate = self
        termsTextView.hyperLink(originalText: "By sigining in, you agree to Eharvest's Terms and Conditions", hyperLink: "Terms and Conditions", urlString: "https://www.eharvest.com.au/terms-conditions/")
        emailField.addBorder(toSide: .Bottom, withColor: UIColor.black.cgColor, andThickness: 1.3)
        passwordField.addBorder(toSide: .Bottom, withColor: UIColor.black.cgColor, andThickness: 1)
        
        let googleGesture = UITapGestureRecognizer(target: self, action:  #selector(self.googleLoginSelected))
        googleLoginView.addGestureRecognizer(googleGesture)
        
        let fbGesture = UITapGestureRecognizer(target: self, action:  #selector(self.facebookLoginSelected))
        facebookLoginView.addGestureRecognizer(fbGesture)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    @objc func googleLoginSelected(){
        print ("Google")
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil{
            print(error)
            return
        }else{
            UserManager.shared.signInWithGoogle(user: user, completion: { (result) in
                if result == LoginResult.success{
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.switchTab(selectIndex: self.selectedIndex)
                }
            })
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    @objc func facebookLoginSelected(){
        print ("Facebook")
        UserManager.shared.signInWithFacebook(viewController: self) { (result) in
            if result == LoginResult.success{
                self.dismiss(animated: true, completion: nil)
                self.delegate?.switchTab(selectIndex: self.selectedIndex)
            }
        }
    }
    
    @IBAction func emailLoginselected(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text else {
            print("Registeration entry is not valid")
            return
        }
        
        UserManager.shared.signInWithEmail(email: email, password: password) { (result) in
            if result == LoginResult.success{
                self.dismiss(animated: true, completion: nil)
                self.delegate?.switchTab(selectIndex: self.selectedIndex)
            }
        }
    }
    
    @IBAction func createAccountSelected(_ sender: Any) {
        performSegue(withIdentifier: "toRegister", sender: nil)
    }
    
    
    @IBAction func forgotPasswordSelected(_ sender: Any) {
        performSegue(withIdentifier: "toForgotPassword", sender: nil)
    }
    
    @IBAction func closeButtonSelected(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension LoginViewController: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if (URL.absoluteString == "https://www.bredway.com.au/terms-conditions/") {
            UIApplication.shared.openURL(URL)
        }
        return false
    }
}
