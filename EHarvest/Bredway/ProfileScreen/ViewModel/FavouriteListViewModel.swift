//
//  FavouriteListViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 25/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift

protocol FavouriteListViewModeling {
    var items: BehaviorSubject<[Item]> { get }
    var firebaseService: FirebaseServicing {get}
    //Input
    var likedItemIndex: PublishSubject<Int> {get}
    var updateListSuccess: PublishSubject<FirebaseQueryResult> {get}
    
    func getFavouriteItems()
}

class FavouriteListViewModel: FavouriteListViewModeling{
    let firebaseService: FirebaseServicing
    
    let items: BehaviorSubject<[Item]> = BehaviorSubject<[Item]>(value: [])
    let likedItemIndex: PublishSubject<Int> = PublishSubject<Int>()
    let updateListSuccess: PublishSubject<FirebaseQueryResult> = PublishSubject<FirebaseQueryResult>()
    
    private let disposeBag = DisposeBag()
    
    init(firebaseService: FirebaseServicing) {
        self.firebaseService = firebaseService
        
        likedItemIndex
            .withLatestFrom(items) { index, items in
                (index, items)
            }
            .flatMap { (index, items) -> Observable<(FirebaseQueryResult, [String: Bool])> in
                let item = items[index]
                let favouriteList = UserManager.shared.currentUserFavouriteList
                if let itemId = item.itemId{
                    if UserManager.shared.isFavouriteItem(itemId: itemId){
                        return firebaseService.removeItemFromFavouriteList(itemId: itemId, submitData: favouriteList)
                    } else {
                        return firebaseService.addItemToFavouriteList(itemId: itemId, submitData: favouriteList)
                    }
                }
                return Observable.just((FirebaseQueryResult.error, favouriteList))
            }
            .subscribe(onNext: { [weak self] (result, list) in
                UserManager.shared.currentUserFavouriteList = list
                self?.updateListSuccess.onNext(result)
            })
            .disposed(by: disposeBag)
    }
    
    func getFavouriteItems() {
        let emptyItemList = [Item]()
        self.items.onNext(emptyItemList)
        
        let itemsList = [String] (UserManager.shared.currentUserFavouriteList.keys)
        firebaseService.getItemsFromList(list: itemsList)
            .withLatestFrom(items) { (data, itemArray) in
                return (data, itemArray)
            }
            .subscribe(onNext: { [weak self] (data, itemArray) in
                let (result, newItem) = data
                var itemList = itemArray
                if result == FirebaseQueryResult.error{
                    logger.debug("Failed to retrieve favourite item, the item may not exist")
                } else {
                    itemList.append(newItem)
                    self?.items.onNext(itemList)
                }
            })
            .disposed(by: disposeBag)
    }
    
}
