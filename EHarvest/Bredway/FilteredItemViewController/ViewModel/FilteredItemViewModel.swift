//
//  FilteredItemViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 31/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift

enum ItemFilterType{
    case lightSearch
    case filter
}

protocol FilteredItemViewModeling {
    var items: PublishSubject<[Item]> { get }
    var filterType: PublishSubject<ItemFilterType> {get}
    var likedItemIndex: PublishSubject<Int> {get}
    var updateListSuccess: PublishSubject<FirebaseQueryResult> {get}
    //Input
}

class FilteredItemViewModel: FilteredItemViewModeling{
    let items: PublishSubject<[Item]> = PublishSubject<[Item]>()
    var filterType: PublishSubject<ItemFilterType> = PublishSubject<ItemFilterType>()
    let likedItemIndex: PublishSubject<Int> = PublishSubject<Int>()
    let updateListSuccess: PublishSubject<FirebaseQueryResult> = PublishSubject<FirebaseQueryResult>()
    
    private let disposeBag = DisposeBag()
    
    init(algoliaService: AlgoliaSearchServicing, firebaseService: FirebaseServicing, filterType: ItemFilterType, filterQuery: String) {
        self.filterType
            .flatMap { (type) -> Observable<[Item]> in
                switch type{
                case .filter:
                    return algoliaService.filterSearch(filterText: filterQuery)
                case .lightSearch:
                    return algoliaService.lightSearch(searchText: filterQuery)
                }
            }.subscribe(onNext: { [weak self] (allItems) in
                self?.items.onNext(allItems)
            }, onError: { (error) in
                
            })
            .disposed(by: disposeBag)
        
        self.filterType.onNext(filterType)
        
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
}
