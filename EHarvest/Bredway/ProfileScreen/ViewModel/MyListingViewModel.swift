//
//  MyListingViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 18/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift

protocol MyListingViewModeling {
    var items: PublishSubject<[Item]> {get}
    var firebaseService: FirebaseServicing {get}
    
    func getListingItems()
}

class MyListingViewModel: MyListingViewModeling{
    let items: PublishSubject<[Item]> = PublishSubject<[Item]>()
    let firebaseService: FirebaseServicing
    private let disposeBag = DisposeBag()
    init(firebaseService: FirebaseServicing) {
        self.firebaseService = firebaseService
        getListingItems()
    }
    
    func getListingItems(){
        firebaseService.getMyListingItems(userId: UserManager.shared.currentUserId)
            .subscribe(onNext: { [weak self] (retrievedItems) in
                self?.items.onNext(retrievedItems)
            })
            .disposed(by: disposeBag)
    }
    
}
