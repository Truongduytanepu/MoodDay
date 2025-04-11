//
//  SplashVC.swift
//  FanNoise
//
//  Created by Manh Nguyen Ngoc on 11/4/25.
//

import UIKit

class SplashVC: BaseVC<SplashPresenter, SplashView> {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    func config() {

    }
}

extension SplashVC: SplashView {
    
}
