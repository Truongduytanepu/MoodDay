//
//  InterstitialAdManager.swift
//  AirhornPrank
//
//  Created by Manh Nguyen Ngoc on 28/4/25.
//

import GoogleMobileAds

class InterstitialAdManager: NSObject {
    private var interstitial: InterstitialAd?
    private var adDismissedHandler: (() -> Void)?
    
    static let shared = InterstitialAdManager()
    private override init() {}
    
    func loadAd(completion: @escaping () -> Void) {
        let request = Request()
        InterstitialAd.load(with: UtilsADS.keyInter,
                            request: request) { [weak self] ad, error in
            
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                completion()
                return
            }
            
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            completion()
        }
    }
    
    func showAd(from viewController: UIViewController,
                onDismiss: @escaping () -> Void) {
        guard let ad = self.interstitial else {
            print("Ad wasn't ready")
            onDismiss()
            return
        }
        
        self.adDismissedHandler = onDismiss
        do {
            try ad.canPresent(from: viewController)
            ad.present(from: viewController)
        } catch {
            print("Failed to present interstitial ad: \(error.localizedDescription)")
            onDismiss()
        }
    }
}

extension InterstitialAdManager: FullScreenContentDelegate {
    // Called when ad fails to present
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Interstitial ad failed to present: \(error.localizedDescription)")
        self.adDismissedHandler?()
    }
    
    // Called when ad is dismissed
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Interstitial ad was dismissed")
        self.adDismissedHandler?()
        self.adDismissedHandler = nil
        
        // Load the next ad immediately after dismissal
        self.loadAd(completion: {})
    }
}

// Khi muốn hiển thị quảng cáo và xử lý khi đóng
// InterstitialAdManager.shared.showAd(from: self) {
// Code xử lý sau khi quảng cáo đóng
//    print("Quảng cáo đã đóng, tiếp tục thực hiện hành động")
//    self.doSomethingAfterAdDismissed()
//}
