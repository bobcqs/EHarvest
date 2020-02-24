//
//  EncodableExtension.swift
//  Bredway
//
//  Created by Xudong Chen on 2/5/19.
//  Copyright © 2018 Xudong Chen. All rights reserved.
//

import Foundation

extension Encodable {
    var asDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
