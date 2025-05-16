//
//  ListItemSoundByHashtagVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 02/05/2025.
//

import UIKit
import GoogleMobileAds
import FirebaseAnalytics

private struct Const {
    static let insetLeftRightSound: CGFloat = 13
    static let minimumInteritemSpacingSound: CGFloat = 14
    static let minimumLineSpacingSound: CGFloat = 16
    static let ratioCellSound: CGFloat = 160 / 215
    static let numberColumsSound: CGFloat = 2
    static let insetForSectionAt = UIEdgeInsets(top: 0, left: 13, bottom: 10, right: 13)
    static let adsStep = 4
}

class ListItemSoundByHashtagVC: BaseVC<ListItemSoundByHashtagPresenter, ListItemSoundByHashtagView> {
    @IBOutlet private weak var bannerContentView: UIView!
    @IBOutlet private weak var hashtagLabel: UILabel!
    @IBOutlet private weak var bannerContainView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var coordinator: ListItemSoundByHashtagCoordinator!
    var nameHashtag : String = ""
    var videos: [Video] = []
    private var nativeAdsLoader = SLNativeAdsLoader()
    private var bannerView: BannerView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    // MARK: - Config
    private func config() {
        self.setupCollectionView()
        self.setupUI()
        self.configBannerView()
        self.setupAdaptiveBanner()
        self.loadData()
    }
    
    private func loadData() {
        self.presenter.loadSoundByHashtag(self.nameHashtag)
    }
    
    override func viewDidFirstAppear() {
        super.viewDidFirstAppear()
        self.configNativeAdsLoader()
    }
    
    private func setupAdaptiveBanner() {
        let adaptiveSize = adSizeFor(cgSize: CGSize(width: UIScreen.main.bounds.width, height: 50))
        self.bannerView = BannerView(adSize: adaptiveSize)
        self.addBannerViewToView(bannerView)
    }
    
    private func addBannerViewToView(_ bannerView: BannerView) {
        self.bannerContentView.addSubview(bannerView)
    }
    
    private func configBannerView() {
        RemoteConfigHelper.shared.getRemoteConfigWithKey(key: RemoteConfigKey.keyIsOnBanner) { [weak self] isOn in
            guard let self = self else { return }
            if !isOn {
                self.bannerContentView.heightConstraint()?.constant = 0
                self.bannerContainView.isHidden = true
                return
            }
            
            self.bannerContainView.isHidden = false
            self.bannerView.delegate = self
            self.bannerView.rootViewController = self
            self.bannerView.adUnitID = UtilsADS.keyBanner
            self.loadBannerAds()
        }
    }
    
    private func loadBannerAds() {
        let request = InterstitialHelper.makeCollapsibleBannerRequest()
        self.bannerView.load(request)
    }
    
    private func setupCollectionView() {
        self.collectionView.registerCell(type: ListItemSoundByHashtagCell.self)
        self.collectionView.registerCell(type: AdsSoundCell.self)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupUI() {
        self.hashtagLabel.text = "#\(self.nameHashtag)"
        self.hashtagLabel.font = AppFont.font(.mPLUS2Bold, size: 16)
    }
    
    private func startPlaySound(navigationController: UINavigationController,
                                sound: Sound,
                                sounds: [Sound],
                                videos: [Video]) {
        let playSound = PlaySoundCoordinator(navigation: navigationController,
                                             sound: sound,
                                             sounds: sounds,
                                             videos: videos)
        playSound.start()
    }
    
    private func configNativeAdsLoader() {
        self.nativeAdsLoader.delegate = self
        
        if !UtilsADS.shared.getPurchase(key: KEY_ENCODE.isPremium) {
            self.nativeAdsLoader.loadNativeAd(key: UtilsADS.keyNativeListSound, rootViewController: self){}
        } else {
            self.presenter.updateListNativeAds(listNativeAd: [])
        }
    }
    
    private func isAdsPosition(at indexPath: IndexPath) -> Bool {
        return (indexPath.row + 1) % (Const.adsStep + 1) == 0
    }
    
    private func calculateAdjustedIndex(for indexPath: IndexPath) -> Int {
        return indexPath.row - (indexPath.row / Const.adsStep)
    }
    
    private func configureAdsCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: AdsSoundCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        let adsIndex = (indexPath.row / Const.adsStep) - 1
        let listNativeAds = self.presenter.getListNativeAd()
        
        if adsIndex < listNativeAds.count {
            cell.bind(nativeAd: listNativeAds[adsIndex])
        }
        
        return cell
    }
    
    private func configureSoundCell(indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: ListItemSoundByHashtagCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        let adCountBefore = (indexPath.row + 1) / (Const.adsStep + 1)
        let soundIndex = !self.presenter.getListNativeAd().isEmpty ? (indexPath.row - adCountBefore) : indexPath.row
        let sounds = self.presenter.getListSound()
        let sound = sounds[soundIndex]
        
        sound.assignRandomColorsIfNeeded()
        cell.configureSound(sound: sound)
        
        return cell
    }
    
    @IBAction private func backButtonDidTap(_ sender: Any) {
        self.coordinator.stop()
    }
}

extension ListItemSoundByHashtagVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isAdsPosition(at: indexPath) && !self.presenter.getListNativeAd().isEmpty {
            return
        }
        
        self.view.disableInteractiveFor(seconds: 1)
        
        self.showInterstitialHelperAdsWithCapping { [weak self] in
            guard let self = self, let navigationController = self.navigationController else { return }
            
            let sounds = self.presenter.getListSound()
            let adCountBefore = (indexPath.row + 1) / (Const.adsStep + 1)
            let soundIndex = !self.presenter.getListNativeAd().isEmpty ? (indexPath.row - adCountBefore) : indexPath.row
            
            if soundIndex < sounds.count {
                let sound = sounds[soundIndex]
                
                Analytics.logEvent("List Item Sound By Hash Tag", parameters: [
                    "name": "LISBHT_Category_\(sound.name?.replaceSpaceAnalytics() ?? "")"
                ])
                
                self.startPlaySound(
                    navigationController: navigationController,
                    sound: sound,
                    sounds: sounds,
                    videos: self.videos
                )
            }
        }
    }
}

extension ListItemSoundByHashtagVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter.numberOfSoundCategories(adsStep: Const.adsStep)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isAdsPosition(at: indexPath) && !self.presenter.getListNativeAd().isEmpty {
            return self.configureAdsCell(at: indexPath)
        }
        
        return self.configureSoundCell(indexPath: indexPath)
    }
}

extension ListItemSoundByHashtagVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 2 * Const.insetLeftRightSound - Const.minimumLineSpacingSound * (Const.numberColumsSound - 1) ) / Const.numberColumsSound
        let height = width / Const.ratioCellSound
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Const.minimumInteritemSpacingSound
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Const.minimumLineSpacingSound
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Const.insetForSectionAt
    }
}

extension ListItemSoundByHashtagVC: SLNativeAdsLoaderDelegate {
    func slNativeAdsLoader(_ loader: SLNativeAdsLoader, didFinishLoading nativeAds: [NativeAd]) {
        self.presenter.updateListNativeAds(listNativeAd: nativeAds)
        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
}

extension ListItemSoundByHashtagVC: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        self.bannerView.isHidden = false
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("Load ads for banner error: \(error)")
        self.bannerView.isHidden = true
        self.bannerContentView.heightConstraint()?.constant = 0
    }

    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
    }
}

extension ListItemSoundByHashtagVC: ListItemSoundByHashtagView {
    
}
