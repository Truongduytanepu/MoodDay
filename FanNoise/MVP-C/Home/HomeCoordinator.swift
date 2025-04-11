//
//  HomeCoordinator.swift
//  FanNoise
//
//  Created by Manh Nguyen Ngoc on 11/4/25.
//

import UIKit

class HomeCoordinator: Coordinator {
    var started: Bool = false
    
    func start() {
        if !started {
            started = true
        }
    }

    func stop() {
        
    }
}
