//
//  SplashVC.swift
//  MoodDay
//
//  Created by Trương Duy Tân on 26/8/25.
//

import UIKit

class SplashVC: UIViewController {
    @IBOutlet private weak var progressContainerView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    func config() {
        self.setUpProgressView()
    }
    
    private func setUpProgressView() {
        let progressBar = CustomProgressView()
        progressBar.progress = 0.15
        progressBar.translatesAutoresizingMaskIntoConstraints = false

        self.progressContainerView.addSubview(progressBar)
        progressBar.fitSuperviewConstraint()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            progressBar.animateProgress(to: 1.0, duration: 5.0) { [weak self] in
                guard let self = self else {return}
                self.navigateNextScreen()
            }
        }

    }
    
    private func navigateNextScreen() {
        guard let navigationController = self.navigationController else {return}
//        if !UserDefaults.standard.bool(forKey: "isFirstShowIntro") {
            // Chưa xem intro -> vào intro
            let introCoordinator = IntroCoordinator(navigation: navigationController)
            introCoordinator.start()
//        } else if !UserDefaults.standard.bool(forKey: "isFirstShowLanguageScreen") {
//            // Đã xem intro nhưng chưa chọn ngôn ngữ -> vào language
//            let languageCoordinator = LanguageCoordinator(navigation: navigationController)
//            languageCoordinator.start()
//        } else {
//            // Đã xem intro + đã chọn ngôn ngữ -> vào Tabbar
//            let tabbarCoordinator = TabbarCoordinator(navigation: navigationController)
//            tabbarCoordinator.start()
//        }
    }
}

extension SplashVC: SplashView {
    
}
