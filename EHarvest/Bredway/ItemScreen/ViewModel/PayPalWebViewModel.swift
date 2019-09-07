//
//  PayPalWebViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 3/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import RxSwift

protocol PayPalWebViewModeling {
    var webUrl: String {get}
    var request: PayPalRequest {get}
}

class PayPalWebViewModel: PayPalWebViewModeling{
    let webUrl: String
    let request: PayPalRequest
    
    init(url: String, payPalRequest: PayPalRequest, payPalService: PayPalServicing){
        webUrl = url
        request = payPalRequest
    }
}
