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
    private var sound: [Sound]
    private var video: [Video]
    private var categoryID: String = ""
    
    init(navigation: UINavigationController,sound: [Sound],video: [Video], categoryID: String) {
        self.navigation = navigation
        self.sound = sound
        self.video = video
        self.categoryID = categoryID
    }
    
    func start() {
        if !started {
            started = true
            let controller = ListItemSoundVC.factory()
            controller.coordinator = self
            controller.sounds = self.sound
            controller.videos = self.video
            controller.categoryID = self.categoryID
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
