//
//  Interstitial.swift
//  demo
//
//  Created by Mei Mei on 29/09/2022.
//

// swiftlint:disable all

import GoogleMobileAds
import SwiftUI
import UIKit

final class Interstitial:NSObject, FullScreenContentDelegate {
    var interstitial: InterstitialAd?
    var unitID: String
    var adsDismissListener: (() -> Void)?
    var isOpening = false
    private var currentVC: UIViewController?
    
    static let shared = Interstitial.init(unitID: UtilsADS.keyInter)

    init(unitID: String) {
        self.unitID = unitID
        super.init()
        
        self.loadInterstitial()
    }

    func loadInterstitial() {
        let request = Request()
        
        InterstitialAd.load(with: unitID, request: request) { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
        }
    }

    func showAd(dismissListner: (() -> Void)? = nil) {
        if self.interstitial != nil {
            self.adsDismissListener = dismissListner
            if !UtilsADS.shared.getPurchase(key: KEY_ENCODE.isPremium){
                if let topViewController = UIApplication.shared.windows.first?.rootViewController?.topVC() {
                    self.currentVC = topViewController
                    self.interstitial?.present(from: topViewController)
                    self.isOpening = true
                } else {
                    dismissListner?()
                    self.isOpening = false
                }
            }else{
                dismissListner?()
            }
        } else{
            self.adsDismissListener = nil
            dismissListner?()
            self.isOpening = false
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        self.currentVC?.dismiss(animated: true, completion: {
            self.loadInterstitial()
            self.adsDismissListener?()
            self.adsDismissListener = nil
            self.isOpening = false
        })
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        self.loadInterstitial()
        self.adsDismissListener?()
        self.adsDismissListener = nil
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
}
