//
//  Payment.swift
//  Bredway
//
//  Created by Xudong Chen on 27/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

struct Payment: Mappable {
    var itemId: String?

    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        itemId <- map["itemId"]
    }
}

