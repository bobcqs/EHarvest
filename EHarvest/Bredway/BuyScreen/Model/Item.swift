//
//  Item.swift
//  Bredway
//
//  Created by Xudong Chen on 16/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

class Item: Mappable {
    var itemId: String?
    var brand: String?
    var category: String?
    var condition: String?
    var email: String?
    var itemDescription: String?
    var name: String?
    var price: Int?
    var sellerId: String?
    var shippingEnabled: String?
    var size: String?
    var timeStamp: String?
    var imageUrls: [String]?
    var sellerImageUrl: String?
    var sellerName: String?
    var sellerRating: String?
    var isSold: Bool?
    
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        itemId <- map["itemId"]
        brand     <- map["brand"]
        category     <- map["category"]
        condition     <- map["condition"]
        email     <- map["email"]
        itemDescription     <- map["itemDescription"]
        name     <- map["name"]
        price     <- map["price"]
        sellerId     <- map["sellerId"]
        shippingEnabled     <- map["shippingEnabled"]
        size     <- map["size"]
        timeStamp     <- map["timeStamp"]
        imageUrls     <- map["imageUrls"]
        sellerImageUrl     <- map["sellerImageUrl"]
        sellerName     <- map["sellerName"]
        sellerRating     <- map["sellerRating"]
        isSold     <- map["isSold"]
    }
}

