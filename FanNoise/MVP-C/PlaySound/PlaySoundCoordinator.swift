//
//  PlaySoundCoordinator.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 02/05/2025.
//

import UIKit

class PlaySoundCoordinator: Coordinator {
    var started: Bool = false
    private weak var navigation: UINavigationController?
    private var sound : Sound
    init(navigation: UINavigationController,sound: Sound) {
        self.navigation = navigation
        self.sound = sound
    }
    
    func start() {
        if !started {
            started = true
            let controller = PlaySoundVC.factory()
            controller.coordinator = self
            controller.soundItem = self.sound
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
