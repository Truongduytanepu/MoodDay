//
//  SplashCoordinator.swift
//  FanNoise
//
//  Created by Manh Nguyen Ngoc on 11/4/25.
//

import UIKit

class SplashCoordinator: Coordinator {
    var started: Bool = false
    private weak var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        if !started {
            started = true
        
            let controller = SplashVC()
            let nav = BaseNavigationController.init(rootViewController: controller)
            self.window?.rootViewController = nav
        }
    }

    func stop() {
        
    }
}
