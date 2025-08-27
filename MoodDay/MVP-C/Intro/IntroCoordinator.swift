//
//  IntroCoordinator.swift
//  MoodDay
//
//  Created by Trương Duy Tân on 26/8/25.
//

import UIKit

class IntroCoordinator: Coordinator {
    var started: Bool = false
    private weak var navigation: UINavigationController?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        if !started {
            started = true
            let introVC = IntroVC()
            introVC.coordinator = self
            self.navigation?.pushViewController(introVC, animated: true)
        }
    }
    
    func stop() {
        
    }
}
