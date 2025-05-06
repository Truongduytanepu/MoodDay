//
//  AppDelegate.swift
//  FanNoise
//
//  Created by Manh Nguyen Ngoc on 11/4/25.
//

import UIKit
import FirebaseCore
import SVProgressHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.configUIView()
        self.configDI()
        self.configLogging()
        self.configFirebase()
        self.setRootController()
        self.configRealm()
        self.configMonitorNetwork()
        self.configSVProgressHUD()
        self.fetch()
        return true
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
}
