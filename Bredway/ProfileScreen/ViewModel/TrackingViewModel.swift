//
//  TrackingViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 3/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift

protocol TrackingViewModeling {
    var referenceId: String {get}
    var courierCompany: String {get}
    var trackingNumber: String {get}
}

class TrackingViewModel: TrackingViewModeling{
    
    let referenceId: String
    let courierCompany: String
    let trackingNumber: String
    
    init(item: SoldItem){
        referenceId = item.referenceId ?? ""
        courierCompany = item.courierCompany ?? ""
        trackingNumber = item.courierTrackingNumber ?? ""
    }
}

