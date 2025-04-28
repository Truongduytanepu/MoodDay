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
    private var trendingVC: TrendingVC?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    // MARK: - Config
    private func config() {
        self.setupTabbar()
        self.setupHomeViewController()
    }
    
    private func setupTabbar() {
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
        home.view.translatesAutoresizingMaskIntoConstraints = false
        home.view.alpha = 0
        self.mainView.addSubview(home.view)
        
        // Auto Layout constraints để fill toàn bộ mainView
        NSLayoutConstraint.activate([
            home.view.topAnchor.constraint(equalTo: mainView.topAnchor),
            home.view.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            home.view.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            home.view.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
        ])
        
        home.didMove(toParent: self)
        
        UIView.animate(withDuration: Const.durationAnimate) {
            home.view.alpha = 1
        }
    }
    
    private func setupTrendingViewController() {
        if self.trendingVC == nil {
            self.trendingVC = TrendingVC.factory()
        }
        
        guard let trending = self.trendingVC else { return }
        
        addChild(trending)
        trending.view.translatesAutoresizingMaskIntoConstraints = false
        trending.view.alpha = 0
        self.mainView.addSubview(trending.view)
        
        // Auto Layout constraints để fill toàn bộ mainView
        NSLayoutConstraint.activate([
            trending.view.topAnchor.constraint(equalTo: mainView.topAnchor),
            trending.view.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            trending.view.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            trending.view.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
        ])
        
        trending.didMove(toParent: self)
        
        UIView.animate(withDuration: Const.durationAnimate) {
            trending.view.alpha = 1
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
        guard let trending = self.trendingVC else { return }
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                trending.view.alpha = 0
            },
            completion: { [weak self] _ in
                trending.willMove(toParent: nil)
                trending.view.removeFromSuperview()
                trending.removeFromParent()
                self?.homeVC = nil
            }
        )
    }
    
    @IBAction private func homeButtonDidTap(_ sender: Any) {
        self.setupHomeViewController()
        self.removeTrendingViewController()
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
