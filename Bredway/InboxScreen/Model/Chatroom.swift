//
//  Chatroom.swift
//  Bredway
//
//  Created by Xudong Chen on 9/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

class Chatroom: Mappable {
    var chatroomId: String?
    var buddyId: String?
    var buddyDisplayName: String?
    var buddyProfileImageUrl: String?
    var buyerId: String?
    var itemImageUrl: String?
    var lastMessage: String?
    var lastUpdated: Date?
    var sellerId: String?
    var timeStamp: String?
    var buddyInfoTimeStamp: String?
    var hasUnreadMessage: Bool?

    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        chatroomId <- map["chatroomId"]
        buddyId <- map["buddyId"]
        buddyDisplayName <- map["buddyDisplayName"]
        buddyProfileImageUrl <- map["buddyProfileImageUrl"]
        buyerId <- map["buyerId"]
        itemImageUrl <- map["itemImageUrl"]
        lastMessage <- map["lastMessage"]
        lastUpdated <- map["lastUpdated"]
        sellerId <- map["sellerId"]
        timeStamp <- map["timeStamp"]
        buddyInfoTimeStamp <- map["buddyInfoTimeStamp"]
        hasUnreadMessage <- map["hasUnreadMessage"]
    }
}
