//
//  AppDelegate.swift
//  MoodDay
//
//  Created by Trương Duy Tân on 26/8/25.
//

import UIKit
import Firebase
import SVProgressHUD
import UserMessagingPlatform
import SwiftyStoreKit
import StoreKit
import AppTrackingTransparency
import AdSupport
import AdjustSdk
import GoogleMobileAds
import Messages
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.configAdj(token: "m59pasz42zuo")
        self.configAds()
        self.configUIView()
        self.configDI()
        self.configLogging()
        self.configFirebase()
        self.setRootController()
        self.configRealm()
        self.fetchChoseLanguage()
        self.configMonitorNetwork()
        self.configSVProgressHUD()
        self.configAllRemoteConfigWithKey()
        self.requestPermissionATTracking()
        return true
    }
    
    private func setRootController() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        }
        
        let coordinator = SplashCoordinator.init(window: self.window)
        coordinator.start()
    }
    
    private func requestPermissionATTracking() {
        ATTrackingManager.requestTrackingAuthorization { (status) in
            switch status {
            case .denied, .notDetermined, .restricted:
                break
            case .authorized:
                self.configEEA()
            @unknown default:
                fatalError("Invalid authorization status")
            }
        }
    }
    
    private func configAdj(token: String) {
        let yourAppToken = token
        let environment = ADJEnvironmentProduction
        let adjustConfig = ADJConfig(
            appToken: yourAppToken,
            environment: environment)
        adjustConfig?.enableSendingInBackground()
        adjustConfig?.externalDeviceId = self.getDeviceIdentifier()
        Adjust.initSdk(adjustConfig)
    }
    
    private func getDeviceIdentifier() -> String? {
        // Lấy IDFA nếu được phép
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        
        // Fallback: IDFV + Keychain
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    private func configAds() {
        MobileAds.shared.start(completionHandler: nil)
    }
    
    private func configEEA() {
        // Request an update to the consent information.
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = false
        
        ConsentInformation.shared.requestConsentInfoUpdate(
            with: parameters,
            completionHandler: { error in
                if error != nil {
                    // Handle the error.
                } else {
                    // The consent information state was updated.
                    // You are now ready to check if a form is
                    // available.
                    let formStatus = ConsentInformation.shared.formStatus
                    if formStatus == FormStatus.available {
                        self.loadForm()
                    }
                }
            })
    }
    
    private func loadForm() {
        ConsentForm.load(with: { form, loadError in
            if loadError != nil {
                // Handle the error.
            } else {
                // Present the form. You can also hold on to the reference to present
                // later.
                if ConsentInformation.shared.consentStatus == ConsentStatus.required {
                    form?.present(
                        from: UIApplication.shared.windows.first(where: {$0.isKeyWindow})!.rootViewController!,
                        completionHandler: { dismissError in
                            if ConsentInformation.shared.consentStatus == ConsentStatus.obtained {
                                // App can start requesting ads.
                            }
                            // Handle dismissal by reloading form.
                            self.loadForm()
                        })
                } else {
                    // Keep the form available for changes to user consent.
                }
            }
        })
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Adjust.trackSubsessionStart()
    }
    
    func willResignActive(with conversation: MSConversation) {
        Adjust.trackSubsessionEnd()
    }
    
    private func configFirebase() {
        FirebaseApp.configure()
    }
    
    private func configUIView() {
        UIView.appearance().isExclusiveTouch = true
    }
    
    private func fetchChoseLanguage() {
        LanguageManager.shared.fetchChoseLanguage()
    }
    
    private func configLogging() {
        Logging.addLogEngine(ConsoleLogEngine())
        Logging.addLogEngine(CrashlyticsLogEngine())
    }
    
    private func configRealm() {
        RealmManager.configRealm()
    }
    
    private func configMonitorNetwork() {
        MonitorNetwork.shared.configMonitorNetwork()
    }
    
    private func configDI() {
        DIContainer.shared.register()
    }
    
    private func configSVProgressHUD() {
        SVProgressHUD.setDefaultMaskType(.black)
    }
    
    private func configAllRemoteConfigWithKey() {
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.key_is_on_aoa_resume) { isOn in
            UtilsADS.shared.isOnAOAResume = isOn
        }
        
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.key_is_on_aoa_splash) { isOn in
            UtilsADS.shared.isOnAOASplash = isOn
        }
        
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.key_is_on_banner) { isOn in
            UtilsADS.shared.isOnBanner = isOn
        }
        
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.key_is_on_inter) { isOn in
            UtilsADS.shared.isOnInter = isOn
        }
        
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.key_is_on_native) { isOn in
            UtilsADS.shared.isOnNative = isOn
        }
        
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.key_is_on_native_full) { isOn in
            UtilsADS.shared.isOnNativeFull = isOn
        }
        
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.key_is_on_reward) { isOn in
            UtilsADS.shared.isOnReward = isOn
        }
        
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.key_is_on_sub) { isOn in
            UtilsADS.shared.isOnSub = isOn
        }
        
        RemoteConfigHelper.shared.getRemoteConfigWithTimeCapping(key: RemoteConfigKey.key_time_capping) { timeCapping in
            UtilsADS.shared.timeCapping = timeCapping
        }
    }
}

enum Connection {
    case unavailable
    case wifi
    case cellular
}

class Reachability {
    var connection: Connection = .wifi
    init() throws {}
}

// MARK: - UIApplication
extension UIApplication {
    func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap { $0 as? UIWindowScene }?.windows
            .first(where: \.isKeyWindow)
    }
}
