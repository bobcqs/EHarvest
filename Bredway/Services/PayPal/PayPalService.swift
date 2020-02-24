//
//  PayPalService.swift
//  Bredway
//
//  Created by Xudong Chen on 27/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import RxSwift
import Firebase
import Alamofire

protocol PayPalServicing {
    //get info, setExpresscheckout, get, do
    func getPayPalKey() -> Observable<FirebaseQueryResult>
    func performPayment(request: PayPalRequest, item: Item, sellerEmail: String) -> Observable<(PayPalQueryResult, String, PayPalRequest)>
    func setExpresscheckout(request: PayPalRequest, item: Item, sellerEmail: String) -> Observable<(PayPalQueryResult, PayPalRequest)>
    func getExpressCheckout(request:PayPalRequest, originalRequest: PayPalRequest) -> Observable<(PayPalQueryResult, PayPalResponse, PayPalRequest)>
    func doExpressCheckout(request: PayPalRequest) -> Observable<PayPalQueryResult>
}

class PayPalService: PayPalServicing {
    
    private let firestoreDb = Firestore.firestore()
    private var user: String?
    private var pwd: String?
    private var signature: String?
    private var version: String?
    private var token: String?
    private var mainEmail: String?
    private var comissionRate: Double?
    private var payPalRate: Double?
    private var url: String?
    private var webViewUrl: String?
    private let disposeBag = DisposeBag()
    
    private let network: NetworkServicing
    
    init(network: NetworkServicing) {
        self.network = network
    }

    func getPayPalKey() -> Observable<FirebaseQueryResult>{
        return Observable.create { observer in
            let keyRef = self.firestoreDb.collection(FilePath.FIREBASE_PAYPAL_ACCOUNT).document(FilePath.FIREBASE_PRODUCTION_PAYPAL_API_KEY)
            keyRef.getDocument(completion: { (document, error) in
                if let err = error {
                    logger.debug("Failed to fetch PayPal API Key from database and error is \(err)")
                    observer.onNext(FirebaseQueryResult.error)
                } else {
                    if let apiData = document?.data(){
                        if let apiVersion = apiData["version"]{
                            self.version = apiVersion as? String
                        }
                        if let apiPwd = apiData["pwd"]{
                            self.pwd = apiPwd as? String
                        }
                        if let apiUser = apiData["user"]{
                            self.user = apiUser as? String
                        }
                        if let apiSignature = apiData["signature"]{
                            self.signature = apiSignature as? String
                        }
                        if let apiComissionRate = apiData["comissionRate"]{
                            self.comissionRate = apiComissionRate as? Double
                        }
                        if let apiPayPalRate = apiData["payPalRate"]{
                            self.payPalRate = apiPayPalRate as? Double
                        }
                        if let apiMainEmail = apiData["mainEmail"]{
                            self.mainEmail = apiMainEmail as? String
                        }
                        if let apiUrl = apiData["url"]{
                            self.url = apiUrl as? String
                        }
                        if let apiWebViewUrl = apiData["webViewUrl"]{
                            self.webViewUrl = apiWebViewUrl as? String
                        }
                    }
                    observer.onNext(FirebaseQueryResult.success)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    func setExpresscheckout(request: PayPalRequest, item: Item, sellerEmail: String) -> Observable<(PayPalQueryResult, PayPalRequest)> {
        return Observable.create { observer in
            if let username = self.user{
                request.user = username
            }
            if let password = self.pwd{
                request.pwd = password
            }
            if let version = self.version{
                request.version = version
            }
            if let signature = self.signature{
                request.signature = signature
            }
            
            //price calculation
            let rate = self.comissionRate ?? 5
            let payPayProcessRate = self.payPalRate ?? 2.6
            var totalPrice = Double(item.price ?? 0)
            if totalPrice == 0 {
                observer.onNext((PayPalQueryResult.error, request))
                observer.onCompleted()
            }
            totalPrice += 5
            let sellerShouldReceiveAmount = totalPrice * ((100 - rate) / 100)
            let shouldSendToSellerAmount = (sellerShouldReceiveAmount + 0.3) / ((100 - payPayProcessRate) / 100) //2.6 % is Paypal Fee
            //let shouldFormatAmount = shouldSendToSellerAmount.truncate(places: 2)
            //var sellerAmount = shouldSendToSellerAmount.rounded(.up)
            var sellerAmount = (shouldSendToSellerAmount * 100).rounded() / 100
            var comissionAmount = totalPrice - sellerAmount
            if comissionAmount < 1 {
                comissionAmount = 1
                sellerAmount = totalPrice - comissionAmount
            }

            let formatString = "%.2f"
            let formattedSellerAmount = String(format: formatString, sellerAmount)
            let formattedComissionAmount = String(format: formatString, comissionAmount)
            
            request.paymentRequest_0_amt = formattedSellerAmount
            request.paymentRequest_0_itemAmt = formattedSellerAmount
            request.L_PAYMENTREQUEST_0_AMT0 = formattedSellerAmount
            request.paymentRequest_1_amt = formattedComissionAmount
            request.paymentRequest_1_itemAmt = formattedComissionAmount
            request.L_PAYMENTREQUEST_1_AMT0 = formattedComissionAmount
            
            request.method = PayPalRequestMethod.setExpressCheckout.rawValue
            request.paymentrequest_0_paymentaction = "Order"
            request.paymentRequest_0_currencyCode = "AUD"
            request.paymentRequest_0_desc = "Payment to seller for your purchase items"
            request.paymentRequest_0_paymentRequestId = "0"
            request.L_PAYMENTREQUEST_0_NAME0 = item.name ?? ""
            request.L_PAYMENTREQUEST_0_DESC0 = "Payment to seller for your purchase items"
            request.L_PAYMENTREQUEST_0_QTY0 = "1"
            
            request.paymentRequest_1_paymentAction = "Order"
            request.paymentRequest_1_currencyCode = "AUD"
            request.paymentRequest_1_desc = "Commission to Bredway collected from Sale amount"
            request.paymentRequest_1_paymentRequestId = "1"
            request.L_PAYMENTREQUEST_1_NAME0 = "Bredway Commission"
            request.L_PAYMENTREQUEST_1_DESC0 = "Commission fee"
            request.L_PAYMENTREQUEST_1_QTY0 = "1"
            
            if !sellerEmail.isEmpty{
                request.paymentRequest_0_sellerPayPalAccountId = sellerEmail
                //To be removed
                //request.paymentRequest_0_sellerPayPalAccountId = "kaipeng.tech-facilitator4@gmail.com"
            }
            if let bredwayEmail = self.mainEmail{
                request.paymentRequest_1_sellerPayPalAccountId = bredwayEmail
            } else {
                observer.onNext((PayPalQueryResult.error, request))
                observer.onCompleted()
            }
            
            request.returnUrl = "https://www.bredway.com.au/"
            request.cancelUrl = "https://www.bredway.com.au/"
            
            let apiUrl = self.url ?? ""
            let parameters = request.toJSON()
            
            self.network.requestForStringResponse(method: .post, url: apiUrl, parameters:parameters )
                .subscribe(onNext: { [weak self] result in
                    let responseValue = PayPalResponseHelper.shared.toJSON(stringValue: result as! String)
                    if responseValue["ACK"] == "Success" {
                        if let responseToken = responseValue["TOKEN"]{
                            self?.token = responseToken
                            request.token = responseToken
                            observer.onNext((PayPalQueryResult.success, request))
                        }
                    } else {
                        observer.onNext((PayPalQueryResult.error, request))
                    }
                    observer.onCompleted()
                },
                           onError: { error in
                            observer.onNext((PayPalQueryResult.error, request))
                            observer.onCompleted()
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    func performPayment(request: PayPalRequest, item: Item, sellerEmail: String) -> Observable<(PayPalQueryResult, String, PayPalRequest)> {
        return Observable.create { observer in
            self.getPayPalKey()
                .flatMapLatest({ result -> Observable<(PayPalQueryResult, PayPalRequest)>  in
                    if result == FirebaseQueryResult.error{
                        return Observable.just((PayPalQueryResult.error, PayPalRequest()))
                    } else  {
                        return self.setExpresscheckout(request: request, item: item, sellerEmail: sellerEmail)
                    }
                })
                .subscribe(onNext: { [weak self] (result, request) in
                    if result == PayPalQueryResult.error{
                        observer.onNext((PayPalQueryResult.error, "", PayPalRequest()))
                    } else if result == PayPalQueryResult.success{
                        var finalUrl = ""
                        if let webUrl = self?.webViewUrl, let requestToken = request.token{
                            finalUrl = webUrl + requestToken
                        }
                        observer.onNext((PayPalQueryResult.success, finalUrl, request))
                    }
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    func getExpressCheckout(request: PayPalRequest,  originalRequest: PayPalRequest) -> Observable<(PayPalQueryResult, PayPalResponse, PayPalRequest)> {
        return Observable.create { observer in
            
            let apiUrl = self.url ?? ""
            let parameters = request.toJSON()
            
            self.network.requestForStringResponse(method: .post, url: apiUrl, parameters:parameters )
                .subscribe(onNext: { result in
                    let responseValue = PayPalResponseHelper.shared.toJSON(stringValue: result as! String)
                    if let payPalResponse = PayPalResponse(JSON: responseValue){
                        if responseValue["ACK"] == "Success" {
                            observer.onNext((PayPalQueryResult.success, payPalResponse, originalRequest))
                        } else {
                            observer.onNext((PayPalQueryResult.error, PayPalResponse(),PayPalRequest()))
                        }
                        observer.onCompleted()
                    } else {
                        observer.onNext((PayPalQueryResult.error, PayPalResponse(),PayPalRequest()))
                    }
                    },
                           onError: { error in
                            observer.onNext((PayPalQueryResult.error, PayPalResponse(), PayPalRequest()))
                            observer.onCompleted()
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func doExpressCheckout(request: PayPalRequest) -> Observable<PayPalQueryResult> {
        return Observable.create { observer in
            
            let apiUrl = self.url ?? ""
            let parameters = request.toJSON()
            
            self.network.requestForStringResponse(method: .post, url: apiUrl, parameters:parameters )
                .subscribe(onNext: { result in
                    let responseValue = PayPalResponseHelper.shared.toJSON(stringValue: result as! String)
                //    if let payPalResponse = PayPalResponse(JSON: responseValue){
                        if  responseValue["ACK"] == "Success" {
                            logger.debug("Successully performed doExpressCheckout payments")
                            observer.onNext(PayPalQueryResult.success)
                        } else {
                            logger.debug("Failed to perform doExpressCheckout payments")
                            observer.onNext(PayPalQueryResult.error)
                        }
                        observer.onCompleted()
//                    } else {
//                       observer.onNext(PayPalQueryResult.error)
//                    }
                },
                           onError: { error in
                            logger.debug("Failed to perform doExpressCheckout payments")
                            observer.onNext(PayPalQueryResult.error)
                            observer.onCompleted()
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
}
