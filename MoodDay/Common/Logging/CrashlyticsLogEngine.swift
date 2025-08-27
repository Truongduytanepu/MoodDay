//
//  CrashlyticsLogEngine.swift
//  PlantIdentification
//
//  Created by Thanh Vu on 25/11/2020.
//

import Foundation
import FirebaseCrashlytics
class CrashlyticsLogEngine: LoggingEngine {
    func log(_ format: String, _ args: CVarArg...) {
        Crashlytics.crashlytics().log(String.init(format: format, args))
    }
}
