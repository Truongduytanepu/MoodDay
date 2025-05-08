//
//  TabbarVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 25/04/2025.
//

import UIKit

private struct Const {
    static let durationAnimate = 0.25
}

class TabbarVC: BaseVC<TabbarPresenter, TabbarView> {
    
    @IBOutlet private weak var tabbarView: UIView!
    @IBOutlet private weak var homeTabbarView: DimableView!
    @IBOutlet private weak var trendingTabbarView: DimableView!
    @IBOutlet private weak var trendingImageView: UIImageView!
    @IBOutlet private weak var homeImageView: UIImageView!
    @IBOutlet private weak var mainView: UIView!
    
    var coordinator : TabbarCoordinator!
    private var homeVC: HomeVC?
    private var previewVideoVC: PreviewVideoVC?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupTabbar()
    }
    
    // MARK: - Config
    private func config() {
        self.setupHomeViewController()
    }
    
    private func setupTabbar() {
        self.tabbarView.layoutIfNeeded()
        self.homeTabbarView.layoutIfNeeded()
        self.trendingTabbarView.layoutIfNeeded()
        
        self.tabbarView.cornerRadius = self.tabbarView.frame.height / 2
        self.homeTabbarView.cornerRadius = self.homeTabbarView.frame.height / 2
        self.trendingTabbarView.cornerRadius = self.trendingTabbarView.frame.height / 2
    }
    
    // MARK: - ViewController Management
    private func setupHomeViewController() {
        if self.homeVC == nil {
            self.homeVC = HomeVC.factory()
        }
        
        guard let home = self.homeVC else { return }
        
        addChild(home)
        home.view.frame = self.mainView.bounds
        home.view.alpha = 0 // Bắt đầu với alpha = 0 để làm fade in
        
        self.mainView.addSubview(home.view)
        home.didMove(toParent: self)
        
        UIView.animate(withDuration: Const.durationAnimate) {
            home.view.alpha = 1
        }
    }
    
    private func setupTrendingViewController() {
        if self.previewVideoVC == nil {
            self.previewVideoVC = PreviewVideoVC.factory()
        }
        
        guard let previewVideoVC = self.previewVideoVC else { return }
        
        addChild(previewVideoVC)
        previewVideoVC.view.frame = self.mainView.bounds
        previewVideoVC.view.alpha = 0 // Bắt đầu với alpha = 0 để làm fade in
        previewVideoVC.videoCategoryType = .trending
        
        self.mainView.addSubview(previewVideoVC.view)
        previewVideoVC.didMove(toParent: self)
        
        UIView.animate(withDuration: Const.durationAnimate) {
            previewVideoVC.view.alpha = 1
        }
    }
    
    private func removeHomeViewController() {
        guard let home = self.homeVC else { return }
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                home.view.alpha = 0
            },
            completion: { [weak self] _ in
                home.willMove(toParent: nil)
                home.view.removeFromSuperview()
                home.removeFromParent()
                self?.homeVC = nil
            }
        )
    }
    
    private func removeTrendingViewController() {
        guard let previewVideoVC = self.previewVideoVC else { return }
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                previewVideoVC.view.alpha = 0
            },
            completion: { [weak self] _ in
                previewVideoVC.stopVideo()
                previewVideoVC.willMove(toParent: nil)
                previewVideoVC.view.removeFromSuperview()
                previewVideoVC.removeFromParent()
                self?.homeVC = nil
            }
        )
    }
    
    @IBAction private func homeButtonDidTap(_ sender: Any) {
        self.removeTrendingViewController()
        self.setupHomeViewController()
        self.homeImageView.image = UIImage(named: "ic_tabbar_home_enable")
        self.trendingImageView.image = UIImage(named: "ic_tabbar_trending_disable")
        self.tabbarView.backgroundColor = .white
    }
    
    @IBAction private func trendingButtonDidTap(_ sender: Any) {
        self.removeHomeViewController()
        self.setupTrendingViewController()
        
        self.homeImageView.image = UIImage(named: "ic_tabbar_home_disable")
        self.trendingImageView.image = UIImage(named: "ic_tabbar_trending_enable")
        self.tabbarView.backgroundColor = .black
    }
}

// MARK: - Supporting Types

extension TabbarVC: TabbarView {
    
}
