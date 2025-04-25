//
//  TrendingCoordinator.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 25/04/2025.
//

import UIKit

class TrendingCoordinator: Coordinator {
    var started: Bool = false
    private weak var navigation: UINavigationController?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        if !started {
            started = true
            let controller = TrendingVC.factory()
            controller.coordinator = self
            self.navigation?.pushViewController(controller, animated: true)
        }
    }
    
    func stop() {
     
    }
}
