//
//  TrendingVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 25/04/2025.
//

import UIKit

class TrendingVC: BaseVC<TrendingPresenter, TrendingView> {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var coordinator : TrendingCoordinator!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    private func config() {
        
    }
}

extension TrendingVC: TrendingView {
    
}
