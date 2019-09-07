//
//  AddShippingViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 24/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//


import RxSwift

protocol PaymentViewModeling {
    var itemId: String {get}
    var sellerId: String {get}
    var name: PublishSubject<String> {get}
    var addressOne: PublishSubject<String> {get}
    var addressTwo: PublishSubject<String> {get}
    var city: PublishSubject<String> {get}
    var state: PublishSubject<String> {get}
    var countryCode: PublishSubject<String> {get}
    var postCode: PublishSubject<String> {get}
    var webUrl: PublishSubject<String> {get}
    var request: PublishSubject<PayPalRequest> {get}
    
    var payDidTap: PublishSubject<Void> {get}
    var submissionResult: PublishSubject<SubmissionResult> {get}
    var presentPayPalWebview: PublishSubject<(SubmissionResult, PayPalWebViewModeling)>{get}
    var checkOutDidFinish: PublishSubject<PayPalRequest>{get}
    var presentConfirmation: Observable<(PayPalQueryResult, PaymentConfirmationViewModeling)>{get}
}

class PaymentViewModel: PaymentViewModeling{
    let itemId: String
    let sellerId: String
    let name: PublishSubject<String> = PublishSubject<String>()
    let addressOne: PublishSubject<String> = PublishSubject<String>()
    let addressTwo: PublishSubject<String> = PublishSubject<String>()
    let city: PublishSubject<String> = PublishSubject<String>()
    let state: PublishSubject<String> = PublishSubject<String>()
    let countryCode: PublishSubject<String> = PublishSubject<String>()
    let postCode: PublishSubject<String> = PublishSubject<String>()
    let webUrl: PublishSubject<String> = PublishSubject<String>()
    let request: PublishSubject<PayPalRequest> = PublishSubject<PayPalRequest>()
    
    let payDidTap: PublishSubject<Void> = PublishSubject<Void>()
    let submissionResult: PublishSubject<SubmissionResult> = PublishSubject<SubmissionResult>()
    let presentPayPalWebview: PublishSubject<(SubmissionResult, PayPalWebViewModeling)> = PublishSubject<(SubmissionResult, PayPalWebViewModeling)>()
    let checkOutDidFinish: PublishSubject<PayPalRequest> =  PublishSubject<PayPalRequest>()
    let presentConfirmation: Observable<(PayPalQueryResult, PaymentConfirmationViewModeling)>
    
    private let disposeBag = DisposeBag()
    
    init(sellerEmail: String, item: Item, payPalService: PayPalServicing){
        itemId = item.itemId ?? ""
        sellerId = item.sellerId ?? ""
        
        let requestInfo = Observable.combineLatest(name, addressOne, addressTwo,city, state, countryCode, postCode ){
            (name: String, addressOne: String, addressTwo:String, city: String, state: String, countryCode: String, postCode: String) -> PayPalRequest in
            
            let request  = PayPalRequest()
            request.paymentRequest_0_shipToName = name
            request.paymentRequest_0_shipToStreet = addressOne + addressTwo
            request.paymentRequest_0_shipToCity = city
            request.paymentRequest_0_shipToState = state
            request.paymentRequest_0_shipToCountryCode = countryCode
            request.paymentRequest_0_shipToZip = postCode
            return request
        }
        
        presentConfirmation = checkOutDidFinish
            .flatMapLatest { originalRequest  -> Observable<(PayPalQueryResult, PayPalResponse, PayPalRequest)> in
                let getRequest = PayPalRequest()
                getRequest.user = originalRequest.user
                getRequest.pwd = originalRequest.pwd
                getRequest.signature = originalRequest.signature
                getRequest.method = PayPalRequestMethod.getExpressCheckoutDetails.rawValue
                getRequest.version = originalRequest.version
                getRequest.token = originalRequest.token
                return payPalService.getExpressCheckout(request: getRequest, originalRequest: originalRequest)
            }
            .map({ (result, response, originalRequest) -> (PayPalQueryResult, PaymentConfirmationViewModeling) in
                let firebaseService = FirebaseService()
                let paymentConfirmationViewModel = PaymentConfirmationViewModel(item: item, payPalRequest: originalRequest, payPalResponse: response, payPalService: payPalService, firebaseService: firebaseService)
                return (result, paymentConfirmationViewModel)
            })
        
        payDidTap
            .throttle(2, scheduler: MainScheduler.instance)
            .withLatestFrom(requestInfo)
            .flatMapLatest({ requestInfo -> Observable<(PayPalQueryResult, String, PayPalRequest)> in
                if requestInfo.isInputValid{
                    return payPalService.performPayment(request: requestInfo, item: item, sellerEmail: sellerEmail)
                } else {
                    return Observable.just((PayPalQueryResult.error, "", PayPalRequest()))
                }
            })
            .map({ (result, url, request) -> (SubmissionResult, PayPalWebViewModeling) in
                let finalResult: SubmissionResult
                if result == PayPalQueryResult.success{
                    finalResult = SubmissionResult.submissionSuccess
                } else {
                    finalResult = SubmissionResult.submissionError
                }
                let payPalWebViewModel = PayPalWebViewModel(url: url, payPalRequest: request, payPalService: payPalService)
                return (finalResult, payPalWebViewModel)
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (result, model) in
                self?.presentPayPalWebview.onNext((result, model))
            })
            .disposed(by: disposeBag)
        
    }
}
