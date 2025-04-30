//
//  NaturalSoundWhiteNoiseCoordinator.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 28/04/2025.
//

import UIKit

class NaturalSoundWhiteNoiseCoordinator: Coordinator {
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
            let controller = NaturalSoundWhiteNoiseVC.factory()
            controller.coordinator = self
            controller.categoryId = homeCategory.id ?? "" 
            controller.categoryName = homeCategory.name ?? ""
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
