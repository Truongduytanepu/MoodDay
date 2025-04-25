//
//  VideoCoordinator.swift
//  FanNoise
//
//  Created by ADMIN on 4/25/25.
//

import UIKit

class VideoCoordinator: Coordinator {
    
    var started: Bool = false
    private weak var navigation: UINavigationController?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        if !started {
            started = true
            let controller = VideoVC.factory()
            controller.coordinator = self
            self.navigation?.pushViewController(controller, animated: true)
        }
    }
    
    func stop(completion: (() -> Void)? = nil) {
        if started {
            started = false
        }
    }
    
    func stop() {
        
    }
}

