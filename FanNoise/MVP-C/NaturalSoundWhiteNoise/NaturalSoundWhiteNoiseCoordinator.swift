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
    private var categoryId : String
    private var categoryName : String
    
    init(navigation: UINavigationController,categoryId: String,categoryName: String) {
        self.navigation = navigation
        self.categoryId = categoryId
        self.categoryName = categoryName
    }
    
    func start() {
        if !started {
            started = true
            let controller = NaturalSoundWhiteNoiseVC.factory()
            controller.coordinator = self
            controller.categoryId = categoryId // Truyền categoryId sang DetailVC
            controller.categoryName = categoryName
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
