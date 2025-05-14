//
//  InterstitialHelper.swift
//  RenaissanceMouthEye
//
//  Created by Linh Nguyen Duc on 01/02/2023.
//

import Foundation
import GoogleMobileAds
import FirebaseRemoteConfig

class InterstitialHelper {
    static func makeCollapsibleBannerRequest() -> Request {
        let request = Request()
        let extras = Extras()
        extras.additionalParameters = ["collapsible": "bottom"]
        request.register(extras)
        return request
    }
    
    static func makeBannerRequest() -> Request {
        let request = Request()
        return request
    }
    
    func loadAds(processingBlock: @escaping () -> Void) {
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.keyIsOnInter) { isOn in
            if !isOn {
                processingBlock()
                return
            } else {
                InterstitialAdManager.shared.loadAd {
                    processingBlock()
                }
            }
        }
    }
    
    func showAdsNow(viewController: UIViewController, processingBlock: @escaping () -> Void) {
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.keyIsOnInter) { isOn in
            if !isOn {
                processingBlock()
                return
            } else {
                InterstitialAdManager.shared.showAd(from: viewController) {
                    processingBlock()
                }
            }
        }
    }
}
