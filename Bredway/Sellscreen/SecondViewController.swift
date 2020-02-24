//
//  SecondViewController.swift
//  Bredway
//
//  Created by WuKaipeng on 11/3/18.
//  Copyright © 2018 WuKaipeng. All rights reserved.
//

import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI

class SellViewController.swift: UIViewController, FUIAuthDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // You need to adopt a FUIAuthDelegate protocol to receive callback
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self

        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIFacebookAuth()
            ]

        authUI?.providers = providers
        let authViewController = BizzyAuthViewController(authUI: authUI!)
       // present(authViewController, animated: true, completion: nil)
    }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
    }

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }

}

