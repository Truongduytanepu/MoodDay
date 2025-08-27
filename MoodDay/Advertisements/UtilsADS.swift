import UIKit
import AdjustSdk
import Contacts
import ContactsUI
import EventKitUI
import RxSwift
import FirebaseAnalytics

// MARK: - Key remote config Firebase
class RemoteConfigKey: NSObject {
    static let key_time_capping = "key_time_capping"
    static let key_percent_lesson = "key_percent_lesson"
    static let key_is_on_sub = "key_is_on_sub"
    static let key_is_on_inter = "key_is_on_inter"
    static let key_is_on_reward = "key_is_on_reward"
    static let key_is_on_native = "key_is_on_native"
    static let key_is_on_native_full = "key_is_on_native_full"
    static let key_is_on_banner = "key_is_on_banner"
    static let key_is_on_aoa_splash = "key_is_on_aoa_splash"
    static let key_is_on_aoa_resume = "key_is_on_aoa_resume"
}

class UtilsADS: NSObject {
    static var shared = UtilsADS()
    
    var isOnAOAResume = true
    var isOnAOASplash = true
    var isOnBanner = true
    var isOnInter = true
    var isOnNative = true
    var isOnNativeFull = true
    var isOnReward = true
    var isOnSub = true
    var timeCapping: Double = 20.0
    
    var isShowAds = false
    var maxNumberClick = 3
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
    static let POLICYURL = "https://docs.google.com/document/d/1nsMw_EXVNZiNlD0ZSsO7xDhTlFHdYmAPUwbioaVgIsE"
    static let TERMURL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
    
    // MARK: - Key thật
//    static let key_banner = "ca-app-pub-6799331595407402/4905215388"
//    static let key_reward = "ca-app-pub-6799331595407402/5732562967"
//    static let key_inter = "ca-app-pub-6799331595407402/3803886708"
//    static let key_aoa_resume = "ca-app-pub-6799331595407402/1177723367"
//    static let key_aoa_splash = "ca-app-pub-6799331595407402/4419481290"
//    
//    static let key_native_full = "ca-app-pub-6799331595407402/6743791104"
//    static let key_native_intro = "ca-app-pub-6799331595407402/3163638744"
//    static let key_native_language = "ca-app-pub-6799331595407402/3050559302"
//    static let key_native_music = "ca-app-pub-6799331595407402/4117627762"
//    static let key_native_trending = "ca-app-pub-6799331595407402/1850557079"
//    static let key_native_library = "ca-app-pub-6799331595407402/3592133719"
//    static let key_native_filter_category = "ca-app-pub-6799331595407402/4395430564"
    
    // MARK: - Key test
    static let key_banner = "ca-app-pub-3940256099942544/8388050270"
    static let key_reward = "ca-app-pub-3940256099942544/1712485313"
    static let key_inter = "ca-app-pub-3940256099942544/4411468910"
    static let key_aoa_resume = "ca-app-pub-3940256099942544/5575463023"
    static let key_aoa_splash = "ca-app-pub-3940256099942544/5575463023"
    
    static let key_native_full = "ca-app-pub-3940256099942544/3986624511"
    static let key_native_intro = "ca-app-pub-3940256099942544/3986624511"
    static let key_native_language = "ca-app-pub-3940256099942544/3986624511"
    static let key_native_music = "ca-app-pub-3940256099942544/3986624511"
    static let key_native_trending = "ca-app-pub-3940256099942544/3986624511"
    static let key_native_library = "ca-app-pub-3940256099942544/3986624511"
    static let key_native_filter_category = "ca-app-pub-3940256099942544/3986624511"
}

struct KEY_ENCODE {
    static let isPremium = "isPremium"
}
