//
//  FilterValue.swift
//  Bredway
//
//  Created by Xudong Chen on 2/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

class FilterMainCategory: Mappable {
    var name: String?
    var categories: [FilterCategory]?
    var categoriesFilter: String {
        get {
            // query.filters = "price > 10 AND (brand: 'Jordan Brand' OR brand: 'Nike')"
            // query.filters = "code=1 AND (price:1000 TO 3000 OR price:10 TO 100)"
            let selectedArray = categories?.map({ (category) -> String in
                return category.subCategoriesFilter
            })
            var selectedString = ""
            if let array = selectedArray{
                let noEmptyStringArray = array.filter{$0 != "()"}
                selectedString = noEmptyStringArray.joined(separator: " AND ")
            }
            return selectedString
        }
    }
    
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        categories <- map["categories"]
    }
}
