//
//  NaturalSoundWhiteNoiseVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 28/04/2025.
//

import UIKit
import GoogleMobileAds
import FirebaseAnalytics

private struct Const {
    static let ratioCell: CGFloat = 336 / 99
    static let cellSpacing: CGFloat = 12
    static let insetForSectionAt = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
}

class NaturalSoundWhiteNoiseVC: BaseVC<NaturalSoundWhiteNoisePresenter, NaturalSoundWhiteNoiseView> {
    
    @IBOutlet private weak var bannerContentView: UIView!
    @IBOutlet private weak var bannerContainView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Lifecycle
    var categoryName : String = ""
    var categoryId : String = ""
    private var soundData: [SoundCategory] = []
    private var bannerView: BannerView!
    var coordinator: NaturalSoundWhiteNoiseCoordinator!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    private func config() {
        self.configConllectionView()
        self.setupTitleLabel()
        self.loadData()
        self.configBannerView()
        self.setupAdaptiveBanner()
    }

    private func configConllectionView() {
        self.collectionView.registerCell(type: NaturalSoundWhiteNoiseCell.self)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func loadData() {
        self.soundData = self.presenter.loadData(categoryId: categoryId)
    }
    
    private func setupTitleLabel() {
        self.titleLabel.font = AppFont.font(.mPLUS2Black, size: 16)
        self.titleLabel.text = self.categoryName
    }
    
    private func startListItemSound(navigationController: UINavigationController,
                                    sound: [Sound],
                                    video: [Video],
                                    categoryID: String) {
        let listItemSoundCoordinator = ListItemSoundCoordinator(navigation: navigationController,
                                                                sound: sound,
                                                                video: video,
                                                                categoryID: categoryID)
          listItemSoundCoordinator.start()
    }
    
    private func setupAdaptiveBanner() {
        let adaptiveSize = adSizeFor(cgSize: CGSize(width: UIScreen.main.bounds.width, height: 50))
        self.bannerView = BannerView(adSize: adaptiveSize)
        self.addBannerViewToView(bannerView)
    }
    
    private func addBannerViewToView(_ bannerView: BannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.bannerContentView.addSubview(bannerView)
    }
    
    private func configBannerView() {
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.keyIsOnBanner) { [weak self] isOn in
            guard let self = self else { return }
            if !isOn {
                self.bannerContainView.isHidden = true
                return
            }
            
            self.bannerContainView.isHidden = false
            self.bannerView.delegate = self
            self.bannerView.rootViewController = self
            self.bannerView.adUnitID = UtilsADS.keyBanner
            self.bannerView.paidEventHandler = { adValue in
                UtilsADS.shared.logEventCC(adFormat: "collapsible", revenue:adValue.value.doubleValue)
            }
            
            self.loadBannerAds()
        }
    }
    
    private func loadBannerAds() {
        let request = InterstitialHelper.makeCollapsibleBannerRequest()
        self.bannerView.load(request)
    }
    
    @IBAction private func backButtonDidTap(_ sender: Any) {
        self.showInterstitialHelperAdsWithCapping { [weak self] in
            guard let self = self else {return}
            self.coordinator.stop()
        }
    }
}

extension NaturalSoundWhiteNoiseVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.disableInteractiveFor(seconds: 1)

        self.showInterstitialHelperAdsWithCapping { [weak self] in
            guard let self = self else {
                return
            }
            
            guard let navigationController = self.navigationController else { return }
            
            let sounds = self.soundData[indexPath.row]
            let soundByName = self.presenter.getSoundByCategoryName(nameCategory: sounds.name ?? "")
            let videoByName = self.presenter.getVideoByCategoryName(nameCategory: sounds.name ?? "")
            
            Analytics.logEvent("Natural Sound White Noise", parameters: [
                "name": "NSWN_Category_\(sounds.name?.replaceSpaceAnalytics() ?? "")"
            ])
            
            self.startListItemSound(navigationController: navigationController,
                                    sound: soundByName,
                                    video: videoByName,
                                    categoryID: self.categoryId)
        }
    }
}

extension NaturalSoundWhiteNoiseVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter.getNumberOfItems(categoryId: categoryId)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: NaturalSoundWhiteNoiseCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        cell.configure(soundCategory: soundData[indexPath.row])
        return cell
    }
}

extension NaturalSoundWhiteNoiseVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.width - Const.cellSpacing
        let height = width / Const.ratioCell
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Const.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Const.insetForSectionAt
    }
}

extension NaturalSoundWhiteNoiseVC: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        self.bannerContainView.isHidden = false
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("Load ads for banner error: \(error)")
        self.bannerContainView.isHidden = true
    }

    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
    }
}

extension NaturalSoundWhiteNoiseVC: NaturalSoundWhiteNoiseView {
    
}
