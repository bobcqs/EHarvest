//
//  PurchasesViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 2/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift

protocol PurchasesViewModeling {
    var items: PublishSubject<[SoldItem]> {get}
    var firebaseService: FirebaseServicing {get}
    var selectedItem: PublishSubject<SoldItem> {get}
    var presentChatroom: Observable<ChatroomViewModeling> {get}
    
    func getPurchasedItems()
}

class PurchasesViewModel: PurchasesViewModeling{
    let items: PublishSubject<[SoldItem]> = PublishSubject<[SoldItem]>()
    let firebaseService: FirebaseServicing
    let selectedItem: PublishSubject<SoldItem> = PublishSubject<SoldItem>()
    let presentChatroom: Observable<ChatroomViewModeling>
    
    private let disposeBag = DisposeBag()
    init(firebaseService: FirebaseServicing) {
        
        presentChatroom = selectedItem
            .map({ item in
                let firebaseChatroomService = FirebaseChatroomService()
                let buddyId = item.buyerId ?? ""
                let imageUrls = item.imageUrls ?? [String]()
                let chatroomViewModel = ChatroomViewModel(firebaseChatroomService: firebaseChatroomService, buddyId: buddyId, itemImageUrl: imageUrls.count > 0 ? imageUrls[0] : "", isBuyer: true)
                return chatroomViewModel
            })
        
        self.firebaseService = firebaseService
        getPurchasedItems()
    }
    
    func getPurchasedItems(){
        firebaseService.getMyPurchasedItems(userId: UserManager.shared.currentUserId)
            .share(replay: 1)
            .subscribe(onNext: { [weak self] (retrievedItems) in
                self?.items.onNext(retrievedItems)
            })
            .disposed(by: disposeBag)
    }
    
}

