//
//  BaseVC.swift
//  SetTimer
//
//  Created by Manh Nguyen Ngoc on 02/07/2021.
//

import Foundation
import UIKit
import GoogleMobileAds
import RxSwift

class BaseVC<Presenter, View>: UIViewController, BaseView, FullScreenContentDelegate {
    // MARK: - Property
    private var viewWillAppeared: Bool = false
    private var viewDidAppeared: Bool = false
    
    public var isDisplaying: Bool = false
    public var isPresentAOA: Bool = false
    
    private var loadingView: UIView!
    private var titleLabel: UILabel!
    private var loadingIcon: UIImageView!
    
    private var appOpenAd: AppOpenAd?
    private var retryTimer: Timer?
    private let maxRetryInterval: TimeInterval = 5.0
    
    var disposeBag = DisposeBag()
    
    var presenter: Presenter!
    var isShow = false
    
    static func factory() -> Self {
        let viewController = Self()
        viewController.injectPresenter()
        return viewController
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configNotificationCenter()
        self.configLoadingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isShow = true
        self.isDisplaying = true
        
        if !viewWillAppeared {
            viewWillAppeared = true
            self.viewWillFirstAppear()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !viewDidAppeared {
            viewDidAppeared = true
            self.viewDidFirstAppear()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.isDisplaying = false
        isShow = false
    }
    
    func viewWillFirstAppear() {
        
    }
    
    func viewDidFirstAppear() {
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func configLoadingView() {
        self.loadingView = UIView()
        self.loadingView.backgroundColor = .white
        self.loadingView.alpha = 0
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.loadingView)
        self.loadingView.fitSuperviewConstraint()
        
        let loadingBGImageView = UIImageView(image: UIImage(named: "bg_splash"))
        loadingBGImageView.backgroundColor = .clear
        loadingBGImageView.contentMode = .scaleAspectFill
        loadingBGImageView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.addSubview(loadingBGImageView)
        loadingBGImageView.fitSuperviewConstraint()
        
        self.titleLabel = UILabel()
        self.titleLabel.text = "Welcome back"
        self.titleLabel.textColor = UIColor(rgb: 0x007AFF)
        self.titleLabel.font = AppFont.font(.mPLUS2Bold, size: 20)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.addSubview(self.titleLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.loadingView.bottomAnchor, constant: -40)
        ])
        
        self.loadingIcon = UIImageView(image: UIImage(named: "ic_loading_splash"))
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
        loadingLogo.cornerRadius = 29
        self.loadingView.addSubview(loadingLogo)

        NSLayoutConstraint.activate([
            loadingLogo.topAnchor.constraint(equalTo: self.loadingView.safeAreaLayoutGuide.topAnchor, constant: 270),
            loadingLogo.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor),
            loadingLogo.widthAnchor.constraint(equalToConstant: 100),
            loadingLogo.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        let subTitleLabel = UILabel()
        subTitleLabel.text = "Bedtime fan: white noise aid"
        subTitleLabel.textColor = .black
        subTitleLabel.font = AppFont.font(.mPLUS2Bold, size: 24)
        subTitleLabel.textAlignment = .center
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.addSubview(subTitleLabel)

        NSLayoutConstraint.activate([
            subTitleLabel.topAnchor.constraint(equalTo: loadingLogo.bottomAnchor, constant: 38),
            subTitleLabel.leadingAnchor.constraint(equalTo: self.loadingView.leadingAnchor, constant: 0),
            subTitleLabel.trailingAnchor.constraint(equalTo: self.loadingView.trailingAnchor, constant: 0),
            subTitleLabel.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor)
        ])

        let descLabel = UILabel()
        descLabel.text = "Sleep deeper, dream better with the soothing sound of fans!"
        descLabel.textColor = .black
        descLabel.font = AppFont.font(.mPLUS2Regular, size: 13)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.addSubview(descLabel)

        NSLayoutConstraint.activate([
            descLabel.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: self.loadingView.leadingAnchor, constant: 93),
            descLabel.trailingAnchor.constraint(equalTo: self.loadingView.trailingAnchor, constant: -93),
            descLabel.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor)
        ])
    }
    
    // MARK: - Helper
    func injectPresenter() {
        self.presenter = DIContainer.shared.resolve(Presenter.self, agrument: self as! View)
    }
    
    // MARK: - Alert
    func showAlert(title: String = "", message: String = "", titleButtons: [String] = ["OK"], destructiveIndexs: [Int] = [], action: ((Int) -> Void)? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        titleButtons.forEach { (titleButton) in
            let index = titleButtons.firstIndex(of: titleButton)!
            let style = destructiveIndexs.contains(index) ? UIAlertAction.Style.destructive : UIAlertAction.Style.default
            let alertAction = UIAlertAction.init(title: titleButton, style: style, handler: { (_) in
                action?(index)
            })
            
            alert.addAction(alertAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertEdit(title: String = "", message: String = "", oldValue: String = "", titleButtons: [String] = ["OK"], action: ((Int, String) -> Void)? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField { (textField) in
            textField.text = oldValue
        }
        
        titleButtons.forEach { (titleButton) in
            let index = titleButtons.firstIndex(of: titleButton)!
            let alertAction = UIAlertAction.init(title: titleButton, style: UIAlertAction.Style.default, handler: { (_) in
                
                let textField = alert.textFields?.first!
                action?(index, textField?.text ?? "")
            })
            
            alert.addAction(alertAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - ShowInterstitialHelperAdsWithCapping
    public func showInterstitialHelperAdsWithCapping(adsBlock: @escaping () -> Void) {
        if Reachabilities.isConnectedToNetwork() == false {
            adsBlock()
            return
        }
        
        if UtilsADS.shared.getPurchase(key: KEY_ENCODE.isPremium) {
            adsBlock()
            return
        }
        
        RemoteConfigHelper.shared.getRemoteConfigWithTimeCapping(key: RemoteConfigKey.keyTimeCapping) { [weak self] capping in
            guard let self = self else  { return }
            let showingAdsLastTime = UserDefaults.standard.double(forKey: "showingAdsLastTime")
            let now = Date().timeIntervalSince1970
            if now - showingAdsLastTime >= capping {
                
                RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.keyIsOnNativeFull) { isOn in
                    if isOn {
                        let underNativeController = UnderNativeController()
                        underNativeController.modalTransitionStyle = .crossDissolve
                        underNativeController.modalPresentationStyle = .overFullScreen
                        self.present(underNativeController, animated: true)
                        
                        underNativeController.showNativeFullAndInterstitialHelperAds {
                            adsBlock()
                        }
                    } else {
                        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.keyIsOnInter) { isOn in
                            if !isOn {
                                adsBlock()
                            } else {
                                let underNativeController = UnderNativeController()
                                underNativeController.modalTransitionStyle = .crossDissolve
                                underNativeController.modalPresentationStyle = .overFullScreen
                                self.present(underNativeController, animated: true)
                                
                                underNativeController.showOnlyInterstitialHelperAds {
                                    adsBlock()
                                }
                            }
                        }
                    }
                }
            } else {
                adsBlock()
            }
        }
    }
    
    private func showLoadingView(title: String = "Welcome back") {
        self.titleLabel.text = title
        self.view.bringSubviewToFront(self.loadingView)
        self.loadingView.alpha = 1
        self.startLoadingAnimation()
    }
    
    private func dismissLoadingView() {
        self.loadingView.alpha = 0
        self.stopLoadingAnimation()
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
    
    private func stopLoadingAnimation() {
        self.loadingIcon.layer.removeAllAnimations()
        self.loadingIcon.transform = .identity
    }
    
    private func configNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func didBecomeActiveNotification(_ notification: Notification) {
        if self.isDisplaying && !self.isPresentAOA && !UtilsADS.shared.isShowAds {
            guard let rootVC = UIApplication.shared.getKeyWindow()?.rootViewController else {
                return
            }
            
            self.dismissLoadingView()
            rootVC.dismiss(animated: true, completion: nil)
            
            if Reachabilities.isConnectedToNetwork() == false {
                return
            }
            
            RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.keyIsOnAoaResume) { [weak self] isOn in
                guard let self = self else { return }
                if !isOn {
                    return
                } else {
                    self.loadAppOpenAd()
                }
            }
        }
    }

    // MARK: - AOA
    private func loadAppOpenAd() {
        self.isPresentAOA = true
        self.showLoadingView()
        
        let request = Request()
        AppOpenAd.load(with: UtilsADS.keyAoaResume, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("🔴 Failed to load AOA: \(error.localizedDescription)")
                self.isPresentAOA = false
                self.dismissLoadingView()
                return
            }
            
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            print("🟢 AOA loaded successfully")
            
            self.tryToPresentAd()
        }
    }
    
    private func tryToPresentAd() {
        guard let appOpenAd = self.appOpenAd,
              let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        appOpenAd.paidEventHandler = { adValue in
            UtilsADS.shared.logEventCC(adFormat: "app_open", revenue:adValue.value.doubleValue)
        }
        
        appOpenAd.present(from: rootViewController)
    }
    
    func adDidDismissFullScreenContent(_ ads: FullScreenPresentingAd) {
        print("AOA dismissed")
        self.isPresentAOA = false
        
        guard let rootVC = UIApplication.shared.getKeyWindow()?.rootViewController else {
            return
        }
        
        self.dismissLoadingView()
        rootVC.dismiss(animated: true, completion: nil)
    }
    
    func ad(_ ads: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("AOA failed to present: \(error.localizedDescription)")
        self.dismissLoadingView()
        self.isPresentAOA = false
    }
}
