//
//  Logging.swift
//  PlantIdentification
//
//  Created by Thanh Vu on 25/11/2020.
//

import Foundation

protocol LoggingEngine {
    func log(_ format: String, _ args: CVarArg...)
}

final class Logging {
    private static let shared = Logging()
    private var engines: [LoggingEngine] = []
    
    static func addLogEngine(_ engine: LoggingEngine) {
        self.shared.engines.append(engine)
    }
}

extension Logging {
    static func log(_ format: String, _ args: CVarArg...) {
        self.shared.engines.forEach { (engine) in
            engine.log(format, args)
        }
    }
}
