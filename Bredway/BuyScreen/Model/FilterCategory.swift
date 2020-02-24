//
//  FilterCategory.swift
//  Bredway
//
//  Created by Xudong Chen on 1/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

class FilterCategory: Mappable {
    var name: String?
    var subCategories: [FilterSubCategory]?
    var subCategoriesFilter: String {
        get {
           // query.filters = "price > 10 AND (brand: 'Jordan Brand' OR brand: 'Nike')"
           // query.filters = "code=1 AND (price:1000 TO 3000 OR price:10 TO 100)"
            let selectedArray = subCategories?.map({ (subCategory) -> String in
                if let selected = subCategory.isSelected, let subCategoryName = subCategory.name, let name = self.name, selected == true {
                    if let isRangeFilter = subCategory.isRangeFilter, let lowerValue = subCategory.lowerRangeValue, let higherValue = subCategory.higherRangeValue, isRangeFilter == true{
                        return name + ":" + String(lowerValue) + " TO " + String(higherValue)
                    } else {
                       return name + ": '" + subCategoryName + "'"
                    }
                }
                return ""
            })
            let noEmptyStringArray = selectedArray?.filter{$0 != ""}
            let selectedString = noEmptyStringArray?.joined(separator: " OR ")
            var result = ""
            if let finalString = selectedString {
                result = "(" + finalString + ")"
            }
            return result
        }
    }
    
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        subCategories <- map["subCategories"]
    }
}
