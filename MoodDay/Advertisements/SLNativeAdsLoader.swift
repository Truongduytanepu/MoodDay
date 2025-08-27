//
//  SLNativeAdsLoader.swift
//  RenaissanceMouthEye
//
//  Created by Linh Nguyen Duc on 01/02/2023.
//

import UIKit
import GoogleMobileAds

@objc protocol SLNativeAdsLoaderDelegate: AnyObject {
    func slNativeAdsLoader(_ loader: SLNativeAdsLoader, didFinishLoading nativeAds: [NativeAd])
    @objc optional func slNativeAdsLoader(_ loader: SLNativeAdsLoader, didReceive nativeAd: NativeAd)
    @objc optional func slNativeAdsLoader(_ loader: SLNativeAdsLoader, didReceiveError error: Error)
}

class SLNativeAdsLoader: NSObject {
    private(set) var nativeAds = [NativeAd]()
    private var adLoader: AdLoader!

    weak var delegate: SLNativeAdsLoaderDelegate?
    
    public var clickNativeAction: ((NativeAd) -> Void)?
    private var completion: (() -> Void)?
    
    func loadNativeAd(key: String, adCnt: Int = 5, rootViewController: UIViewController, clearBeforeLoad: Bool = true, completion: @escaping () -> ()) {
        if !UtilsADS.shared.isOnNative {
            completion()
            return
        }
        
        self.completion = completion
        
        if clearBeforeLoad {
            self.nativeAds = []
        }
        // phần còn lại giữ nguyên
        let multipleAdsOptions = MultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = adCnt
        self.adLoader = AdLoader(adUnitID: key,
                                 rootViewController: rootViewController,
                                 adTypes: [.native],
                                 options: [multipleAdsOptions])
        self.adLoader.delegate = self
        self.adLoader.load(Request())
    }
}

// MARK: - GADNativeAdLoaderDelegate, GADNativeAdDelegate
extension SLNativeAdsLoader: NativeAdLoaderDelegate, NativeAdDelegate {
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(error)")
        delegate?.slNativeAdsLoader?(self, didReceiveError: error)
    }

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        nativeAd.delegate = self
        self.nativeAds.append(nativeAd)
        
        nativeAd.paidEventHandler = { adValue in
            UtilsADS.shared.logEventCC(adFormat: "native", revenue:adValue.value.doubleValue)
        }
        
        delegate?.slNativeAdsLoader?(self, didReceive: nativeAd)
    }

    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        self.completion?()
        self.completion = nil
    }
    
    func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        self.clickNativeAction?(nativeAd)
    }
}
