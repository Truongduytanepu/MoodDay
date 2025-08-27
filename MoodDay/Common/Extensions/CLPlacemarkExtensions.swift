//
//  CLPlacemarkExtensions.swift
//  BabyPhoto
//
//  Created by Thanh Vu on 8/12/20.
//  Copyright © 2020 Solar. All rights reserved.
//

import Foundation
import CoreLocation

extension CLPlacemark {
    func friendlyAddress() -> String {
        var components = [String]()
        
        if let name = self.name {
            components.append(name)
        }
        
        if let subLocality = self.subLocality {
            components.append(subLocality)
        }
        
        if let locality = self.locality {
            components.append(locality)
        }
        
        if let country = self.country {
            components.append(country)
        }
        
        return components.joined(separator: ", ")
    }
}
