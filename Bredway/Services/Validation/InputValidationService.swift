//
//  InputValidationService.swift
//  Bredway
//
//  Created by Xudong Chen on 7/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation

struct Validation{
    var result: Bool
    var message: String
}

class InputValidationService{
    
    // MARK: - Varaibles
    
    private init() { }
    
    static let shared = InputValidationService()
    
    func isValid(input: String, type: ValidationType)-> Validation{
        switch type {
        case .email:
            return validateEmail(email: input)
        case .price:
            return validatePrice(price: input)
        case .itemDescription:
            return validateItemDescription(itemDescription: input)
        case .itemName:
            return validateItemName(name: input)
        case .category:
            return validateCategory(category: input)
        case .brand:
            return validateBrand(brand: input)
        case .size:
            return validateSize(size: input)
        case .condition:
            return validateCondition(condition: input)
        default:
            return Validation(result: true, message: "")
        }
    }
    
    func validateCondition(condition: String)-> Validation{
        if condition.isEmpty{
            return Validation(result: false, message: "Please choose an item condition")
        } else {
            return Validation(result: true, message: "")
        }
    }
    
    func validateSize(size: String)-> Validation{
        if size.isEmpty{
            return Validation(result: true, message: "Please choose an item size")
        } else {
            return Validation(result: true, message: "")
        }
    }
    
    func validateBrand(brand: String)-> Validation{
        if brand.isEmpty{
            return Validation(result: true, message: "Please choose an item brand")
        } else {
            return Validation(result: true, message: "")
        }
    }
    
    func validateCategory(category: String)-> Validation{
        if category.isEmpty{
            return Validation(result: false, message: "Please choose an item category")
        } else {
            return Validation(result: true, message: "")
        }
    }
    
    func validateItemName(name: String)-> Validation{
        if name.isEmpty{
            return Validation(result: false, message: "Please enter a name for your item")
        } else {
            return Validation(result: true, message: "")
        }
    }
    
    func validateItemDescription(itemDescription: String)-> Validation{
        if itemDescription.isEmpty{
            return Validation(result: false, message: "Please enter a description for your item")
        } else {
            return Validation(result: true, message: "")
        }
    }
    
    func validatePrice(price: String)-> Validation{
        if price.isEmpty{
            return Validation(result: false, message: "Please enter a price for your item")
        } else {
            return Validation(result: true, message: "")
        }
    }
    
    func validateEmail(email: String)-> Validation{
        if email.isEmpty{
            return Validation.init(result: false, message: "Email address cannot be empty")
        }
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        if emailPredicate.evaluate(with: email){
            return Validation.init(result: true, message: "")
        } else {
            return Validation(result: false, message: "Please enter a correct email format")
        }
    }
}
