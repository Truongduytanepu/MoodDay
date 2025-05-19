import UIKit
import AdjustSdk
import Contacts
import ContactsUI
import EventKitUI
import RxSwift
import FirebaseAnalytics

// MARK: - Key remote config Firebase
class RemoteConfigKey: NSObject {
    static let keyTimeCapping = "key_time_capping"
    static let keyIsOnSub = "key_is_on_sub"
    static let keyIsOnInter = "key_is_on_inter"
    static let keyIsOnReward = "key_is_on_reward"
    static let keyIsOnNative = "key_is_on_native"
    static let keyIsOnNativeFull = "key_is_on_native_full"
    static let keyIsOnBanner = "key_is_on_banner"
    static let keyIsOnAoaSplash = "key_is_on_aoa_splash"
    static let keyIsOnAoaResume = "key_is_on_aoa_resume"
}

class UtilsADS: NSObject {
    static var shared = UtilsADS()
    
    var isShowAds = false
    var didPurchasePremiumSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    
    override init() {
        super.init()
        self.didPurchasePremiumSubject.onNext(self.getPurchase(key: KEY_ENCODE.isPremium))
    }
    
    func savePurchase(key: String, value: Bool) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
        defaults.set(value, forKey: key)
    }
    
    func getPurchase(key: String) -> Bool {
        let defaults = UserDefaults.standard
        if let data = defaults.value(forKey: key) as? Bool {
            return data
        } else {
            return  false
        }
    }
    
    func removePurchase(key: String) {
        let defaults = UserDefaults.standard
        return defaults.removeObject(forKey: key)
    }
    
    func logEventCC(adFormat: String, revenue: Double) { // adFormat: collapsible, inter, app_open, native, reward, banner
        Analytics.logEvent("ad_revenue_sdk", parameters: [
          AnalyticsParameterAdFormat: adFormat,
          AnalyticsParameterValue: revenue / 1_000_000,
          AnalyticsParameterCurrency: "USD",
        ])
        logRevAdjust(revenue: revenue)
    }
    
    func logRevAdjust(revenue: Double) {
        guard let adRevenue = ADJAdRevenue(source: "admob_sdk") else { return }
        adRevenue.setRevenue(revenue/1_000_000, currency: "USD")
        Adjust.trackAdRevenue(adRevenue)
    }
    
    static let REVIEWURL = "itms-apps://itunes.apple.com/us/app/itunes-u/id%@?action=write-review"

    static let POLICYURL = "https://docs.google.com/document/d/1UagFunvfwnTP6PrVWGoy7lzXdmGTNw8Xn6zTiYSBMp0"

    // MARK: - Key thật
    static let keyBanner = "ca-app-pub-6799331595407402/3630827041"
    static let keyNativeFull = "ca-app-pub-6799331595407402/2317745371"
    static let keyNativeListTrending = "ca-app-pub-6799331595407402/8179320416"
    static let keyNativeListSoundAndVideo = "ca-app-pub-6799331595407402/5553157076"
    static let keyInter = "ca-app-pub-6799331595407402/2593604204"
    static let keyAoaResume = "ca-app-pub-6799331595407402/6341277520"
    static let keyAoaSplash = "ca-app-pub-6799331595407402/9490185042"

    // MARK: - Key test
//    static let keyBanner = "ca-app-pub-3940256099942544/2934735716"
//    static let keyNativeFull = "ca-app-pub-3940256099942544/3986624511"
//    static let keyNativeListTrending = "ca-app-pub-3940256099942544/3986624511"
//    static let keyNativeListSoundAndVideo = "ca-app-pub-3940256099942544/3986624511"
//    static let keyInter = "ca-app-pub-3940256099942544/4411468910"
//    static let keyAoaResume = "ca-app-pub-3940256099942544/5575463023"
//    static let keyAoaSplash = "ca-app-pub-3940256099942544/5575463023"
}

struct KEY_ENCODE {
    static let isPremium = "isPremium"
}
