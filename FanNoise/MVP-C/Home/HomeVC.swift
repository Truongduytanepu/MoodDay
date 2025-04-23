//
//  HomeVC.swift
//  FanNoise
//
//  Created by Manh Nguyen Ngoc on 11/4/25.
//

import UIKit

class HomeVC: BaseVC<HomePresenter, HomeView> {
    // MARK: - Lifecycle
    var coordinator: HomeCoordinator!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    func config() {

    }
}

extension HomeVC: HomeView {
    
}
