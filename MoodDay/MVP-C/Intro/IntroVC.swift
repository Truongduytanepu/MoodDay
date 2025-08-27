//
//  IntroVC.swift
//  MoodDay
//
//  Created by Trương Duy Tân on 26/8/25.
//

import UIKit

class IntroVC: BaseVC<IntroPresenter, IntroView> {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var pageControlView1: UIView!
    @IBOutlet private weak var pageControlView2: UIView!
    @IBOutlet private weak var pageControlView3: UIView!
    
    var coordinator: IntroCoordinator!
    private var lastPage: Int = 0
    private var currentPage: Int = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    func config() {
        self.setUpScrollView()
        self.setUpPageControl(currentPage: 0)
    }
    
    private func setUpScrollView() {
        self.scrollView.delegate = self
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
    }
    
    private func setUpPageControl(currentPage: Int) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
            self.pageControlView1.backgroundColor = currentPage == 0 ? UIColor(rgb: 0xFF6A46) : UIColor(rgb: 0x000000, alpha: 0.1)
            self.pageControlView2.backgroundColor = currentPage == 1 ? UIColor(rgb: 0x39C870) : UIColor(rgb: 0x000000, alpha: 0.1)
            self.pageControlView3.backgroundColor = currentPage == 2 ? UIColor(rgb: 0xFFC339) : UIColor(rgb: 0x000000, alpha: 0.1)
        }, completion: { _ in
            // Chỉ rung khi chuyển page
            if self.lastPage != currentPage {
                if currentPage == 0 {
                    self.pageControlView1.shake()
                } else if currentPage == 1 {
                    self.pageControlView2.shake()
                } else if currentPage == 2 {
                    self.pageControlView3.shake()
                }
                self.lastPage = currentPage
            }
        })
    }
    
    private func goToPage(_ page: Int, animated: Bool = true) {
        let x = CGFloat(page) * scrollView.frame.width
        self.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }
    
    @IBAction func nextToIntro2DidTapped(_ sender: Any) {
        self.goToPage(1)
    }
    
    @IBAction func nextToIntro3DidTapped(_ sender: Any) {
        self.goToPage(2)
    }
    
    @IBAction func navigationToNextScreen(_ sender: Any) {
        
    }
    
}

// MARK: - Protocol
extension IntroVC: IntroView {}

// MARK: - UIScrollViewDelegate
extension IntroVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0 // Khóa trục dọc
        let currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        self.currentPage = currentPage
        self.setUpPageControl(currentPage: currentPage)
    }
}
