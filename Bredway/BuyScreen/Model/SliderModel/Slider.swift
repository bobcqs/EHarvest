//
//  Slider.swift
//  Bredway
//
//  Created by Xudong Chen on 10/9/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

enum SliderType: String {
    case webUrl = "webUrl"
    case filter = "filter"
    case retailSale = "retailSale"
    case raffle = "raffle"
    case giveAway = "giveAway"
}

class Slider: Mappable {
    var sliderId: String?
    var imageUrl: String?
    var actionType: String?
    var name: String?
    var filterContent: String?
    
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        sliderId <- map["sliderId"]
        imageUrl <- map["imageUrl"]
        actionType <- map["actionType"]
        name <- map["name"]
        filterContent <- map["filterContent"]
    }
}
