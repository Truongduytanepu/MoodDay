//
//  LanguageVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 22/04/2025.
//

import UIKit
import FirebaseAnalytics
import GoogleMobileAds

private struct Const {
    static let sizeHeight: Float = 48
    static let minimumInteritemSpacing: CGFloat = 12
    static let insetCollection: CGFloat = 15
}

class LanguageVC: BaseVC<LanguagePresenter, LanguageView> {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var acceptButton: UIButton!
    @IBOutlet private weak var navigationLabel: UILabel!
    @IBOutlet private weak var nativeView: UIView!
    
    var coordinator : LanguageCoordinator!
    private var choseLanguage: Language?
    private var nativeAdLoader = NativeAdLoader()
    private var gadNativeAdView: NativeAdView!
    private var nativeAdsView: UIView!
    
    // MARK: - Lifecycle
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
        self.choseLanguage = LanguageManager.shared.getChoseLanguage()
        self.setupCollectionView()
        self.setupFont()
        self.configNativeAdsView()
    }
    
    private func setupFont() {
        self.navigationLabel.font = AppFont.font(.mPLUS2SemiBold, size: 16)
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerCell(type: LanguageCell.self)
    }
    
    private func navigateToNextScreen() {
        if let navigationController = self.navigationController {
            let tabbarCoordinator = TabbarCoordinator(navigation: navigationController)
            tabbarCoordinator.start()
        }
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
    
    // MARK: - Action
    @IBAction private func acceptButtonDidTap(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "isFirstShowLanguageScreen")
        
        Analytics.logEvent("Language", parameters: [
            "value": "Language_\(self.choseLanguage?.name ?? "")"
        ])
        
        if let choseLanguage = choseLanguage {
            LanguageManager.shared.setChoseLanguage(choseLanguage)
        }
        
        self.navigateToNextScreen()
    }
}

// MARK: - UICollectionViewDelegate
extension LanguageVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath
    ) {
        if let choseLanguage = choseLanguage,
           let cell = collectionView.cellForItem(at: IndexPath(item: choseLanguage.rawValue, section: 0)) as? LanguageCell {
            cell.deselect()
        }
        
        self.choseLanguage = Language.allCases[indexPath.item]
        if let cell = collectionView.cellForItem(at: indexPath) as? LanguageCell {
            cell.select()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension LanguageVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Language.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: LanguageCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        cell.config(language: Language.allCases[indexPath.item])
        if let choseLanguage = choseLanguage, choseLanguage == Language.allCases[indexPath.item] {
            cell.select()
        } else {
            cell.deselect()
        }
        
        return cell
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension LanguageVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - Const.insetCollection * 2, height: CGFloat(Const.sizeHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Const.minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,
                            left: Const.insetCollection,
                            bottom: Const.insetCollection,
                            right: Const.insetCollection)
    }
}

extension LanguageVC: LanguageView {
    
}
