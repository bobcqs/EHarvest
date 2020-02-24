//
//  DoubleExtension.swift
//  Bredway
//
//  Created by Xudong Chen on 5/8/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
