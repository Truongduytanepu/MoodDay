//
//  AppDelegate.swift
//  FanNoise
//
//  Created by Manh Nguyen Ngoc on 11/4/25.
//

import UIKit
import FirebaseCore
import SVProgressHUD
import GoogleMobileAds
import AppTrackingTransparency
import UserMessagingPlatform
import AdjustSdk
import AppTrackingTransparency
import AdSupport

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.configAdj(token: "q6rmgms50cg0")
        self.configUIView()
        self.configDI()
        self.configLogging()
        self.configFirebase()
        self.setRootController()
        self.configRealm()
        self.configMonitorNetwork()
        self.configSVProgressHUD()
        self.fetch()
        self.configAds()
        return true
    }
    
    private func requestPermissionATTracking() {
        ATTrackingManager.requestTrackingAuthorization { [weak self] (status) in
            guard let self = self else {return}
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
        Adjust.initSdk(adjustConfig)
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
    
    private func fetch() {
        LanguageManager.shared.fetchChoseLanguage()
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
    
    private func configFirebase() {
        FirebaseApp.configure()
    }
    
    private func configUIView() {
        UIView.appearance().isExclusiveTouch = true
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
    
    private func configAds() {
        MobileAds.shared.start(completionHandler: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.requestPermissionATTracking()
        Adjust.trackSubsessionStart()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Adjust.trackSubsessionEnd()
    }
}
