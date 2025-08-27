//
//  MaxRewarded.swift
//  PrankVideoCallSanta
//
//  Created by BemBoy on 5/12/23.
//

import UIKit
import GoogleMobileAds

class MaxRewarded: NSObject {
    
    private(set) var retryAttempt = 0.0
    private(set) var didLoadSuccess = false
    private(set) var dismissBlock: (() -> Void)?
    
    static var shared = MaxRewarded()
    
    override init() {
        super.init()
    }
    
    private var rewardedAdmod: RewardedAd?
    
    func loadRewardedAdmod(processingBlock: (() -> Void)? = nil) {
        let request = Request()
        RewardedAd.load(with: UtilsADS.key_reward,
                        request: request,
                        completionHandler: { [self] ad, error in
            if error != nil {
                processingBlock?()
                return
            }
            
            self.rewardedAdmod = ad
            self.rewardedAdmod?.fullScreenContentDelegate = self
            processingBlock?()
        })
    }
    
    func showRewardAdmod(controller: UIViewController, completion: (() -> Void)? = nil, loadAdsFail: (() -> Void)? = nil) {
        if let ad = rewardedAdmod {
            self.dismissBlock = completion
            
            ad.paidEventHandler = { adValue in
                UtilsADS.shared.logEventCC(adFormat: "reward", revenue:adValue.value.doubleValue)
            }
            
            ad.present(from: controller) {
                let reward = ad.adReward
                print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
                self.didLoadSuccess = true
            }
        } else {
            self.didLoadSuccess = false
            loadAdsFail?()
            self.dismissBlock = nil
        }
    }
}

// MARK: - FullScreenContentDelegate
extension MaxRewarded: FullScreenContentDelegate {
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.loadRewardedAdmod()
        }
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        self.dismissBlock?()
        self.dismissBlock = nil
    }
}
