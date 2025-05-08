//
//  SetTimerDialogCoordinator.swift
//  FanNoise
//
//  Created by ADMIN on 5/7/25.
//

import UIKit

class SetTimerDialogCoordinator: Coordinator {
    
    var started: Bool = false
    private weak var navigation: UINavigationController?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        if !started {
            started = true
            
        }
    }
    
    func presentSetTimerDialog(completion: @escaping (Int, Int) -> Void) {
        let setTimerDialogVC = SetTimerDialogVC.factory()
        setTimerDialogVC.modalPresentationStyle = .overCurrentContext
        
        setTimerDialogVC.onTimeSelected = { minute, second in
            completion(minute, second)
        }
        
        self.navigation?.present(setTimerDialogVC, animated: true, completion: nil)
    }

    func stop() {
        if started {
            started = false
            self.navigation?.dismiss(animated: true)
        }
    }
}
