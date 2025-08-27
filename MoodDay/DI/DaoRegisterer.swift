//
//  DaoRegisterer.swift
//  PlantIdentification
//
//  Created by thanhvu on 6/30/20.
//  Copyright © 2020 Solar. All rights reserved.
//

import Foundation
import Swinject

class DaoRegisterer {
    static func registerDependencyForDaos(container: Container) {
        registerObjectDao(container)
    }
    
    static func registerObjectDao(_ container: Container) {
        
    }
}
