//
//  UpdateShipmentViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 1/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift

protocol UpdateShipmentViewModeling {

    var courierCompany: PublishSubject<String> {get}
    var trackingNumber: PublishSubject<String> {get}
    var updateButtonDidPress: PublishSubject<Void> {get}
    var submissionResult: PublishSubject<SubmissionResult> {get}
    
    var buyerName: String {get}
    var buyerAddress: String {get}
}

class UpdateShipmentViewModel: UpdateShipmentViewModeling{

    let courierCompany: PublishSubject<String> = PublishSubject<String>()
    let trackingNumber: PublishSubject<String> = PublishSubject<String>()
    let updateButtonDidPress: PublishSubject<Void> = PublishSubject<Void>()
    let submissionResult: PublishSubject<SubmissionResult> = PublishSubject<SubmissionResult>()
    let buyerName: String
    let buyerAddress: String
    
    private let disposeBag = DisposeBag()
    init(item: SoldItem, firebaseService: FirebaseServicing) {
        buyerName = item.buyerName ?? ""
        buyerAddress = item.buyerAddress ?? ""
        
        let textfieldInfo = Observable.combineLatest(courierCompany, trackingNumber){(
            company: String, trackingNum: String) in
                return (company, trackingNum)
        }
        
        updateButtonDidPress
            .throttle(2, scheduler: MainScheduler.instance)
            .withLatestFrom(textfieldInfo)
            .flatMapLatest({ textfieldInfo -> Observable<SubmissionResult> in
                let companyInput = textfieldInfo.0
                let trackingNumberInput = textfieldInfo.1
                
                if !companyInput.isEmpty || !trackingNumberInput.isEmpty {
                    return firebaseService.updateShipment(soldItemId: item.itemId ?? "", buyerId: item.buyerId ?? "", courierCompany: companyInput, trackingNumber: trackingNumberInput)
                } else {
                    return Observable.just(SubmissionResult.invalidInput)
                }
            })
            .bind(to: submissionResult)
            .disposed(by: disposeBag)
        
    }
    
    
}
