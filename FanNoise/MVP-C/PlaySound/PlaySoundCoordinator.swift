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
    private var sound: Sound
    private var sounds: [Sound] = []
    private var videos: [Video] = []
    
    init(navigation: UINavigationController, sound: Sound, sounds: [Sound], videos: [Video]) {
        self.navigation = navigation
        self.sound = sound
        self.sounds = sounds
        self.videos = videos
    }
    
    func start() {
        if !started {
            started = true
            let controller = PlaySoundVC.factory()
            controller.coordinator = self
            controller.soundItem = self.sound
            controller.listSound = self.sounds
            controller.listVideo = self.videos
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
