//
//  IntroVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 21/04/2025.
//

import UIKit
import YYImage
import GoogleMobileAds
import FirebaseAnalytics

private struct Const {
    static let dotPageViewSize = CGSize(width: 6, height: 6)
    static let longBottomConstraintContinue: CGFloat = 112
    static let shortBottomConstraintContinue: CGFloat  = 49
    static let longHeightConstraintAds: CGFloat = 200
    static let shortHeightConstraintAds: CGFloat = 0
}

class IntroVC: BaseVC<IntroPresenter, IntroView> {
    @IBOutlet private weak var nativeView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var introFirstView: UIView!
    @IBOutlet private weak var introSecondView: UIView!
    @IBOutlet private weak var introThirdView: UIView!
    @IBOutlet private weak var introFourthView: UIView!
    @IBOutlet private weak var introFifthView: UIView!
    @IBOutlet private weak var introLastView: UIView!
    @IBOutlet private weak var containAdsView: UIView!
    @IBOutlet private weak var bottomConstraintContinue: NSLayoutConstraint!
    @IBOutlet private weak var heightConstraintAds: NSLayoutConstraint!
    
    var coordinator: IntroCoordinator!
    
    private var nativeAdLoader = NativeAdLoader()
    private var gadNativeAdView: NativeAdView!
    private var nativeAdsView: UIView!
    private let titles = [
        "Find the perfect fan sound",
        "Not just a sound, but experience",
        "Find the perfect sleep sound",
        "Explore the soothing, sound of fans",
        "Melt stress away with white noise",
        "Relax Your Mind"
    ]
    
    // MARK: - Life Cycle
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
        self.setupFont()
        self.setupPageControl()
        self.setupScrollView()
        self.configNativeAdsView()
    }
    
    private func setupFont() {
        self.continueButton.titleLabel?.font = AppFont.font(.mPLUS2Bold, size: 16)
        self.titleLabel.font = AppFont.font(.mPLUS2Bold, size: 20)
    }
    
    private func configNativeAdsView() {
        self.nativeAdsView = UIView()
        self.nativeAdsView.backgroundColor = .white
        self.nativeAdsView.translatesAutoresizingMaskIntoConstraints = false
        self.nativeView.addSubview(self.nativeAdsView)
        self.nativeAdsView.fitSuperviewConstraint()
        
        self.gadNativeAdView = Bundle.main.loadNibNamed("IntroNativeAd", owner: nil, options: nil)!.first as! NativeAdView
        self.gadNativeAdView.translatesAutoresizingMaskIntoConstraints = false
        self.nativeAdsView.addSubview(self.gadNativeAdView)
        self.gadNativeAdView.fitSuperviewConstraint()
    }
    
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
    
    private func setupScrollView() {
        self.scrollView.delegate = self
        
        // Sắp xếp các introView cạnh nhau
        let introViews = [self.introFirstView, self.introSecondView, self.introThirdView, self.introFourthView, self.introFifthView, self.introLastView]
        for (index, view) in introViews.enumerated() {
            view?.frame.origin.x = CGFloat(index) * self.scrollView.frame.width
        }
        
        self.scrollView.contentSize = CGSize(
            width: self.scrollView.frame.width * CGFloat(introViews.count),
            height: self.scrollView.frame.height
        )
    }
    
    private func setupPageControl() {
        self.pageControl.currentPage = 0
        self.pageControl.addTarget(self, action: #selector(self.pageControlChanged(_:)), for: .valueChanged)
        self.pageControl.pageIndicatorTintColor = UIColor(rgb: 0x2D2C2B1A).withAlphaComponent(0.1)
        self.pageControl.currentPageIndicatorTintColor = UIColor(rgb: 0x2D2C2B)
        let dotImage = UIImage(named: "ic_image_currentPageIndicator")
        let currentDotImage = UIImage(named: "ic_image_PageIndicator")
        
        let resizedDot = dotImage?.resized(to: Const.dotPageViewSize)
        let resizedCurrentDot = currentDotImage?.resized(to: Const.dotPageViewSize)

        self.pageControl.preferredIndicatorImage = resizedDot
        self.pageControl.setIndicatorImage(resizedCurrentDot, forPage: self.pageControl.currentPage)

    }
    
    private func applyCollapsedAdLayout() {
        self.heightConstraintAds.constant = Const.shortHeightConstraintAds
        self.bottomConstraintContinue.constant = Const.longBottomConstraintContinue
        self.containAdsView.alpha = 0
    }
    
    private func applyExpandedAdLayout() {
        self.heightConstraintAds.constant = Const.longHeightConstraintAds
        self.bottomConstraintContinue.constant = Const.shortHeightConstraintAds
        self.containAdsView.alpha = 1
    }
    
    // Xử lý khi nhấn nút Continue
    @IBAction private func continueButtonDidTap (_ sender: UIButton) {
        if self.pageControl.currentPage < self.pageControl.numberOfPages - 1 {
            // Chưa ở trang cuối → scroll đến trang tiếp theo
            let nextPage = self.pageControl.currentPage + 1
            let offsetX = CGFloat(nextPage) * self.scrollView.frame.width
            self.scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        } else {
            // Đang ở trang cuối → chuyển màn hình 
            UserDefaults.standard.set(true, forKey: "isFirstShowIntro")

            self.navigateToNextScreen()
        }
    }
    
    private func navigateToNextScreen() {
        if let navigationController = self.navigationController {
            let languageCoordinator = LanguageCoordinator(navigation: navigationController)
            languageCoordinator.start()
        }
    }
    
    // Xử lý khi pageControl thay đổi (tap vào dot)
    @objc private func pageControlChanged(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        let offsetX = CGFloat(currentPage) * self.scrollView.frame.width
        self.scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}

extension IntroVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0 // Khóa trục dọc
        
        // Tính toán currentPage dựa trên vị trí scroll
        let currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        let introIndex = currentPage + 1
        self.pageControl.currentPage = currentPage
        
        Analytics.logEvent("Intro", parameters: [
            "name": "Intro_\(introIndex)"
        ])
        
        if currentPage < self.titles.count {
            self.titleLabel.text = self.titles[currentPage]
        }
        
        if currentPage == 1 || currentPage == 3 || currentPage == 5 {
            self.applyCollapsedAdLayout()
            self.nativeAdsView.alpha = 0
        } else {
            self.applyExpandedAdLayout()
            self.nativeAdsView.alpha = 1
        }
    }
}

extension IntroVC: IntroView {
    
}
