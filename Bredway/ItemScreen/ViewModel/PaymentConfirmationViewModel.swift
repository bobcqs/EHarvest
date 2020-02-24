//
//  PaymentConfirmationViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 7/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import RxSwift

protocol PaymentConfirmationViewModeling {
    var request: PayPalRequest {get}
    var response: PayPalResponse {get}
    var item: Item {get}
    var confirmationDidTap: PublishSubject<Void>{get}
    var submissionResult: Observable<PayPalQueryResult>{get}
}

class PaymentConfirmationViewModel: PaymentConfirmationViewModeling{
    let request: PayPalRequest
    let response: PayPalResponse
    let item: Item
    let confirmationDidTap: PublishSubject<Void> = PublishSubject<Void>()
    let submissionResult: Observable<PayPalQueryResult>
    
    private let disposeBag = DisposeBag()
    
    init(item: Item, payPalRequest: PayPalRequest, payPalResponse: PayPalResponse, payPalService: PayPalServicing, firebaseService: FirebaseServicing){
        request = payPalRequest
        response = payPalResponse
        self.item = item
        
         submissionResult = confirmationDidTap
            .throttle(2, scheduler: MainScheduler.instance)
            .flatMapLatest { _ -> Observable<FirebaseQueryResult> in
                
                //shipping address
                let shipToName = payPalResponse.shipToName ??  ""
                let shipToStreet = payPalResponse.shipToStreet ?? ""
                let shipToCity = payPalResponse.shipToCity ?? ""
                let shipToState = payPalResponse.shipToState ?? ""
                let shipToZip = payPalResponse.shipToZip ?? ""
                let shipToCountry = payPalResponse.countryCode ?? ""
                let finalAddress = shipToStreet + " " + shipToCity + " " + shipToState.uppercased() + " " + shipToCountry.uppercased() + ", " + shipToZip
                
                 return firebaseService.savePaidItem(item: item, buyerName: shipToName, buyerAddress: finalAddress)
            }
            .flatMap{ firebaseResult -> Observable<PayPalQueryResult> in
                if firebaseResult == FirebaseQueryResult.error{
                    return Observable.just(PayPalQueryResult.error)
                } else {
                    let doRequest = PayPalRequest()
                    doRequest.user = payPalRequest.user
                    doRequest.pwd = payPalRequest.pwd
                    doRequest.signature = payPalRequest.signature
                    doRequest.method = PayPalRequestMethod.doExpressCheckoutPayment.rawValue
                    doRequest.version = payPalRequest.version
                    doRequest.token = payPalRequest.token
                    doRequest.PAYERID = payPalResponse.payerId
                    doRequest.paymentRequest_0_amt = payPalRequest.paymentRequest_0_amt
                    doRequest.paymentRequest_0_currencyCode = payPalRequest.paymentRequest_0_currencyCode
                    doRequest.paymentRequest_0_sellerPayPalAccountId = payPalRequest.paymentRequest_0_sellerPayPalAccountId
                    doRequest.paymentRequest_0_paymentRequestId = payPalRequest.paymentRequest_0_paymentRequestId
                    doRequest.paymentRequest_1_amt = payPalRequest.paymentRequest_1_amt
                    doRequest.paymentRequest_1_currencyCode = payPalRequest.paymentRequest_1_currencyCode
                    doRequest.paymentRequest_1_sellerPayPalAccountId = payPalRequest.paymentRequest_1_sellerPayPalAccountId
                    doRequest.paymentRequest_1_paymentRequestId = payPalRequest.paymentRequest_1_paymentRequestId
                    return payPalService.doExpressCheckout(request: doRequest)
                }
            }
    }
}
