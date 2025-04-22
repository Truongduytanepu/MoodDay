//
//  SplashVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 21/04/2025.
//

import UIKit

private struct Const {
    static let progressViewCornerRadius = 4
    static let TimeInterval = 0.02
}

class SplashVC: BaseVC<SplashPresenter, SplashView> {
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var fanLabel: UILabel!
    @IBOutlet private weak var loadingLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    // MARK: - Config
    private func config() {
        self.setupGradient()
        self.customProgressView()
        self.startLoading()
        self.setupFont()
    }
    
    private func setupFont() {
        self.loadingLabel.font = AppFont.font(.mPLUS2Regular, size: 9)
        self.fanLabel.font = AppFont.font(.mPLUS2Bold, size: 24)
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
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func customProgressView() {
        self.progressView.progressTintColor = UIColor(rgb: 0x2D2C2B)
        self.progressView.trackTintColor = UIColor.lightGray.withAlphaComponent(0.3)
        self.progressView.layer.cornerRadius = 4
        self.progressView.clipsToBounds = true
        self.progressView.subviews.first?.layer.cornerRadius = CGFloat(Const.progressViewCornerRadius)
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
                self.navigateToNextScreen()
            } else {
                progress += 0.01
                self.updateProgress(to: progress)
            }
        }
    }
    
    private func navigateToNextScreen() {
            if let navigationController = self.navigationController {
                let introCoordinator = IntroCoordinator(navigation: navigationController)
                introCoordinator.start()
            }
        }
}
extension SplashVC: SplashView {
    
}
