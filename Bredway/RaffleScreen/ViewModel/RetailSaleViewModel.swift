//
//  RetailSaleViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 19/9/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol RetailSaleViewModeling {
    var sliders: Driver<[RetailSlider]> {get}
    var firebaseService: FirebaseServicing {get}
    
}

class RetailSaleViewModel: RetailSaleViewModeling{
    let sliders: Driver<[RetailSlider]>
    let firebaseService: FirebaseServicing
    private let disposeBag = DisposeBag()
    
    init(firebaseService: FirebaseServicing) {
        self.firebaseService = firebaseService
        
        sliders = firebaseService.getAllRetailSliders()
            .asDriver(onErrorJustReturn: [])

    }
    
}
