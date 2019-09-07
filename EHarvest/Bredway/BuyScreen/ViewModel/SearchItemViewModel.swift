//
//  SearchItemViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 29/7/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift

protocol SearchItemViewModeling {
    var searchTextList: PublishSubject<[String]> { get }
    var searchText: PublishSubject<String>{get}
    var beginSearch: PublishSubject<Void> {get}
    var showFilteredItemView: Observable<FilteredItemViewModeling>{get}
}

class SearchItemViewModel: SearchItemViewModeling{
    let searchTextList: PublishSubject<[String]> = PublishSubject<[String]>()
    let searchText: PublishSubject<String> = PublishSubject<String>()
    let beginSearch: PublishSubject<Void> = PublishSubject<Void>()
    let showFilteredItemView: Observable<FilteredItemViewModeling>
    
    init(firebaseService: FirebaseServicing, algoliaService: AlgoliaSearchServicing){
        
        showFilteredItemView = beginSearch
            .withLatestFrom(searchText){ _, text in
                (text)
            }
            .map({ (searchText) -> FilteredItemViewModeling in
                let filteredItemViewModel = FilteredItemViewModel.init(algoliaService: algoliaService, firebaseService: firebaseService, filterType: ItemFilterType.lightSearch, filterQuery: searchText)
                return filteredItemViewModel
            })
        
        UserManager.shared.getLatestSearchList { [weak self] (result, searchList) in
            if result == FirebaseQueryResult.error{
                logger.debug("The search list returned from backend has error)")
            } else {
                //user locale storage
                if let newList = self?.computeSearchList(localList: UserManager.shared.currentUserSearchHistory, newList: searchList){
                    UserManager.shared.currentUserSearchHistory = Array(newList[0...3])
                    self?.searchTextList.onNext(newList)
                }
            }
        }

        
    }
    
    func computeSearchList(localList: [String], newList: [String])-> [String]{
        var computedList = localList
        
        if localList.isEmpty{
            computedList = newList
        }
        
        for localItem in localList{
            for newItem in newList{
                if localItem != newItem{
                    computedList.append(newItem)
                }
            }
        }
        
        var result = [String]()
        if computedList.count > 7{
            for i in 0...7{
                result.append(computedList[i])
            }
        }

        return result
    }
}
