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
    private var indicatorView: UIActivityIndicatorView!
    private var titleLabel: UILabel!
    
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
    
    func executeWithAdCheck(_ action: @escaping () -> Void) {
        if UtilsADS.shared.getPurchase(key: KEY_ENCODE.isPremium) {
            action()
        } else {
            self.showInterstitialHelperAdsWithCapping {
                action()
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
    
    public func showInterstitialHelperAdsWithCapping(adsBlock: @escaping () -> Void) {
        if Reachabilities.isConnectedToNetwork() == false {
            adsBlock()
            return
        }
        
        RemoteConfigHelper.shared.getRemoteConfigWithTimeCapping(key: RemoteConfigKey.keyTimeCapping) { capping in
            let showingAdsLastTime = UserDefaults.standard.double(forKey: "showingAdsLastTime")
            let now = Date().timeIntervalSince1970
            if now - showingAdsLastTime >= capping {
                UserDefaults.standard.setValue(now, forKey: "showingAdsLastTime")
                let underNativeController = UnderNativeController()
                underNativeController.modalTransitionStyle = .crossDissolve
                underNativeController.modalPresentationStyle = .overFullScreen
                self.present(underNativeController, animated: true)
                
                underNativeController.showInterstitialHelperAds {
                    adsBlock()
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
        self.indicatorView.startAnimating()
    }
    
    private func dismissLoadingView() {
        self.indicatorView.stopAnimating()
        self.loadingView.alpha = 0
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
    
    private func loadAppOpenAd() {
        self.isPresentAOA = true
        self.showLoadingView()
        
        let request = Request()
        AppOpenAd.load(with: UtilsADS.keyAoaResume, request: request) { [weak self] ads, error in
            guard let self = self else { return }
            
            self.indicatorView.stopAnimating()
            
            if let error = error {
                print("🔴 Failed to load AOA: \(error.localizedDescription)")
                return
            }
            
            self.appOpenAd = ads
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
