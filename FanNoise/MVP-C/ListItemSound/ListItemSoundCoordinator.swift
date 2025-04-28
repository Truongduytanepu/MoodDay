//
//  ListItemSoundCoordinator.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 26/04/2025.
//

import UIKit

class ListItemSoundCoordinator: Coordinator {
    var started: Bool = false
    private weak var navigation: UINavigationController?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        if !started {
            started = true
            let controller = ListItemSoundVC.factory()
            controller.coordinator = self
            navigation?.pushViewController(controller, animated: true)
        }
    }
    
    func stop() {
        if started {
            started = false
            self.navigation?.popViewController(animated: true)
        }
    }
}
