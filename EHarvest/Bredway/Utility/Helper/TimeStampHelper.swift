//
//  timeStampHelper.swift
//  Bredway
//
//  Created by Xudong Chen on 16/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation

class TimeStampHelper{
    
    static let shared = TimeStampHelper()
    
    func getTime(timeStamp: Int)-> String{
        let currentTime = Int(Date().timeIntervalSince1970)
        let secDifference = currentTime - timeStamp
        let minDifference = Int(secDifference / 60)
        let hourDifference = Int(secDifference / 3600)
        let dayDifference = Int(secDifference / (3600 * 24))
        
        if minDifference < 60 {
            return ("\(minDifference) MINS AGO")
        } else if (hourDifference < 24){
            return ("\(hourDifference) HOURS AGO")
        } else {
            return ("\(dayDifference) DAYS AGO")
        }
    }
    
    func getMinuteDifference(timeStamp: Int)-> Int{
        let currentTime = Int(Date().timeIntervalSince1970)
        let secDifference = currentTime - timeStamp
        let minDifference = Int(secDifference / 60)
        
        return minDifference
    }
    
}
