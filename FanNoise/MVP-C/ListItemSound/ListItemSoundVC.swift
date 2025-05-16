//
//  ListItemSoundVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 26/04/2025.
//

import UIKit
import GoogleMobileAds
import FirebaseAnalytics

private struct Const {
    static let insetLeftRightSound: CGFloat = 13
    static let minimumInteritemSpacingSound: CGFloat = 14
    static let minimumInteritemSpacingHashtag: CGFloat = 8
    static let minimumLineSpacingSound: CGFloat = 16
    static let minimumLineSpacingHashtag: CGFloat = 0
    static let ratioCellSound: CGFloat = 160 / 215
    static let numberColumsSound: CGFloat = 2
    static let insetForSectionAt = UIEdgeInsets(top: 0, left: 13, bottom: 10, right: 13)
    static let spacingTopLeft : CGFloat = 8
    static let adsStep = 4
}

enum MediaType {
    case sound
    case video
}

class ListItemSoundVC: BaseVC<ListItemSoundPresenter, ListItemSoundView> {
    
    @IBOutlet private weak var bannerContainView: UIView!
    @IBOutlet private weak var videoCollectionView: UICollectionView!
    @IBOutlet private weak var videoButton: UIButton!
    @IBOutlet private weak var soundButton: UIButton!
    @IBOutlet private weak var tabbarView: UIView!
    @IBOutlet private weak var hashtagCollectionView: UICollectionView!
    @IBOutlet private weak var soundCollectionView: UICollectionView!
    @IBOutlet private weak var videoView: UIView!
    @IBOutlet private weak var soundView: UIView!
    @IBOutlet private weak var bannerContentView: UIView!
    
    var coordinator : ListItemSoundCoordinator!
    var sounds: [Sound] = []
    var videos: [Video] = []
    var categoryID: String = ""
    private var mediaType: MediaType = .sound
    private var bannerView: BannerView!
    private var nativeAdsLoader = SLNativeAdsLoader()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupTabbar()
    }
    
    // MARK: - Config
    private func config() {
        self.configNativeAdsLoader()
        self.setupHashTagCollectionView()
        self.setupSoundCollectionView()
        self.setupVideoCollectionView()
        self.setupFont()
        self.configBannerView()
        self.setupAdaptiveBanner()
    }

    private func setupFont() {
        self.videoButton.titleLabel?.font = AppFont.font(.mPLUS2Bold, size: 10)
        self.soundButton.titleLabel?.font = AppFont.font(.mPLUS2Bold, size: 10)
    }
    
    private func setupHashTagCollectionView() {
        self.hashtagCollectionView.registerCell(type: ItemHashtagCell.self)
        self.hashtagCollectionView.delegate = self
        self.hashtagCollectionView.dataSource = self
        self.hashtagCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSoundCollectionView() {
        self.soundCollectionView.registerCell(type: ItemSoundCell.self)
        self.soundCollectionView.registerCell(type: AdsSoundCell.self)
        self.soundCollectionView.delegate = self
        self.soundCollectionView.dataSource = self
        self.soundCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupVideoCollectionView() {
        self.videoCollectionView.registerCell(type: VideoCell.self)
        self.videoCollectionView.registerCell(type: AdsVideoCell.self)
        self.videoCollectionView.delegate = self
        self.videoCollectionView.dataSource = self
        self.videoCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupTabbar() {
        self.soundButton.layoutIfNeeded()
        self.videoButton.layoutIfNeeded()
        self.tabbarView.layoutIfNeeded()
        
        self.soundButton.cornerRadius = self.soundButton.frame.height / 2
        self.videoButton.cornerRadius = self.videoButton.frame.height / 2
        self.tabbarView.cornerRadius = self.tabbarView.frame.height / 2
    }
    
    private func startListItemSoundByHashtag (navigationController: UINavigationController,nameHastag: String, videos: [Video]) {
        let listItemSoundByHashtagCoordinator =  ListItemSoundByHashtagCoordinator(navigation: navigationController, nameHashtag: nameHastag, videos: videos)
        listItemSoundByHashtagCoordinator.start()
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
    
    private func startPlayVideo(navigationController: UINavigationController, categoryID: String, targetIndexPath: IndexPath) {
        let playVideo = PreviewVideoCoordinator(navigation: navigationController,
                                                videoCategoryType: .listVideo(videos: self.videos),
                                                targetIndexPath: targetIndexPath)
        playVideo.start()
    }
    
    private func configNativeAdsLoader() {
        self.nativeAdsLoader.delegate = self
        
        if !UtilsADS.shared.getPurchase(key: KEY_ENCODE.isPremium) {
            self.nativeAdsLoader.loadNativeAd(key: UtilsADS.keyNativeListSoundAndVideo, rootViewController: self){}
            return
        }

        self.presenter.updateListNativeAds(listNativeAd: [])
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
    
    private func isAdsPosition(at indexPath: IndexPath) -> Bool {
        return (indexPath.row + 1) % (Const.adsStep + 1) == 0
    }
    
    private func configureHashtagCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = hashtagCollectionView.dequeueCell(type: ItemHashtagCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        let hashtagString = self.presenter.getHashtag(sound: sounds)
        if indexPath.row < hashtagString.count {
            cell.configure(hashtag: hashtagString[indexPath.row])
        }
        
        return cell
    }

    private func configureAdsVideoCell(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: AdsVideoCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        let adsIndex = (indexPath.row / Const.adsStep) - 1
        let listNativeAds = self.presenter.getListNativeAd()
        
        if adsIndex < listNativeAds.count {
            cell.bind(nativeAd: listNativeAds[adsIndex])
        }
        
        return cell
    }
    
    private func configureAdsSoundCell(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
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

        guard let cell = soundCollectionView.dequeueCell(type: ItemSoundCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        let adCountBefore = (indexPath.row + 1) / (Const.adsStep + 1)
        let soundIndex = !self.presenter.getListNativeAd().isEmpty ? (indexPath.row - adCountBefore) : indexPath.row
        
        self.sounds[soundIndex].assignRandomColorsIfNeeded()
        cell.configure(sound: self.sounds[soundIndex])
        
        return cell
    }

    private func configureVideoCell(indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = videoCollectionView.dequeueCell(type: VideoCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        let adCountBefore = (indexPath.row + 1) / (Const.adsStep + 1)
        let videoIndex = !self.presenter.getListNativeAd().isEmpty ? (indexPath.row - adCountBefore) : indexPath.row
        
        self.videos[videoIndex].assignRandomHashtagIfNeeded()
        cell.configure(video: self.videos[videoIndex])
        
        return cell
    }
    
    @IBAction private func backButtonDidTap(_ sender: Any) {
        self.showInterstitialHelperAdsWithCapping { [weak self] in
            guard let self = self else {
                return
            }
            
            self.coordinator.stop()
        }
    }
    
    @IBAction private func soundButonDidTap(_ sender: Any) {
        self.videoButton.backgroundColor = .clear
        self.soundButton.backgroundColor = .black
        self.videoButton.setTitleColor(.black, for: .normal)
        self.soundButton.setTitleColor(.white, for: .normal)
        self.videoView.isHidden = true
        self.soundView.isHidden = false
        self.mediaType = .sound
    }
    
    @IBAction private func videoButtonDidTap(_ sender: Any) {
        self.videoButton.backgroundColor = .black
        self.soundButton.backgroundColor = .clear
        self.videoButton.setTitleColor(.white, for: .normal)
        self.soundButton.setTitleColor(.black, for: .normal)
        self.videoView.isHidden = false
        self.soundView.isHidden = true
        self.mediaType = .video
    }
}

extension ListItemSoundVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let adCountBefore = (indexPath.row + 1) / (Const.adsStep + 1)
        let index = !self.presenter.getListNativeAd().isEmpty ? (indexPath.row - adCountBefore) : indexPath.row
        
        self.view.disableInteractiveFor(seconds: 1)
        
        if collectionView == self.hashtagCollectionView {
            self.showInterstitialHelperAdsWithCapping { [weak self] in
                guard let self = self,
                      let navigationController = self.navigationController else { return }
                
                let nameHashtag = self.presenter.getHashtag(sound: self.sounds)[indexPath.row]
                
                Analytics.logEvent("List Item Sound", parameters: [
                    "name": "LIS_HashTag_\(nameHashtag.replaceSpaceAnalytics())"
                ])
                
                self.startListItemSoundByHashtag(
                    navigationController: navigationController,
                    nameHastag: nameHashtag,
                    videos: self.videos
                )
            }
        } else if self.mediaType == .sound {
            self.showInterstitialHelperAdsWithCapping { [weak self] in
                guard let self = self,
                      let navigationController = self.navigationController else { return }
                
                Analytics.logEvent("List Item Sound", parameters: [
                    "name": "LIS_Sound_\(self.sounds[index].name?.replaceSpaceAnalytics() ?? "")"
                ])
                
                if self.isAdsPosition(at: indexPath) && !self.presenter.getListNativeAd().isEmpty {
                    return
                }
                
                self.startPlaySound(
                    navigationController: navigationController,
                    sound: self.sounds[index],
                    sounds: self.sounds,
                    videos: self.videos
                )
            }
        } else {
            self.showInterstitialHelperAdsWithCapping { [weak self] in
                guard let self = self,
                      let navigationController = self.navigationController else { return }
                
                Analytics.logEvent("List Item Sound", parameters: [
                    "name": "LIS_Video_\(self.videos[index].name?.replaceSpaceAnalytics() ?? "")"
                ])
                
                if self.isAdsPosition(at: indexPath) && !self.presenter.getListNativeAd().isEmpty {
                    return
                }
                
                self.startPlayVideo(
                    navigationController: navigationController,
                    categoryID: self.categoryID,
                    targetIndexPath: indexPath
                )
            }
        }
    }
}

extension ListItemSoundVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.hashtagCollectionView {
            return self.presenter.getHashtag(sound: sounds).count
        } else if collectionView == self.soundCollectionView {
            return self.presenter.numberOfSoundCategories(sounds: self.sounds,
                                                          adsStep: Const.adsStep)
        } else if collectionView == self.videoCollectionView {
            return self.presenter.numberOfVideoCategories(videos: self.videos,
                                                          adsStep: Const.adsStep)
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.hashtagCollectionView {
            return self.configureHashtagCell(at: indexPath)
        }
        
        if collectionView == self.soundCollectionView {
            if self.isAdsPosition(at: indexPath) && !self.presenter.getListNativeAd().isEmpty {
                return configureAdsSoundCell(at: indexPath, in: collectionView)
            } else {
                return self.configureSoundCell(indexPath: indexPath)
            }
        } else if collectionView == self.videoCollectionView {
            if self.isAdsPosition(at: indexPath) && !self.presenter.getListNativeAd().isEmpty {
                return configureAdsVideoCell(at: indexPath, in: collectionView)
            } else {
                return self.configureVideoCell(indexPath: indexPath)
            }
        }

        return UICollectionViewCell()
    }
}
extension ListItemSoundVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.hashtagCollectionView {
            let text = self.presenter.getHashtag(sound: sounds)[indexPath.row]
            let sizingLabel = UILabel()
            sizingLabel.font = AppFont.font(.mPLUS2Medium, size: 10)
            sizingLabel.text = text
            
            let width = sizingLabel.intrinsicContentSize.width + 2 * Const.minimumInteritemSpacingHashtag
            let height = sizingLabel.intrinsicContentSize.height + 2 * Const.spacingTopLeft
            
            return CGSize(width: width, height: height)
        } else {
            
            let width = (collectionView.bounds.width - 2 * Const.insetLeftRightSound - Const.minimumLineSpacingSound * (Const.numberColumsSound - 1) ) / Const.numberColumsSound
            let height = width / Const.ratioCellSound
            
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.hashtagCollectionView {
            return Const.minimumInteritemSpacingHashtag
        } else {
            return Const.minimumInteritemSpacingSound
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == hashtagCollectionView {
            return Const.minimumLineSpacingHashtag
        } else {
            return Const.minimumLineSpacingSound
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Const.insetForSectionAt
    }
}

extension ListItemSoundVC: BannerViewDelegate {
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

extension ListItemSoundVC: SLNativeAdsLoaderDelegate {
    func slNativeAdsLoader(_ loader: SLNativeAdsLoader, didFinishLoading nativeAds: [NativeAd]) {
        self.presenter.updateListNativeAds(listNativeAd: nativeAds)
        DispatchQueue.main.async {
            self.soundCollectionView.collectionViewLayout.invalidateLayout()
            self.soundCollectionView.reloadData()
            self.videoCollectionView.collectionViewLayout.invalidateLayout()
            self.videoCollectionView.reloadData()
        }
    }
}

extension ListItemSoundVC: ListItemSoundView {
    
}
