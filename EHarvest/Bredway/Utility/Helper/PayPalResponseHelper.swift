//
//  PayPalResponseHelper.swift
//  Bredway
//
//  Created by Xudong Chen on 3/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation

class PayPalResponseHelper{
    
    static let shared = PayPalResponseHelper()
    
    func toJSON(stringValue: String) -> [String: String]{
        var result: Dictionary = [String : String]()
        if let s = stringValue.removingPercentEncoding {
            let paraArray = s.components(separatedBy: "&")
            for component in paraArray{
                let pair = component.components(separatedBy: "=")
                result[pair[0]] = pair[1]
            }
        }
        return result
    }
}
