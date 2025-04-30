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
    private var homeCategory : HomeCategory
    init(navigation: UINavigationController,homeCategory: HomeCategory) {
        self.navigation = navigation
        self.homeCategory = homeCategory
    }
    
    func start() {
        if !started {
            started = true
            let controller = ListItemSoundVC.factory()
            controller.coordinator = self
            controller.categoryId = homeCategory.id ?? "" // Truyền categoryId sang DetailVC
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
