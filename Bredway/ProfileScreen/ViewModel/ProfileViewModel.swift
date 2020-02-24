//
//  ProfileViewModel.swift
//  Bredway
//
//  Created by Xudong Chen on 17/6/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation
import RxSwift

enum ProfileOption: String {
    case myListing = "My Listing"
    case soldItems = "Sold Items"
    case purchases = "Purchases"
    case favourites = "Favourites"
    case contactUs = "Contact Us"
    case settings = "Settings"
}

protocol ProfileViewModeling {
    var profileOptions: Observable<[ProfileOption]> {get}
}

class ProfileViewModel: ProfileViewModeling{
    
    let profileOptions: Observable<[ProfileOption]>
    
    init(firebaseService: FirebaseServicing){
        let optionArray = [ProfileOption.myListing, ProfileOption.soldItems, ProfileOption.purchases, ProfileOption.favourites, ProfileOption.contactUs, ProfileOption.settings]
        profileOptions = Observable.just(optionArray)

    }
    
}
