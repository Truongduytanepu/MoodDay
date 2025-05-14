//
//  InterstitialAdManager.swift
//  AirhornPrank
//
//  Created by Manh Nguyen Ngoc on 28/4/25.
//

import GoogleMobileAds

class InterstitialAdManager {
    private var interstitial: InterstitialAd?
    
    static let shared = InterstitialAdManager()
    private init() {}
    
    func loadAd(processingBlock: @escaping () -> Void) {
        let request = Request()
        InterstitialAd.load(with: UtilsADS.keyInter,
                              request: request) { [weak self] ads, error in
            if let error = error {
                processingBlock()
                return
            }
            
            self?.interstitial = ads
            processingBlock()
        }
    }
    
    func showAd(from viewController: UIViewController, processingBlock: @escaping () -> Void) {
        if let ads = interstitial {
            ads.present(from: viewController)
            processingBlock()
        } else {
            processingBlock()
        }
    }
}

// Cách sử dụng:
// InterstitialAdManager.shared.loadAd() // Gọi khi khởi tạo app
// InterstitialAdManager.shared.showAd(from: self) // Khi muốn hiển thị
