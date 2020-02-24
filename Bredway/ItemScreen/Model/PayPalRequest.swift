//
//  PayPalRequest.swift
//  Bredway
//
//  Created by Xudong Chen on 27/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import ObjectMapper

enum PayPalRequestMethod: String{
    case setExpressCheckout = "SetExpressCheckout"
    case getExpressCheckoutDetails = "GetExpressCheckoutDetails"
    case doExpressCheckoutPayment = "DoExpressCheckoutPayment"
}

class PayPalRequest: Mappable {
    var user: String?
    var pwd: String?
    var signature: String?
    var method: String?
    var version: String?
    var token: String?
    var returnUrl: String?
    var cancelUrl: String?
    var PAYERID: String?
    
    var paymentrequest_0_paymentaction: String?
    var paymentRequest_0_amt: String?
    var paymentRequest_0_currencyCode: String?
    var paymentRequest_0_sellerPayPalAccountId: String?
    var paymentRequest_0_desc: String?
    var paymentRequest_0_paymentRequestId: String?
    var paymentRequest_0_itemAmt: String?
    var paymentRequest_0_shippingAmt: String?
    var paymentRequest_0_insuranceAmt: String?
    var paymentRequest_0_shipDiscAmt: String?
    var paymentRequest_0_handlingAmt: String?
    var paymentRequest_0_taxAmt: String?

    var L_PAYMENTREQUEST_0_NAME0: String?
    var L_PAYMENTREQUEST_0_DESC0: String?
    var L_PAYMENTREQUEST_0_AMT0: String?
    var L_PAYMENTREQUEST_0_QTY0: String?
    var L_PAYMENTREQUEST_0_NUMBER0: String?
//    var L_PAYMENTREQUEST_0_AMT0: String?
    
    var paymentRequest_1_paymentAction: String?
    var paymentRequest_1_amt: String?
    var paymentRequest_1_currencyCode: String?
    var paymentRequest_1_sellerPayPalAccountId: String?
    var paymentRequest_1_desc: String?
    var paymentRequest_1_paymentRequestId: String?
    var paymentRequest_1_itemAmt: String?
    var paymentRequest_1_shippingAmt: String?
    var paymentRequest_1_insuranceAmt: String?
    var paymentRequest_1_shipDiscAmt: String?
    var paymentRequest_1_handlingAmt: String?
    var paymentRequest_1_taxAmt: String?
    
    var L_PAYMENTREQUEST_1_NAME0: String?
    var L_PAYMENTREQUEST_1_DESC0: String?
    var L_PAYMENTREQUEST_1_AMT0: String?
    var L_PAYMENTREQUEST_1_QTY0: String?
    var L_PAYMENTREQUEST_1_NUMBER0: String?
//    var l_paymentRequest_1_atm0: String?

    //shipping
    var paymentRequest_0_shipToName: String?
    var paymentRequest_0_shipToStreet: String?
    var paymentRequest_0_shipToCity: String?
    var paymentRequest_0_shipToState: String?
    var paymentRequest_0_shipToZip: String?
    var paymentRequest_0_shipToCountryCode: String?
    
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        user <- map["user"]
        pwd <- map["pwd"]
        signature <- map["signature"]
        method <- map["method"]
        version <- map["version"]
        token <- map["token"]
        returnUrl <- map["returnUrl"]
        cancelUrl <- map["cancelUrl"]
        PAYERID <- map["PAYERID"]
        paymentrequest_0_paymentaction <- map["paymentrequest_0_paymentaction"]
        paymentRequest_0_amt <- map["paymentrequest_0_amt"]
        paymentRequest_0_currencyCode <- map["paymentRequest_0_currencyCode"]
        paymentRequest_0_sellerPayPalAccountId <- map["paymentRequest_0_sellerPayPalAccountId"]
        paymentRequest_0_desc <- map["paymentRequest_0_desc"]
        paymentRequest_0_paymentRequestId <- map["paymentRequest_0_paymentRequestId"]
        paymentRequest_0_itemAmt <- map["paymentRequest_0_itemAmt"]
        paymentRequest_0_shippingAmt <- map["paymentRequest_0_shippingAmt"]
        paymentRequest_0_insuranceAmt <- map["paymentRequest_0_insuranceAmt"]
        paymentRequest_0_shipDiscAmt <- map["paymentRequest_0_shipDiscAmt"]
        paymentRequest_0_handlingAmt <- map["paymentRequest_0_handlingAmt"]
        paymentRequest_0_taxAmt <- map["paymentRequest_0_taxAmt"]
        
        L_PAYMENTREQUEST_0_NAME0 <- map["L_PAYMENTREQUEST_0_NAME0"]
        L_PAYMENTREQUEST_0_DESC0 <- map["L_PAYMENTREQUEST_0_DESC0"]
        L_PAYMENTREQUEST_0_AMT0 <- map["L_PAYMENTREQUEST_0_AMT0"]
        L_PAYMENTREQUEST_0_QTY0 <- map["L_PAYMENTREQUEST_0_QTY0"]
        L_PAYMENTREQUEST_0_NUMBER0 <- map["L_PAYMENTREQUEST_0_NUMBER0"]
     //   L_PAYMENTREQUEST_0_AMT0 <- map["L_PAYMENTREQUEST_0_AMT0"]
        
        paymentRequest_1_paymentAction <- map["paymentRequest_1_paymentAction"]
        paymentRequest_1_amt <- map["paymentRequest_1_amt"]
        paymentRequest_1_currencyCode <- map["paymentRequest_1_currencyCode"]
        paymentRequest_1_sellerPayPalAccountId <- map["paymentRequest_1_sellerPayPalAccountId"]
        paymentRequest_1_desc <- map["paymentRequest_1_desc"]
        paymentRequest_1_paymentRequestId <- map["paymentRequest_1_paymentRequestId"]
        paymentRequest_1_itemAmt <- map["paymentRequest_1_itemAmt"]
        paymentRequest_1_shippingAmt <- map["paymentRequest_1_shippingAmt"]
        paymentRequest_1_insuranceAmt <- map["paymentRequest_1_insuranceAmt"]
        paymentRequest_1_shipDiscAmt <- map["paymentRequest_1_shipDiscAmt"]
        paymentRequest_1_handlingAmt <- map["paymentRequest_1_handlingAmt"]
        paymentRequest_1_taxAmt <- map["paymentRequest_1_taxAmt"]
        
        L_PAYMENTREQUEST_1_NAME0 <- map["L_PAYMENTREQUEST_1_NAME0"]
        L_PAYMENTREQUEST_1_DESC0 <- map["L_PAYMENTREQUEST_1_DESC0"]
        L_PAYMENTREQUEST_1_AMT0 <- map["L_PAYMENTREQUEST_1_AMT0"]
        L_PAYMENTREQUEST_1_QTY0 <- map["L_PAYMENTREQUEST_1_QTY0"]
        L_PAYMENTREQUEST_1_NUMBER0 <- map["L_PAYMENTREQUEST_1_NUMBER0"]
   //     l_paymentRequest_1_atm0 <- map["l_paymentRequest_1_atm0"]
        
        paymentRequest_0_shipToName <- map["paymentRequest_0_shipToName"]
        paymentRequest_0_shipToStreet <- map["paymentRequest_0_shipToStreet"]
        paymentRequest_0_shipToCity <- map["paymentRequest_0_shipToCity"]
        paymentRequest_0_shipToState <- map["paymentRequest_0_shipToState"]
        paymentRequest_0_shipToZip <- map["paymentRequest_0_shipToZip"]
        paymentRequest_0_shipToCountryCode <- map["paymentRequest_0_shipToCountryCode"]
    }
    
    var isInputValid: Bool {
        guard let shipToName = paymentRequest_0_shipToName, !shipToName.isEmpty else {
            return false
        }
        
        guard let shipToStreet = paymentRequest_0_shipToStreet, !shipToStreet.isEmpty else {
            return false
        }
        
        guard let shipToCity = paymentRequest_0_shipToCity, !shipToCity.isEmpty else {
            return false
        }
        
        guard let shipToState = paymentRequest_0_shipToState, !shipToState.isEmpty else {
            return false
        }
        
        guard let shipToZip = paymentRequest_0_shipToZip, !shipToZip.isEmpty else {
            return false
        }
        
        guard let shipToCountryCode = paymentRequest_0_shipToCountryCode, !shipToCountryCode.isEmpty else {
            return false
        }
        
        return true
    }

}
