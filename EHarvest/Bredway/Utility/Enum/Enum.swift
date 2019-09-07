//
//  enum.swift
//  Bredway
//
//  Created by Xudong Chen on 2/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation

enum SubmissionResult {
    case invalidInput
    case submissionSuccess
    case submissionFail
    case submissionError
}

enum FirebaseQueryResult{
    case success
    case error
    case noDocument
    case unknown
}

enum PayPalQueryResult{
    case success
    case error
    case unknown
}

enum ValidationType{
    case email
    case integer
    case price
    case itemDescription
    case itemName
    case category
    case brand
    case size
    case condition
}
