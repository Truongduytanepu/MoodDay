//
//  UnderNativeController.swift
//  AirhornPrank
//
//  Created by Manh Nguyen Ngoc on 6/5/25.
//

import UIKit
import GoogleMobileAds

class UnderNativeController: UIViewController {
    
    private var loadingView: UIView!
    private var loadingIcon: UIImageView!
    private var titleLabel: UILabel!
    
    private var nativeAdLoader = NativeAdLoader()
    private var gadNativeAdView: NativeAdView!
    private var nativeAdsView: UIView!
    private var cancelNativeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    // MARK: - Config
    private func config() {
        self.configUI()
        self.configLoadingView()
        self.configNativeAdsView()
    }
    
    private func configUI() {
        self.view.backgroundColor = .white
    }
    
    private func configNativeAdsView() {
        self.nativeAdsView = UIView()
        self.nativeAdsView.backgroundColor = .white
        self.nativeAdsView.alpha = 0
        self.nativeAdsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.nativeAdsView)
        self.nativeAdsView.fitSuperviewConstraint()
        
        self.gadNativeAdView = Bundle.main.loadNibNamed("UnderNativeAdView", owner: nil, options: nil)!.first as! NativeAdView
        self.gadNativeAdView.translatesAutoresizingMaskIntoConstraints = false
        self.nativeAdsView.addSubview(self.gadNativeAdView)
        self.gadNativeAdView.fitSuperviewConstraint()
        
        self.cancelNativeButton = UIButton(type: .custom)
        self.cancelNativeButton.backgroundColor = .clear
        self.cancelNativeButton.setImage(UIImage(named: "ic_cancle"), for: .normal)
        self.cancelNativeButton.translatesAutoresizingMaskIntoConstraints = false
        self.nativeAdsView.addSubview(self.cancelNativeButton)
        NSLayoutConstraint.activate([
            self.cancelNativeButton.topAnchor.constraint(equalTo: self.nativeAdsView.topAnchor, constant: 50),
            self.cancelNativeButton.trailingAnchor.constraint(equalTo: self.nativeAdsView.trailingAnchor, constant: -5),
            self.cancelNativeButton.widthAnchor.constraint(equalToConstant: 40),
            self.cancelNativeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        self.cancelNativeButton.addTarget(self, action: #selector(cancelNativeButtonDidTap(_:)), for: .touchUpInside)
    }
    
    @objc private func cancelNativeButtonDidTap(_ sender: UIButton) {
        UtilsADS.shared.isShowAds = false
        self.dismiss(animated: true)
    }
    
    // MARK: - Native Ads
    private func loadNativeAds(completion: (() -> Void)? = nil) {
        self.nativeAdLoader.loadNativeAd(keyNative: UtilsADS.key_native_full, adCnt: 1, viewController: self) { [weak self] in
            guard let self else { return }
            
            completion?()
            
            if !self.nativeAdLoader.nativeAds.isEmpty {
                DispatchQueue.main.async {
                    self.bindNativeAds(gadNativeAdView: self.gadNativeAdView, nativeAd: self.nativeAdLoader.nativeAds[0])
                }
            }
        }
    }
    
    private func bindNativeAds(gadNativeAdView: NativeAdView, nativeAd: NativeAd) {
        gadNativeAdView.nativeAd = nativeAd
        (gadNativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        gadNativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        (gadNativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        gadNativeAdView.bodyView?.isHidden = nativeAd.body == nil

        (gadNativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        gadNativeAdView.iconView?.isHidden = nativeAd.icon == nil

        (gadNativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        gadNativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil

        gadNativeAdView.callToActionView?.isUserInteractionEnabled = false
    }
    
    // MARK: - Helper
    private func showLoadingView(title: String = "Welcome back") {
        self.titleLabel.text = title
        self.view.bringSubviewToFront(self.loadingView)
        self.loadingView.alpha = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startLoadingAnimation()
        }
    }
    
    private func configLoadingView() {
        self.loadingView = UIView()
        self.loadingView.backgroundColor = .white
        self.loadingView.alpha = 0
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.loadingView)
        self.loadingView.fitSuperviewConstraint()
        
        self.titleLabel = UILabel()
        self.titleLabel.text = "Welcome back"
        self.titleLabel.textColor = UIColor(rgb: 0x000317)
        self.titleLabel.font = AppFont.font(.rubikBold, size: 20)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.addSubview(self.titleLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.loadingView.bottomAnchor, constant: -40)
        ])
        
        self.loadingIcon = UIImageView(image: UIImage(named: "ic_splash_loading"))
        self.loadingIcon.backgroundColor = .clear
        self.loadingIcon.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.addSubview(self.loadingIcon)
        NSLayoutConstraint.activate([
            self.loadingIcon.bottomAnchor.constraint(equalTo: self.titleLabel.topAnchor, constant: -10),
            self.loadingIcon.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor),
            self.loadingIcon.widthAnchor.constraint(equalToConstant: 32),
            self.loadingIcon.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        let loadingLogo = UIImageView(image: UIImage(named: "ic_splash_logo"))
        loadingLogo.backgroundColor = .clear
        loadingLogo.contentMode = .scaleAspectFit
        loadingLogo.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.addSubview(loadingLogo)

        NSLayoutConstraint.activate([
            loadingLogo.topAnchor.constraint(equalTo: self.loadingView.safeAreaLayoutGuide.topAnchor, constant: 248),
            loadingLogo.leadingAnchor.constraint(equalTo: self.loadingView.leadingAnchor, constant: 115),
            loadingLogo.trailingAnchor.constraint(equalTo: self.loadingView.trailingAnchor, constant: -115),
            loadingLogo.heightAnchor.constraint(equalTo: loadingLogo.widthAnchor, multiplier: 202/145)
        ])
    }
    
    private func dismissLoadingView() {
        self.loadingView.alpha = 0
    }
    
    private func showNativeAdsView() {
        self.nativeAdsView.alpha = 1
    }
    
    private func startLoadingAnimation() {
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.repeat]) { [weak self] in
            guard let self else { return }
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                self.loadingIcon.transform = CGAffineTransform(rotationAngle: .pi / 2)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                self.loadingIcon.transform = CGAffineTransform(rotationAngle: .pi)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                self.loadingIcon.transform = CGAffineTransform(rotationAngle: .pi / 2 * 3)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                self.loadingIcon.transform = CGAffineTransform(rotationAngle: .pi * 2)
            }
        }
    }
    
    // MARK: - Inter Ads
    public func showNativeFullAndInterstitialHelperAds(adsBlock: @escaping () -> Void) {
        self.loadViewIfNeeded()
        UtilsADS.shared.isShowAds = true
        self.showLoadingView(title: "Loading Ads")
        
        InterstitialHelper().loadAds { [weak self] in
            guard let self = self else { return }
            self.dismissLoadingView()
            
            self.loadNativeAds { [weak self] in
                guard let self = self else { return }
                self.showNativeAdsView()
            }
            
            InterstitialHelper().showAdsNow(viewController: self) {
                adsBlock()
                UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: "showingAdsLastTime")
            }
        }
    }
    
    public func showOnlyInterstitialHelperAds(adsBlock: @escaping () -> Void) {
        self.loadViewIfNeeded()
        UtilsADS.shared.isShowAds = true
        self.showLoadingView(title: "Loading Ads")
        
        InterstitialHelper().loadAds { [weak self] in
            guard let self = self else { return }
            self.dismissLoadingView()
            InterstitialHelper().showAdsNow(viewController: self) {
                adsBlock()
                UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: "showingAdsLastTime")
                UtilsADS.shared.isShowAds = false
                self.dismiss(animated: true)
            }
        }
    }
    
    // MARK: - Reward Ads
    public func showNativeFullAndRewardedHelperAds(adsBlock: @escaping () -> Void) {
        self.loadViewIfNeeded()
        UtilsADS.shared.isShowAds = true
        self.showLoadingView(title: "Loading Ads")
        
        MaxRewardedHelper().loadAds { [weak self] in
            guard let self = self else { return }
            self.dismissLoadingView()
            
            self.loadNativeAds { [weak self] in
                guard let self = self else { return }
                self.showNativeAdsView()
            }
            
            MaxRewardedHelper().showAdsNow(viewController: self, completion:  {
                adsBlock()
            }) {
                InterstitialHelper().showAdsNow(viewController: self) {
                    adsBlock()
                }
            }
        }
    }
    
    public func showOnlyRewardedHelperAds(adsBlock: @escaping () -> Void) {
        self.loadViewIfNeeded()
        UtilsADS.shared.isShowAds = true
        self.showLoadingView(title: "Loading Ads")
        
        MaxRewardedHelper().loadAds { [weak self] in
            guard let self = self else { return }
            self.dismissLoadingView()
            
            MaxRewardedHelper().showAdsNow(viewController: self, completion:  {
                adsBlock()
                UtilsADS.shared.isShowAds = false
                self.dismiss(animated: true)
            }) {
                InterstitialHelper().showAdsNow(viewController: self) {
                    adsBlock()
                    UtilsADS.shared.isShowAds = false
                    self.dismiss(animated: true)
                }
            }
        }
    }
}
