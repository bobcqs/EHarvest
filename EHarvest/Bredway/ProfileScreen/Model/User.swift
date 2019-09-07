//
//  SoldItem.swift
//  Bredway
//
//  Created by Xudong Chen on 30/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

class Person: Mappable {
    var userId: String?
    var userProfileImageUrl: String?
    var userEmail: String?
    var userDisplayName: String?
    
    init (){
        
    }
    
    init(userId: String, userProfileImageUrl: String, userDisplayName: String) {
        self.userId = userId
        self.userProfileImageUrl = userProfileImageUrl
        self.userDisplayName = userDisplayName
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        userId <- map["userId"]
        userProfileImageUrl <- map["userProfileImageUrl"]
        userEmail <- map["userEmail"]
        userDisplayName <- map["userDisplayName"]
    }
}
