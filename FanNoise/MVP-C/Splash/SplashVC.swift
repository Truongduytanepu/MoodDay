//
//  SplashVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 21/04/2025.
//

import UIKit
import GoogleMobileAds
import AppTrackingTransparency
import AdjustSdk
import AdSupport

private struct Const {
    static let TimeInterval = 0.02
}

class SplashVC: UIViewController {
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var loadingLabel: UILabel!
    
    private var appOpenAd: AppOpenAd?
    private var loadAdStartTime: Date?
    private var loadAdTimeoutTimer: Timer?
    private var isNetworkAvailable = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupGradient()
        self.requestPermissionATTracking()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.customProgressView()
    }
    
    // MARK: - Config
    private func config() {
        self.setupFont()
    }
    
    private func setupFont() {
        self.loadingLabel.font = AppFont.font(.mPLUS2Regular, size: 9)
        self.titleLabel.font = AppFont.font(.mPLUS2Bold, size: 24)
        self.descriptionLabel.font = AppFont.font(.mPLUS2Regular, size: 13)
    }
    
    private func requestPermissionATTracking() {
        ATTrackingManager.requestTrackingAuthorization {[weak self] (status) in
            guard let self = self else {return}
            switch status {
            case .denied:
                DispatchQueue.main.async {
                    self.startLoading()
                    self.configAdj()
                }
                
            case .notDetermined:
                self.configAdj()
            case .restricted:
                self.configAdj()
            case .authorized:
                DispatchQueue.main.async {
                    self.startLoading()
                    self.configAdj(token: self.getDeviceIdentifier()?.uuidString ?? "96h0y7wnhmo0")
                }
                
            @unknown default:
                fatalError("Invalid authorization status")
            }
        }
    }
    
    private func getDeviceIdentifier() -> UUID? {
        // Lấy IDFA nếu được phép
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier
        }
        
        // Fallback: IDFV + Keychain
        return UIDevice.current.identifierForVendor
    }
    
    private func configAdj(token: String = "96h0y7wnhmo0") {
        let yourAppToken = token
        let event = ADJEvent(eventToken: yourAppToken)
        Adjust.trackEvent(event)
    }
    
    private func setupGradient() {
        // Tạo một gradient layer
        let gradientLayer = CAGradientLayer()
        
        // Đặt kích thước layer
        gradientLayer.frame = view.bounds
        
        // Đặt màu cho gradient
        gradientLayer.colors = [
            UIColor(rgb: 0xEDFFE8).cgColor,
            UIColor(rgb: 0xE5F0FF).cgColor
        ]
        
        // Thêm gradient layer vào view
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func customProgressView() {
        self.progressView.layoutIfNeeded()
        self.progressView.progressTintColor = UIColor(rgb: 0x2D2C2B)
        self.progressView.trackTintColor = UIColor.lightGray.withAlphaComponent(0.3)
        self.progressView.layer.cornerRadius = self.progressView.frame.height / 2
        self.progressView.clipsToBounds = true
        self.progressView.subviews.first?.clipsToBounds = true
    }
    
    private func updateProgress(to value: Float) {
        self.progressView.setProgress(value, animated: true)
        self.loadingLabel.text = "loading \(Int(value * 100))%"
    }
    
    private func startLoading() {
        var progress: Float = 0.0
        Timer.scheduledTimer(withTimeInterval: Const.TimeInterval, repeats: true) { [ weak self ] timer in
            guard let self = self else { return }
            if progress >= 1.0 {
                timer.invalidate()
                self.checkNetworkConnection()
            } else {
                progress += 0.01
                self.updateProgress(to: progress)
            }
        }
    }
    
    private func navigateNextScreen() {
        guard let navigationController = self.navigationController else {return}
        if !UserDefaults.standard.bool(forKey: "isFirstShowIntro") {
            // Chưa xem intro -> vào intro
            let introCoordinator = IntroCoordinator(navigation: navigationController)
            introCoordinator.start()
        } else if !UserDefaults.standard.bool(forKey: "isFirstShowLanguageScreen") {
            // Đã xem intro nhưng chưa chọn ngôn ngữ -> vào language
            let languageCoordinator = LanguageCoordinator(navigation: navigationController)
            languageCoordinator.start()
        } else {
            // Đã xem intro + đã chọn ngôn ngữ -> vào Tabbar
            let tabbarCoordinator = TabbarCoordinator(navigation: navigationController)
            tabbarCoordinator.start()
        }
    }
    
    private func checkNetworkConnection() {
        // Kiểm tra kết nối mạng
        let reachability = try? Reachability()
        self.isNetworkAvailable = reachability?.connection != .unavailable
        
        let block = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self = self else { return }
                self.navigateNextScreen()
            }
        }
        
        if self.isNetworkAvailable {
            RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.keyIsOnAoaSplash) { [weak self] isOn in
                guard let self = self else { return }
                if !isOn {
                    block()
                    return
                } else {
                    self.loadAppOpenAd()
                    self.startLoadAdTimeoutTimer()
                }
            }
        } else {
            block()
        }
    }
    
    private func startLoadAdTimeoutTimer() {
        // Timer 10 giây
        self.loadAdTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            print("Load AOA timeout after 10 seconds")
        }
    }
    
    private func loadAppOpenAd() {
        self.loadAdStartTime = Date()
        
        let request = Request()
        AppOpenAd.load(with: UtilsADS.keyAoaSplash, request: request) { [weak self] ads, error in
            
            guard let self = self else { return }
            
            // Hủy timer khi nhận được kết quả
            self.loadAdTimeoutTimer?.invalidate()
            self.loadAdTimeoutTimer = nil
            
            if let error = error {
                print("Load AOA failed: \(error.localizedDescription)")
                self.navigateNextScreen()
                return
            }
            
            self.appOpenAd = ads
            self.appOpenAd?.fullScreenContentDelegate = self
            self.tryToPresentAd()
        }
    }
    
    private func tryToPresentAd() {
        guard let appOpenAd = self.appOpenAd,
              let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            self.navigateNextScreen()
            return
        }
        
        appOpenAd.present(from: rootViewController)
    }
}

extension SplashVC: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ads: FullScreenPresentingAd) {
        self.navigateNextScreen()
    }
    
    func ad(_ ads: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.navigateNextScreen()
    }
}

enum Connection {
    case unavailable
    case wifi
    case cellular
}

class Reachability {
    var connection: Connection = .wifi
    init() throws {}
}

extension UIApplication {
    func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap { $0 as? UIWindowScene }?.windows
            .first(where: \.isKeyWindow)
    }
}

extension SplashVC: SplashView {
    
}
