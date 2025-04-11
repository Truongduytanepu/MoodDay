//
//  ConsoleLogEngine.swift
//  PlantIdentification
//
//  Created by Thanh Vu on 25/11/2020.
//

import Foundation

class ConsoleLogEngine: LoggingEngine {
    func log(_ format: String, _ args: CVarArg...) {
        NSLog(format, args)
    }
}
