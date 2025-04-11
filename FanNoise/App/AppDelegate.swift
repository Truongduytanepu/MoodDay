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
        config()
        configFirebase()
        setRootController()
        configRealm()
        configMonitorNetwork()
        
        SVProgressHUD.setDefaultMaskType(.black)
        return true
    }
    
    func setRootController() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        }
        
        let coordinator = SplashCoordinator.init(window: self.window)
        coordinator.start()
    }
    
    func configFirebase() {
        FirebaseApp.configure()
    }
    
    func config() {
        UIView.appearance().isExclusiveTouch = true
        
        Logging.addLogEngine(ConsoleLogEngine())
        Logging.addLogEngine(CrashlyticsLogEngine())
    }
    
    func configRealm() {
        RealmManager.configRealm()
    }
    
    func configMonitorNetwork() {
        MonitorNetwork.shared.configMonitorNetwork()
    }
}
