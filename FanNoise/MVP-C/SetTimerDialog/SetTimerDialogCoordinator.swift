//
//  SetTimerDialogCoordinator.swift
//  FanNoise
//
//  Created by ADMIN on 5/7/25.
//

import UIKit

class SetTimerDialogCoordinator: Coordinator {
    
    var started: Bool = false
    private var minute = 5
    private var second = 30
    private weak var navigation: UINavigationController?
    
    init(navigation: UINavigationController, minute: Int, second: Int) {
        self.navigation = navigation
        self.minute = minute
        self.second = second
    }
    
    func start() {
        if !started {
            started = true
            
        }
    }
    
    func presentSetTimerDialog(completion: @escaping (Int, Int, Bool) -> Void) {
        let setTimerDialogVC = SetTimerDialogVC.factory()
        setTimerDialogVC.modalPresentationStyle = .overCurrentContext
        setTimerDialogVC.minuteDefault = self.minute
        setTimerDialogVC.secondDefault = self.second
        
        setTimerDialogVC.onTimeSelected = { minute, second, isOn in
            completion(minute, second, isOn)
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
