//
//  RetailSlider.swift
//  Bredway
//
//  Created by Xudong Chen on 14/9/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

class RetailSlider: Mappable {
    var sliderId: Int?
    var imageUrl: String?
    var shareImageUrl: String?
    var actionType: String?
    var name: String?
    var filterContent: String?
    var retailSaleLabel: String?
    var retailSaleQuantity: String?
    var originalPrice: String?
    var newPrice: String?
    var title: String?
    var startTimeStamp: Double?
    var endTimeStamp: Double?
    var isInProgress: Bool?
    var returnUrl: String?
    var captionForInstagram: String?
    var captionForFacebook: String?
    
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        sliderId <- map["sliderId"]
        imageUrl <- map["imageUrl"]
        shareImageUrl <- map["shareImageUrl"]
        actionType <- map["actionType"]
        name <- map["name"]
        filterContent <- map["filterContent"]
        retailSaleLabel <- map["retailSaleLabel"]
        retailSaleQuantity <- map["retailSaleQuantity"]
        originalPrice <- map["originalPrice"]
        newPrice <- map["newPrice"]
        title <- map["title"]
        startTimeStamp <- map["startTimeStamp"]
        endTimeStamp <- map["endTimeStamp"]
        isInProgress <- map["isInProgress"]
        returnUrl <- map["returnUrl"]
        captionForInstagram <- map["captionForInstagram"]
        captionForFacebook <- map["captionForFacebook"]
    }
}
