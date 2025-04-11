//
//  NSMutableData.swift
//  PlantIdentification
//
//  Created by Manh Nguyen Ngoc on 05/04/2021.
//

import Foundation

extension NSMutableData {

    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
