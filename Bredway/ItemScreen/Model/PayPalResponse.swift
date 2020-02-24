//
//  PayPalResponse.swift
//  Bredway
//
//  Created by Xudong Chen on 4/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

class PayPalResponse: Mappable {

    var token: String?
    var timeStamp: String?
    var ack: String?
    var email: String?
    var payerId: String?
    var payerStatus: String?
    var firstname: String?
    var lastname: String?
    var countryCode: String?
    var shipToName: String?
    var shipToStreet: String?
    var shipToCity: String?
    var shipToState: String?
    var shipToZip: String?
    var paymentAmount: String?
    var commissionAmount: String?
    var itemName: String?
    
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        token <- map["TOKEN"]
        timeStamp <- map["TIMESTAMP"]
        ack <- map["ACK"]
        email <- map["EMAIL"]
        payerId <- map["PAYERID"]
        payerStatus <- map["PAYERSTATUS"]
        firstname <- map["FIRSTNAME"]
        lastname <- map["LASTNAME"]
        countryCode <- map["COUNTRYCODE"]
        shipToName <- map["SHIPTONAME"]
        shipToStreet <- map["SHIPTOSTREET"]
        shipToCity <- map["SHIPTOCITY"]
        shipToState <- map["SHIPTOSTATE"]
        shipToZip <- map["SHIPTOZIP"]
        paymentAmount <- map["PAYMENTREQUEST_0_AMT"]
        commissionAmount <- map["PAYMENTREQUEST_1_AMT"]
        itemName <- map["L_PAYMENTREQUEST_0_NAME0"]
        
    }
    
}
