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

    func loadNativeAd(key: String, adCnt: Int = 5, rootViewController: UIViewController, completion: @escaping () -> ()) {
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.keyIsOnNative) { [weak self] isOn in
            guard let self = self else { return }
            if !isOn {
                completion()
                return
            } else {
                self.nativeAds = []
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
    }
}

// MARK: - GADNativeAdLoaderDelegate, GADNativeAdDelegate
extension SLNativeAdsLoader: NativeAdLoaderDelegate, NativeAdDelegate {
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(error)")
        delegate?.slNativeAdsLoader?(self, didReceiveError: error)
    }

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAds.append(nativeAd)
        delegate?.slNativeAdsLoader?(self, didReceive: nativeAd)
    }

    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        delegate?.slNativeAdsLoader(self, didFinishLoading: self.nativeAds)
    }
}
