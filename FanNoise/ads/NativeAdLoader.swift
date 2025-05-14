//
//  NativeAdLoader.swift
//  PrankVideoCallSanta
//
//  Created by BemBoy on 5/12/23.
//

import UIKit
import GoogleMobileAds

class NativeAdLoader: NSObject, AdLoaderDelegate, NativeAdLoaderDelegate {
    private(set) var nativeAds = [NativeAd]()
    private(set) var adLoader: AdLoader!
    private var completion: (() -> Void)?

    func loadNativeAd(adCnt: Int, viewController: UIViewController, completion: (() -> Void)? = nil) {

        self.completion = completion
        
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.keyIsOnNativeFull) { [weak self] isOn in
            guard let self = self else { return }
            if !isOn {
                completion?()
                return
            } else {
                let multipleAdsOptions = MultipleAdsAdLoaderOptions()
                multipleAdsOptions.numberOfAds = adCnt
                let nativeOptions = VideoOptions()
                nativeOptions.shouldStartMuted = true
                self.adLoader = AdLoader(adUnitID: UtilsADS.keyNativeFull,
                                            rootViewController: viewController,
                                            adTypes: [.native],
                                            options: [multipleAdsOptions, nativeOptions])
                self.adLoader.delegate = self
                self.adLoader.load(Request())
            }
        }
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(error)")
    }
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAds.append(nativeAd)
    }
    
    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        self.completion?()
        self.completion = nil
    }
}
