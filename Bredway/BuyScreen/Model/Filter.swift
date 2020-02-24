//
//  Filter.swift
//  Bredway
//
//  Created by Xudong Chen on 1/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

class Filter: Mappable {
    var mainCategories: [FilterMainCategory]?
    var name: String?
    
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        mainCategories <- map["mainCategories"]
        name <- map["name"]
    }
    
    func clearAllFilter(){
        if let mainCategories = mainCategories{
            for mainCategory in mainCategories{
                if let categories = mainCategory.categories{
                    for category in categories{
                        if let subCategories = category.subCategories{
                            for subCategory in subCategories{
                                subCategory.isSelected = false
                            }
                        }
                    }
                }
            }
        }
    }
}
