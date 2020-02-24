//
//  PayPalManager.swift
//  Bredway
//
//  Created by Xudong Chen on 15/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

class PayPalManager{
    
    // MARK: - Varaibles
    
    private init() { }
    
    static let shared = PayPalManager()
    
    var commissionRate: Double {
        get {
            if let rate = UserDefaults.standard.value(forKey: PAYPAL_COMMISSION_RATE) as? Double{
                return rate
            }
            return 5.0
        }
        set{
            UserDefaults.standard.set(newValue, forKey: PAYPAL_COMMISSION_RATE)
        }
    }
    
    var payPalRate: Double {
        get {
            if let rate = UserDefaults.standard.value(forKey: PAYPAL_PROCESS_RATE) as? Double{
                return rate
            }
            return 2.6
        }
        set{
            UserDefaults.standard.set(newValue, forKey: PAYPAL_PROCESS_RATE)
        }
    }
    
    func getCommissionRate(){
        let db = Firestore.firestore()
        let keyRef = db.collection(FilePath.FIREBASE_PAYPAL_ACCOUNT).document(FilePath.FIREBASE_PRODUCTION_PAYPAL_API_KEY)
        keyRef.getDocument(completion: { (document, error) in
            if let err = error {
                logger.debug("Failed to fetch PayPal API Key from database and error is \(err)")
            } else {
                if let apiData = document?.data(){
                    if let apiComissionRate = apiData["comissionRate"]{
                        self.commissionRate = apiComissionRate as? Double ?? 5
                    }
                    if let apiPayPalRate = apiData["payPalRate"]{
                        self.payPalRate = apiPayPalRate as? Double ?? 2.6
                    }
                }
            }
        })
    }
}
