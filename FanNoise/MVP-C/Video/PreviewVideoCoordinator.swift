//
//  VideoCoordinator.swift
//  FanNoise
//
//  Created by ADMIN on 4/25/25.
//

import UIKit

class PreviewVideoCoordinator: Coordinator {
    
    var started: Bool = false
    var videoCategoryType: VideoCategoryType
    var targetIndexPath: IndexPath?
    private weak var navigation: UINavigationController?
    
    init(navigation: UINavigationController, videoCategoryType: VideoCategoryType) {
        self.navigation = navigation
        self.videoCategoryType = videoCategoryType
    }
    
    func start() {
        if !started {
            started = true
            let controller = PreviewVideoVC.factory()
            controller.coordinator = self
            controller.videoCategoryType = self.videoCategoryType
            controller.targetIndexPath = self.targetIndexPath
            self.navigation?.pushViewController(controller, animated: true)
        }
    }
    
    func stop() {
        if started {
            started = false
            self.navigation?.popViewController(animated: true)
        }
    }
}
