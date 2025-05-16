import UIKit
import Contacts
import ContactsUI
import EventKitUI
import RxSwift

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
    var isRemoteConfigInter = true
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
    
    static let REVIEWURL = "itms-apps://itunes.apple.com/us/app/itunes-u/id%@?action=write-review"

    static let POLICYURL = "https://docs.google.com/document/d/1UagFunvfwnTP6PrVWGoy7lzXdmGTNw8Xn6zTiYSBMp0"

    // MARK: - Key thật
//    static let keyAoaResume = "ca-app-pub-6799331595407402/4891125758"
//    static let keyAoaSplash = "ca-app-pub-6799331595407402/3059169334"
//    static let keyBanner = "ca-app-pub-6799331595407402/3863008753"
//    static let keyInter = "ca-app-pub-6799331595407402/6998414346"
//    static let keyNativeFull = "ca-app-pub-6799331595407402/3578044086"
//    static let keyNativeListVideo = "ca-app-pub-6799331595407402/9951880742"
//    static let keyNativeListSound = "ca-app-pub-6799331595407402/1755720160"

    // MARK: - Key test
    static let keyBanner = "ca-app-pub-3940256099942544/2934735716"
    static let keyNativeFull = "ca-app-pub-3940256099942544/3986624511"
    static let keyReward = "ca-app-pub-3940256099942544/1712485313"
    static let keyNativeListVideo = "ca-app-pub-3940256099942544/3986624511"
    static let keyNativeListSound = "ca-app-pub-3940256099942544/3986624511"
    static let keyInter = "ca-app-pub-3940256099942544/4411468910"
    static let keyAoaResume = "ca-app-pub-3940256099942544/5575463023"
    static let keyAoaSplash = "ca-app-pub-3940256099942544/5575463023"
}

struct KEY_ENCODE {
    static let isPremium = "isPremium"
}
