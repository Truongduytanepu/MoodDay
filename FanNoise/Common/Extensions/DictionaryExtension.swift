//
//  DictionaryExtension.swift
//  BabyPhoto
//
//  Created by thanhvu on 7/13/20.
//  Copyright © 2020 Solar. All rights reserved.
//

import Foundation

extension Dictionary {
    func jsonString() -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]) else {
            return ""
        }
        
        return String(data: jsonData, encoding: .utf8) ?? ""
    }
}
