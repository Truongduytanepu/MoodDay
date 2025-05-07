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
    private var videos: [Video] = []
    
    init(navigation: UINavigationController,nameHashtag: String, videos: [Video]) {
        self.navigation = navigation
        self.nameHashtag = nameHashtag
        self.videos = videos
    }
    
    func start() {
        if !started {
            started = true
            let controller = ListItemSoundByHashtagVC.factory()
            controller.coordinator = self
            controller.nameHashtag = nameHashtag
            controller.videos = self.videos
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
