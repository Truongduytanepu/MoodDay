//
//  NativeAdLoader.swift
//  PrankVideoCallSanta
//
//  Created by BemBoy on 5/12/23.
//

import UIKit
import GoogleMobileAds

class NativeAdLoader: NSObject, AdLoaderDelegate, NativeAdLoaderDelegate, NativeAdDelegate {
    private(set) var nativeAds = [NativeAd]()
    private(set) var adLoader: AdLoader!
    
    private var completion: (() -> Void)?
    public var clickNativeAction: ((NativeAd) -> Void)?
    
    func loadNativeAd(keyNative: String, adCnt: Int, viewController: UIViewController, completion: (() -> Void)? = nil) {

        self.completion = completion
        
        let multipleAdsOptions = MultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = adCnt
        let nativeOptions = VideoOptions()
        nativeOptions.shouldStartMuted = true
        self.adLoader = AdLoader(adUnitID: keyNative,
                                    rootViewController: viewController,
                                    adTypes: [.native],
                                    options: [multipleAdsOptions, nativeOptions])
        self.adLoader.delegate = self
        self.adLoader.load(Request())
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(error)")
    }
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        nativeAd.paidEventHandler = { adValue in
            UtilsADS.shared.logEventCC(adFormat: "native", revenue:adValue.value.doubleValue)
        }
        
        nativeAd.delegate = self
        self.nativeAds.append(nativeAd)
    }
    
    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        self.completion?()
        self.completion = nil
    }
    
    func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        self.clickNativeAction?(nativeAd)
    }
}
