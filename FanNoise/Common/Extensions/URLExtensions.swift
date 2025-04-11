//
//  URLExtensions.swift
//  BabyPhoto
//
//  Created by Thanh Vu on 6/24/20.
//  Copyright © 2020 Solar. All rights reserved.
//

import Foundation

extension URL {
    var params: [String:Any] {
        guard let query = self.query else { return [:] }
        let paramsComponent = query.components(separatedBy: "&")

        var paramsResult = [String:Any]()
        paramsComponent.forEach { (item) in
            let components = item.components(separatedBy: "=")
            let key = components[0]
            let value = components[1]

            paramsResult[key] = value
        }

        return paramsResult
    }
    
    var creationDate: Date? {
        return (try? resourceValues(forKeys: [.creationDateKey]))?.creationDate
    }
}
