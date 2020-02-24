//
//  MainSlider.swift
//  Bredway
//
//  Created by Xudong Chen on 11/9/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

class MainSlider: Mappable {
    var sliders: [Slider]?
    var smallFilterCount: Int?
    var smallFilters: [Slider]?
    var brandFilters: [Slider]?
    var retailSliders: [RetailSlider]?
    var giveAwaySliders: [RetailSlider]?
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        sliders <- map["slider"]
        smallFilterCount <- map["smallFilterCount"]
        smallFilters <- map["smallFilter"]
        brandFilters <- map["brandFilter"]
        retailSliders <- map["retailSliders"]
        giveAwaySliders <- map["giveAwaySliders"]
    }
}
