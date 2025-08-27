//
//  BaseVC.swift
//  SetTimer
//
//  Created by Manh Nguyen Ngoc on 02/07/2021.
//

import Foundation
import UIKit
import AVFoundation
import GoogleMobileAds

class BaseVC<Presenter, View>: UIViewController, BaseView, FullScreenContentDelegate {
    // MARK: - Property
    private var viewWillAppeared: Bool = false
    private var viewDidAppeared: Bool = false
    
    var presenter: Presenter!
    
    public var isDisplaying: Bool = false
    public var isPresentAOA: Bool = false
    
    private var loadingView: UIView!
    private var titleLabel: UILabel!
    private var loadingIcon: UIImageView!
    
    private var appOpenAd: AppOpenAd?
    private var retryTimer: Timer?
    private let maxRetryInterval: TimeInterval = 5.0
    
    var nameScreen = "Base"
    
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
    }
    
    func viewWillFirstAppear() {
        
    }
    
    func viewDidFirstAppear() {
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
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
    
    func showToast(message: String, duration: Double = 1.2) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 15)
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 16
        toastLabel.clipsToBounds = true
        
        let textSize = toastLabel.intrinsicContentSize
        let padding: CGFloat = 24
        let labelWidth = min(self.view.frame.width - 2 * padding, textSize.width + padding)
        let labelHeight: CGFloat = 40
        toastLabel.frame = CGRect(
            x: (self.view.frame.width - labelWidth) / 2,
            y: (self.view.frame.height - labelHeight) / 2,
            width: labelWidth, height: labelHeight
        )
        
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseIn, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
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
    
    public func showInterstitialHelperAdsWithCapping(adsBlock: @escaping () -> Void) {
        if Reachabilities.isConnectedToNetwork() == false {
            adsBlock()
            return
        }
        
        if UtilsADS.shared.getPurchase(key: KEY_ENCODE.isPremium) {
            adsBlock()
            return
        }
        
        let showingAdsLastTime = UserDefaults.standard.double(forKey: "showingAdsLastTime")
        let now = Date().timeIntervalSince1970
        if now - showingAdsLastTime >= UtilsADS.shared.timeCapping {
            if UtilsADS.shared.isOnNativeFull {
                let underNativeController = UnderNativeController()
                underNativeController.modalTransitionStyle = .crossDissolve
                underNativeController.modalPresentationStyle = .overFullScreen
                self.present(underNativeController, animated: true)
                
                underNativeController.showNativeFullAndInterstitialHelperAds {
                    adsBlock()
                }
            } else {
                if !UtilsADS.shared.isOnInter {
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
        } else {
            adsBlock()
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
        if UtilsADS.shared.getPurchase(key: KEY_ENCODE.isPremium) {
            return
        }
        
        if !self.isDisplaying {
            return
        }
        
        if !self.isPresentAOA && !UtilsADS.shared.isShowAds {
            guard let rootVC = UIApplication.shared.getKeyWindow()?.rootViewController else {
                return
            }
            
            self.dismissLoadingView()
            rootVC.dismiss(animated: true, completion: nil)
            
            if Reachabilities.isConnectedToNetwork() == false {
                return
            }
            
            if !UtilsADS.shared.isOnAOAResume {
                return
            } else {
                self.loadAppOpenAd()
            }
        }
    }

    // MARK: - AOA
    private func loadAppOpenAd() {
        self.isPresentAOA = true
        self.showLoadingView()
        
        NotificationCenter.default.post(name: .PauseAllPlayer, object: nil)
        
        let request = Request()
        AppOpenAd.load(with: UtilsADS.key_aoa_resume, request: request) { [weak self] ad, error in
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
        
        NotificationCenter.default.post(name: .ResumeAllPlayer, object: nil)
        
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

extension Notification.Name {
    static let PauseAllPlayer = Notification.Name("PauseAllPlayer")
    static let ResumeAllPlayer = Notification.Name("ResumeAllPlayer")
}
