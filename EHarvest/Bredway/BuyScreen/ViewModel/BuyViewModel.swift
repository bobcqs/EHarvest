//
//  BuyViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 16/3/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import RxSwift

protocol BuyViewModeling {
    var items: PublishSubject<[Item]> { get }
    var mainSlider: MainSlider { get }
    var getSliderResult: PublishSubject<FirebaseQueryResult> {get}
    
    //Input
    var pullToRefresh: PublishSubject<Void> { get }
    var refreshEnd: Observable<Bool> { get }
    var shouldStartFetch: PublishSubject<Void> {get}
    var likedItemIndex: PublishSubject<Int> {get}
    var updateListSuccess: PublishSubject<FirebaseQueryResult> {get}
}

class BuyViewModel: BuyViewModeling{
    let items: PublishSubject<[Item]> = PublishSubject<[Item]>()
    let pullToRefresh: PublishSubject<Void> = PublishSubject<Void>()
    let shouldStartFetch: PublishSubject<Void> = PublishSubject<Void>()
    let refreshEnd: Observable<Bool>
    let likedItemIndex: PublishSubject<Int> = PublishSubject<Int>()
    let updateListSuccess: PublishSubject<FirebaseQueryResult> = PublishSubject<FirebaseQueryResult>()
    var mainSlider: MainSlider = MainSlider()
    let getSliderResult: PublishSubject<FirebaseQueryResult> = PublishSubject<FirebaseQueryResult>()
    
    private let disposeBag = DisposeBag()
    
    init(firebaseService: FirebaseServicing) {
        refreshEnd = items.asObservable()
            .map({ _ in
                return true
            })

        firebaseService.getItems(paginationLimit: 8)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] allItems in
                var xx = Array(allItems.prefix(8))
                self?.items.onNext(xx)
            })
            .disposed(by: disposeBag)
        
        pullToRefresh
            .flatMapLatest({ _ in
                firebaseService.getItems(paginationLimit: 8)
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:{ [unowned self] allItems in
                var xx = Array(allItems.prefix(8))
                self.items.onNext(xx)
            })
            .disposed(by: disposeBag)
        
        shouldStartFetch
            .flatMapLatest { _ in
                firebaseService.getNextItems(paginationLimit: 8)
                .catchErrorJustReturn([])
            }
            .withLatestFrom(items){ retrievedItems, items in
                (retrievedItems, items)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (retrievedItems, items) in
                logger.debug("Items fetched from Firebase")
                self.items.onNext(items + retrievedItems)
            })
            .disposed(by: disposeBag)
        
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
        
        //Slider
        firebaseService.getSliders()
            .retry(3)
            .subscribe(onNext: { [weak self] (mainSlider) in
                self?.mainSlider = mainSlider
                self?.mainSlider.smallFilters?.shuffle()
                self?.mainSlider.brandFilters?.shuffle() //Randomise the results
                self?.mainSlider.retailSliders?.reverse()
                self?.getSliderResult.onNext(FirebaseQueryResult.success)
            }, onError: { [weak self] (error) in
                self?.getSliderResult.onNext(FirebaseQueryResult.error)
            })
            .disposed(by: disposeBag)
    }
    
}
