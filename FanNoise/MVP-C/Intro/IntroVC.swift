//
//  IntroVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 21/04/2025.
//

import UIKit

class IntroVC: BaseVC<IntroPresenter, IntroView> {
    // MARK: - Lifecycle
    var coordinator: IntroCoordinator!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    func config() {

    }
}

extension IntroVC: IntroView {
    
}
