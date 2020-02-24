//
//  GiveAwayViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 3/10/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol GiveAwayViewModeling {
    var sliders: Driver<[RetailSlider]> {get}
    var firebaseService: FirebaseServicing {get}
    
    
}

class GiveAwayViewModel: GiveAwayViewModeling{
    let sliders: Driver<[RetailSlider]>
    let firebaseService: FirebaseServicing
    private let disposeBag = DisposeBag()
    
    init(firebaseService: FirebaseServicing) {
        self.firebaseService = firebaseService
        
        sliders = firebaseService.getAllGiveAwaySliders()
            .asDriver(onErrorJustReturn: [])
        
    }
    
}
