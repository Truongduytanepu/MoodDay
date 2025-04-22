//
//  IntroVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 21/04/2025.
//

import UIKit
import YYImage

private struct Const {
    static let dotSize = CGSize(width: 6, height: 6)
}

class IntroVC: BaseVC<IntroPresenter, IntroView> {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var introViewFirst: UIView!
    @IBOutlet private weak var introViewSecond: UIView!
    @IBOutlet private weak var introViewThird: UIView!
    @IBOutlet private weak var introViewLast: UIView!
    @IBOutlet private weak var adView: UIView!
    @IBOutlet private weak var swipeGif: YYAnimatedImageView!
    
    var coordinator: IntroCoordinator!
    
    private let titles = [
        "Find the perfect fan sound",
        "Not just a sound, but experience",
        "Find the perfect sleep sound",
        "Explore the soothing, sound of fans"
    ]
    // MARK: - Properties
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    // MARK: - Config
    private func config() {
        self.setupFont()
        self.setupPageControl()
        self.setupScrollView()
        self.setupGIF()
    }
    
    private func setupFont() {
        self.continueButton.titleLabel?.font = AppFont.font(.mPLUS2Bold, size: 16)
        self.titleLabel.font = AppFont.font(.mPLUS2Bold, size: 20)
    }
    
    private func setupScrollView() {
        self.scrollView.delegate = self
        self.scrollView.showsHorizontalScrollIndicator = false
        
        // Sắp xếp các introView cạnh nhau
        let introViews = [introViewFirst, introViewSecond, introViewThird, introViewLast]
        for (index, view) in introViews.enumerated() {
            view?.frame.origin.x = CGFloat(index) * scrollView.frame.width
        }
        
        self.scrollView.contentSize = CGSize(
            width: scrollView.frame.width * CGFloat(introViews.count),
            height: scrollView.frame.height
        )
    }
    
    private func setupPageControl() {
        self.pageControl.currentPage = 0
        self.pageControl.addTarget(self, action: #selector(pageControlChanged(_:)), for: .valueChanged)
        self.pageControl.pageIndicatorTintColor = UIColor(rgb: 0x2D2C2B1A).withAlphaComponent(0.1)
        self.pageControl.currentPageIndicatorTintColor = UIColor(rgb: 0x2D2C2B)
        let dotImage = UIImage(named: "ic_image_currentPageIndicator")
        let currentDotImage = UIImage(named: "ic_image_PageIndicator")
        
        self.pageControl.preferredIndicatorImage = dotImage?.resize(to: Const.dotSize)
        self.pageControl.setIndicatorImage(currentDotImage?.resize(to: Const.dotSize), forPage: pageControl.currentPage)
    }
    
    private func setupGIF() {
        if let path = Bundle.main.path(forResource: "gift_intro_2", ofType: "gif") {
            self.swipeGif.image = YYImage.init(contentsOfFile: path)
            self.swipeGif.startAnimating()
        }
    }
    
    // Xử lý khi nhấn nút Continue
    @IBAction private func continueButtonDidTap (_ sender: UIButton) {
        if pageControl.currentPage < pageControl.numberOfPages - 1 {
            // Chưa ở trang cuối → scroll đến trang tiếp theo
            let nextPage = pageControl.currentPage + 1
            let offsetX = CGFloat(nextPage) * self.scrollView.frame.width
            self.scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        } else {
            // Đang ở trang cuối → chuyển màn hình 
            //     coordinator.navigateToHome() // Gọi hàm từ coordinator
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
        self.pageControl.currentPage = currentPage
        
        if currentPage < titles.count {
            self.titleLabel.text = titles[currentPage]
        }
        
        self.adView.isHidden = (currentPage == 1 || currentPage == 3)
        
    }
}
extension IntroVC: IntroView {
    
}
