//
//  MaxRewardedHelper.swift
//  StickmanAnimation
//
//  Created by Manh Nguyen Ngoc on 14/5/25.
//

import Foundation
import GoogleMobileAds
import FirebaseRemoteConfig

class MaxRewardedHelper {
    func loadAds(processingBlock: @escaping () -> Void) {
        if !UtilsADS.shared.isOnReward {
            processingBlock()
            return
        } else {
            MaxRewarded.shared.loadRewardedAdmod {
                processingBlock()
            }
        }
    }
    
    func showAdsNow(viewController: UIViewController, completion: (() -> Void)? = nil, loadAdsFail: (() -> Void)? = nil) {
        if !UtilsADS.shared.isOnReward {
            completion?()
            return
        } else {
            MaxRewarded.shared.showRewardAdmod(controller: viewController, completion:  {
                completion?()
            }) {
                completion?()
            }
        }
    }
}
