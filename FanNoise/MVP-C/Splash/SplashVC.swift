//
//  SplashVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 21/04/2025.
//

import UIKit

private struct Const {
    static let TimeInterval = 0.02
}

class SplashVC: BaseVC<SplashPresenter, SplashView> {
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var loadingLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupGradient()
    }
    
    // MARK: - Config
    private func config() {
        self.customProgressView()
        self.startLoading()
        self.setupFont()
    }
    
    private func setupFont() {
        self.loadingLabel.font = AppFont.font(.mPLUS2Regular, size: 9)
        self.titleLabel.font = AppFont.font(.mPLUS2Bold, size: 24)
        self.descriptionLabel.font = AppFont.font(.mPLUS2Regular, size: 13)
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
                self.navigateNextScreen()
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
}
extension SplashVC: SplashView {
    
}
