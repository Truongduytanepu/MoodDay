//
//  HomeCoordinator.swift
//  FanNoise
//
//  Created by Manh Nguyen Ngoc on 11/4/25.
//

import UIKit

class HomeCoordinator: Coordinator {
    var started: Bool = false
    private weak var navigation: UINavigationController?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        if !started {
            started = true
            let controller = HomeVC.factory()
            controller.coordinator = self
            self.navigation?.pushViewController(controller, animated: true)
        }
    }
    
    func stop() {
     
    }
}
