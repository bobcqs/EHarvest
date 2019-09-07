//
//  SellingItem.swift
//  Bredway
//
//  Created by Xudong Chen on 2/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import UIKit

struct SellingItem {
    var category: String?
    var brand: String?
    var name: String?
    var size: String?
    var condition: String?
    var itemDescription: String?
    var price: Int?
    var email: String?
    var shippingEnabled: Bool?
    var images: [UIImage]?
    
    private var dictionary: [String: Any] {
        return ["category": category ?? "",
                "brand": brand ?? "",
                "name": name ?? "",
                "size": size ?? "",
                "condition": condition ?? "",
                "itemDescription": itemDescription ?? "",
                "price": price ?? 0,
                "email": email ?? "",
                "shippingEnabled": shippingEnabled ?? false,
                "images": images ?? [UIImage]()]
    }
    
    var asDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
    
    var firebaseDictionary: [String: Any] {
        
        guard let shipping = shippingEnabled else {
            return Dictionary<String, Any>()
        }
        
        return ["category": category ?? "",
                "brand": brand ?? "",
                "name": name ?? "",
                "size": size ?? "",
                "condition": condition ?? "",
                "itemDescription": itemDescription ?? "",
                "price": price ?? 0,
                "email": email ?? "",
                "shippingEnabled": shipping ? "Aus Nationwide" : "Other"]
    }
    
    var asFirebaseDictionary: NSDictionary {
        return firebaseDictionary as NSDictionary
    }

    var isInputValid: Bool {
        guard let itemCategory = category, !itemCategory.isEmpty else {
            return false
        }
        guard let itemName = name, !itemName.isEmpty else {
            return false
        }
        guard let itemCondition = condition, !itemCondition.isEmpty else {
            return false
        }
        guard let itemDescription = itemDescription, !itemDescription.isEmpty else {
            return false
        }
        guard let itemPrice = price, itemPrice >= 5 else {
            return false
        }
        guard let payPalEmail = email, !payPalEmail.isEmpty else {
            return false
        }
        guard let isShipping = shippingEnabled, isShipping == true else {
            return false
        }
        guard let photos = images, photos.count > 1 else {
            return false
        }
        
        if itemDescription == "Description"{
            return false
        }
        
        return true
    }
    
}
