//
//  FilterSubCategory.swift
//  Bredway
//
//  Created by Xudong Chen on 1/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

class FilterSubCategory: Mappable {
    var name: String?
    var isSelected: Bool?
    var isRangeFilter: Bool?
    var lowerRangeValue: Int?
    var higherRangeValue: Int?
    
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        isRangeFilter <- map["isRangeFilter"]
    }
}


