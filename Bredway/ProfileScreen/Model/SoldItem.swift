//
//  SoldItem.swift
//  Bredway
//
//  Created by Xudong Chen on 30/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

class SoldItem: Mappable {
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
    var buyerId: String?
    var lastUpdated: String?
    var isShippingUpdated: Bool?
    var buyerName: String?
    var buyerAddress: String?
    var tradeStatus: String?
    var courierCompany: String?
    var courierTrackingNumber: String?
    var referenceId: String?
    var isSold: String?

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
        buyerId     <- map["buyerId"]
        lastUpdated <- map["lastUpdated"]
        timeStamp <- map["timeStamp"]
        isShippingUpdated <- map["isShippingUpdated"]
        buyerName <- map["buyerName"]
        buyerAddress <- map["buyerAddress"]
        tradeStatus <- map["tradeStatus"]
        courierCompany <- map["courierCompany"]
        courierTrackingNumber <- map["courierTrackingNumber"]
        referenceId <- map["referenceId"]
        isSold <- map["isSold"]
    }
}
