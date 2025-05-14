//
//  RemoteConfigHelper.swift
//  TextRepeater
//
//  Created by Manh Nguyen Ngoc on 22/1/25.
//

import UIKit
import FirebaseRemoteConfig

class RemoteConfigHelper {
    static var shared = RemoteConfigHelper()
    
    func getRemoteConfigWithKey(key: String, completion: ((Bool) -> Void)?) {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.fetchAndActivate { status, error in
            if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                completion?(RemoteConfig.remoteConfig()[key].boolValue)
            } else {
                completion?(true)
            }
        }
    }
    
    func getRemoteConfigWithTimeCapping(key: String, completion: ((Double) -> Void)?) {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.fetchAndActivate { status, error in
            if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                completion?(RemoteConfig.remoteConfig()[key].numberValue.doubleValue)
            } else {
                completion?(20)
            }
        }
    }
}
