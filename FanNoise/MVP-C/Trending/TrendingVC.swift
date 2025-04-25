//
//  TrendingVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 25/04/2025.
//

import UIKit

class TrendingVC: BaseVC<TrendingPresenter, TrendingView> {
    // MARK: - Lifecycle
    var coordinator : TrendingCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    func config() {

    }
}

extension TrendingVC: TrendingView {
    
}
