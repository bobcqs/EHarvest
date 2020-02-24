//
//  FilterViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 3/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift

protocol FilterViewModeling {
    var currentFilter: Filter {get}
    var currentFilterDidUpdate: PublishSubject<Void>{get}
    var applyButtonDidTap: PublishSubject<Int>{get}
    var showFilteredItemView: PublishSubject<FilteredItemViewModeling>{get}
}

class FilterViewModel: FilterViewModeling{
    var currentFilter: Filter = Filter()
    let currentFilterDidUpdate: PublishSubject<Void> = PublishSubject<Void>()
    let applyButtonDidTap: PublishSubject<Int> = PublishSubject<Int>()
    let showFilteredItemView: PublishSubject<FilteredItemViewModeling> = PublishSubject<FilteredItemViewModeling>()
    
    private let disposeBag = DisposeBag()
    init(firebaseService: FirebaseServicing, algoliaService: AlgoliaSearchServicing){
        
        applyButtonDidTap
            .subscribe(onNext: { [weak self] (index) in
                let query = self?.currentFilter.mainCategories?[index].categoriesFilter
                let filteredItemViewModel = FilteredItemViewModel.init(algoliaService: algoliaService, firebaseService: firebaseService, filterType: ItemFilterType.filter, filterQuery: query ?? "")
                self?.showFilteredItemView.onNext(filteredItemViewModel) 
            })
            .disposed(by: disposeBag)
        
        UserManager.shared.getLatestFilterList { [weak self] (result, filter) in
            if result == FirebaseQueryResult.error{
                logger.debug("The search list returned from backend has error)")
            } else {
                //user locale storage
                self?.currentFilter = filter
                self?.currentFilterDidUpdate.onNext(())
            }
        }
    }
}
