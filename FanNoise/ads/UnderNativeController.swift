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
    private var indicatorView: UIActivityIndicatorView!
    private var titleLabel: UILabel!
    
    private var nativeAdLoader = NativeAdLoader()
    private var gadNativeAdView: NativeAdView!
    private var nativeAdsView: UIView!
    private var cancelNativeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadNativeAds()
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
    
    private func configLoadingView() {
        self.loadingView = UIView()
        self.loadingView.backgroundColor = .white
        self.loadingView.alpha = 0
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.loadingView)
        self.loadingView.fitSuperviewConstraint()
        
        self.titleLabel = UILabel()
        self.titleLabel.text = "Welcome back"
        self.titleLabel.textColor = .black
        self.titleLabel.font = UIFont(name: "Dosis-Bold", size: 35)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.addSubview(self.titleLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.loadingView.centerYAnchor)
        ])
        
        self.indicatorView = UIActivityIndicatorView()
        self.indicatorView.color = .black
        self.indicatorView.style = .large
        self.indicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.addSubview(self.indicatorView)
        NSLayoutConstraint.activate([
            self.indicatorView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20),
            self.indicatorView.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor),
            self.indicatorView.widthAnchor.constraint(equalToConstant: 40),
            self.indicatorView.heightAnchor.constraint(equalToConstant: 40)
        ])
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
        
        self.cancelNativeButton = UIButton()
        self.cancelNativeButton.backgroundColor = .clear
        self.cancelNativeButton.setImage(UIImage(named: "ic_cancle"), for: .normal)
        self.cancelNativeButton.translatesAutoresizingMaskIntoConstraints = false
        self.nativeAdsView.addSubview(self.cancelNativeButton)
        NSLayoutConstraint.activate([
            self.cancelNativeButton.topAnchor.constraint(equalTo: self.nativeAdsView.topAnchor, constant: 50),
            self.cancelNativeButton.trailingAnchor.constraint(equalTo: self.nativeAdsView.trailingAnchor, constant: -16),
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
    private func loadNativeAds() {
        self.nativeAdLoader.loadNativeAd(adCnt: 1, viewController: self) { [weak self] in
            guard let self else { return }
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
        self.indicatorView.startAnimating()
    }
    
    private func dismissLoadingView() {
        self.indicatorView.stopAnimating()
        self.loadingView.alpha = 0
    }
    
    private func showNativeAdsView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self else { return }
            self.nativeAdsView.alpha = 1
        }
    }
    
    // MARK: - Inter Ads
    public func showInterstitialHelperAds(adsBlock: @escaping () -> Void) {
        UtilsADS.shared.isShowAds = true
        
        if UtilsADS.shared.getPurchase(key: KEY_ENCODE.isPremium) {
            adsBlock()
            UtilsADS.shared.isShowAds = false
            return
        }
        
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.keyIsOnNativeFull) { isOn in
            if !isOn {
                adsBlock()
                UtilsADS.shared.isShowAds = false
                return
            } else {
                self.showLoadingView(title: "Loading Ads")
                InterstitialHelper().loadAds { [weak self] in
                    guard let self = self else { return }
                    self.dismissLoadingView()
                    self.showNativeAdsView()
                    InterstitialHelper().showAdsNow(viewController: self) {
                        adsBlock()
                    }
                }
            }
        }
    }
}
