//
//  ListItemSoundByHashtagCoordinator.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 02/05/2025.
//

import UIKit

class ListItemSoundByHashtagCoordinator: Coordinator {
    var started: Bool = false
    private weak var navigation: UINavigationController?
    private var nameHashtag : String
    init(navigation: UINavigationController,nameHashtag: String) {
        self.navigation = navigation
        self.nameHashtag = nameHashtag
    }
    
    func start() {
        if !started {
            started = true
            let controller = ListItemSoundByHashtagVC.factory()
            controller.coordinator = self
            controller.nameHashtag = nameHashtag
            navigation?.pushViewController(controller, animated: true)
        }
    }
    
    func stop() {
        if started {
            started = false
            navigation?.popViewController(animated: true)
        }
    }
}
