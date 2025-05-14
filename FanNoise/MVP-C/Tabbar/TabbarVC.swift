//
//  TabbarVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 25/04/2025.
//

import UIKit
import GoogleMobileAds

private struct Const {
    static let durationAnimate = 0.25
    static let bottomConstraint: CGFloat = -30
}

class TabbarVC: BaseVC<TabbarPresenter, TabbarView> {
    
    @IBOutlet private weak var bottomTabbarViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tabbarView: UIView!
    @IBOutlet private weak var homeTabbarView: DimableView!
    @IBOutlet private weak var trendingTabbarView: DimableView!
    @IBOutlet private weak var trendingImageView: UIImageView!
    @IBOutlet private weak var homeImageView: UIImageView!
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var bannerContainView: UIView!
    @IBOutlet private weak var bannerContentView: UIView!
    
    var coordinator : TabbarCoordinator!
    private var homeVC: HomeVC?
    private var currentTab: TabType = .home
    private var bannerView: BannerView!

    enum TabType {
        case home
        case trending
    }
    
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
        self.configBannerView()
        self.setupAdaptiveBanner()
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
    
    private func setupAdaptiveBanner() {
        let adaptiveSize = adSizeFor(cgSize: CGSize(width: UIScreen.main.bounds.width, height: 50))
        self.bannerView = BannerView(adSize: adaptiveSize)
        self.addBannerViewToView(bannerView)
    }
    
    private func addBannerViewToView(_ bannerView: BannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.bannerContentView.addSubview(bannerView)
    }
    
    private func configBannerView() {
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.keyIsOnBanner) { [weak self] isOn in
            guard let self = self else { return }
            if !isOn {
                self.bottomTabbarViewConstraint.constant = Const.bottomConstraint
                self.bannerContainView.isHidden = true
                return
            }
            
            self.bannerContainView.isHidden = false
            self.bannerView.delegate = self
            self.bannerView.rootViewController = self
            self.bannerView.adUnitID = UtilsADS.keyBanner
            self.loadBannerAds()
        }
    }
    
    private func loadBannerAds() {
        let request = InterstitialHelper.makeCollapsibleBannerRequest()
        self.bannerView.load(request)
    }
    
    @IBAction private func homeButtonDidTap(_ sender: Any) {
        let adsBlock = {
            guard self.currentTab != .home else { return }
            self.currentTab = .home
            
            self.removeTrendingViewController()
            self.setupHomeViewController()
            self.homeImageView.image = UIImage(named: "ic_tabbar_home_enable")
            self.trendingImageView.image = UIImage(named: "ic_tabbar_trending_disable")
            self.tabbarView.backgroundColor = .white
        }
        
        self.executeWithAdCheck(adsBlock)
    }
    
    @IBAction private func trendingButtonDidTap(_ sender: Any) {
        let adsBlock = {
            guard self.currentTab != .trending else { return }
            self.currentTab = .trending
            
            self.removeHomeViewController()
            self.setupTrendingViewController()
            
            self.homeImageView.image = UIImage(named: "ic_tabbar_home_disable")
            self.trendingImageView.image = UIImage(named: "ic_tabbar_trending_enable")
            self.tabbarView.backgroundColor = .black
        }
        
        self.executeWithAdCheck(adsBlock)
    }
}

extension TabbarVC: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        self.bannerContainView.isHidden = false
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("Load ads for banner error: \(error)")
        self.bottomTabbarViewConstraint.constant = Const.bottomConstraint
        self.bannerContainView.isHidden = true
    }

    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
    }
}

// MARK: - Supporting Types

extension TabbarVC: TabbarView {
    
}
