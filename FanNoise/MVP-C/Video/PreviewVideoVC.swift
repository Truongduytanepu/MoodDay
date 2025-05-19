//
//  PreviewVideoVC.swift
//  FanNoise
//
//  Created by ADMIN on 4/25/25.
//
import UIKit
import AVKit
import YYImage
import GoogleMobileAds
import FirebaseAnalytics

private struct Const {
    static let lineSpace: CGFloat = 0
    static let interitemSpace: CGFloat = 0
    static let swipeCountToShowTopic: Int = 5
    static let gifSize: CGFloat = 200
    static let timeOutGif = 3.0
    static let adsStep = 4
}

enum VideoCategoryType {
    case trending
    case filtered(idCategory: String)
    case listVideo(videos: [Video])
}

class PreviewVideoVC: BaseVC<PreviewVideoPresenter, PreviewVideoView> {
    
    @IBOutlet private weak var navigationView: UIView!
    @IBOutlet private weak var bannerContentView: UIView!
    @IBOutlet private weak var bannerContainView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var introGIFView: YYAnimatedImageView?
    private var bannerView: BannerView!
    private var nativeAdsLoader = SLNativeAdsLoader()
    var completion: ((Bool) -> Void)?
    var videoCategoryType: VideoCategoryType = .trending
    var idCategory: String = ""
    var targetIndexPath: IndexPath?
    
    var coordinator: PreviewVideoCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.autoPlayVideo()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.didChangeConnectNetworkActivity, object: nil)
    }
    
    override func viewDidFirstAppear() {
        super.viewDidFirstAppear()
        self.configNativeAdsLoader()
    }
    
    private func config() {
        self.configBannerView()
        self.setupAdaptiveBanner()
        self.showIntroGIF()
        self.setupCollectionView()
        self.setUpNotification()
        self.configNetwork()
        self.setUpData()
    }
    
    private func configNetwork() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationNetwork), name: Notification.Name.didChangeConnectNetworkActivity, object: nil)
    }
    
    @objc private func notificationNetwork() {
        if MonitorNetwork.shared.isConnectedNetwork() {
            self.collectionView.reloadData()
        } else {
            self.postAlert("Notification", message: "No Internet") { [weak self] in
                guard let self = self else {return}
                self.notificationNetwork()
            }
        }
    }
    
    private func setUpData() {
        switch self.videoCategoryType {
        case .trending:
            self.navigationView.isHidden = true
            self.bannerContainView.isHidden = true
            self.collectionView.isHidden = false
            self.presenter.getAllVideo()
        case .filtered(let idCategory):
            self.navigationView.isHidden = false
            self.bannerContainView.isHidden = false
            self.collectionView.alpha = 0
            self.presenter.loadData(idCategory: idCategory)
        case .listVideo(videos: let videos):
            self.bannerContainView.isHidden = false
            self.navigationView.isHidden = false
            self.collectionView.alpha = 0
            self.presenter.updateDataListVideo(videos: videos)
        }
    }
    
    private func autoPlayVideo() {
        switch self.videoCategoryType {
        case .trending:
            self.startVideo()
       case .filtered(idCategory: _), .listVideo(videos: _):
            break
        }
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.collectionView.registerCell(type: ItemVideoCell.self)
        self.collectionView.registerCell(type: TopicSuggestVideoCell.self)
        self.collectionView.registerCell(type: AdsPreviewVideoCell.self)
    }
    
    private func setUpNotification() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(appInterrupted),
                name: AVAudioSession.interruptionNotification,
                object: nil)
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(appMovedToBackground),
                name: UIApplication.willResignActiveNotification,
                object: nil
            )
            
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func scrollToIndexPath() {
        guard let initialIndexPath = self.targetIndexPath else { return }
        self.collectionView.scrollToItem(at: initialIndexPath, at: .top, animated: false)
        self.collectionView.alpha = 1
    }
    
    func stopVideo() {
        if let cell = collectionView.getCurrentCell() as? ItemVideoCell {
            cell.stopVideo()
        }
    }
    
    private func startVideo() {
        if let cell = collectionView.getCurrentCell() as? ItemVideoCell {
            cell.startVideo()
        }
    }
    
    private func showIntroGIF() {
        if !AppManager.shared.hasSeenIntroGif() {
            guard let path = Bundle.main.path(forResource: "gift_intro_2", ofType: "gif"),
                  let image = YYImage(contentsOfFile: path) else {
                return
            }
            
            let gifView = YYAnimatedImageView(image: image)
            gifView.contentMode = .scaleAspectFit
            gifView.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(gifView)
            NSLayoutConstraint.activate([
                gifView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                gifView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                gifView.widthAnchor.constraint(equalToConstant: Const.gifSize),
                gifView.heightAnchor.constraint(equalToConstant: Const.gifSize)
            ])
            self.view.bringSubviewToFront(gifView)
            self.introGIFView = gifView
            
            AppManager.shared.setHasSeenIntroGif()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Const.timeOutGif) { [weak self] in
                self?.introGIFView?.removeFromSuperview()
            }
        }
    }
    
    @objc private func appMovedToBackground() {
        self.stopVideo()
    }
    
    @objc private func appInterrupted(notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        switch type {
        case .began:
            self.stopVideo()
            
        case .ended:
            break
            
        @unknown default:
            break
        }
    }
    
    private func configNativeAdsLoader() {
        self.nativeAdsLoader.delegate = self
        
        if !UtilsADS.shared.getPurchase(key: KEY_ENCODE.isPremium) {
            self.nativeAdsLoader.loadNativeAd(key: UtilsADS.keyNativeListTrending, rootViewController: self) { [weak self] in
                guard let self = self else {return}
                
                self.scrollInMainThread()
            }
        } else {
            self.presenter.updateListNativeAds(listNativeAd: [])
            self.scrollInMainThread()
        }
    }
    
    private func scrollInMainThread() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.performBatchUpdates(nil) { _ in
                self.scrollToIndexPath()
            }
        }
    }
    
    private func configureAdsCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: AdsPreviewVideoCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        let adsIndex: Int
        switch videoCategoryType {
        case .trending:
            adsIndex = (indexPath.row + 1) / (Const.swipeCountToShowTopic + 1) - 1
       case .filtered(idCategory: _), .listVideo(videos: _):
            adsIndex = (indexPath.row + 1) / (Const.adsStep + 1) - 1
        }
        
        let listNativeAds = self.presenter.getListNativeAd()
        if adsIndex >= 0 && adsIndex < listNativeAds.count {
            cell.bind(nativeAd: listNativeAds[adsIndex])
        }
        
        return cell
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
                self.collectionView.reloadData()
                return
            }
            
            self.bannerContentView.isHidden = false
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
    
    private func isAdsPosition(at indexPath: IndexPath) -> Bool {
        return (indexPath.row + 1) % (Const.adsStep + 1) == 0
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.showInterstitialHelperAdsWithCapping { [weak self] in
            guard let self = self else {
                return
            }
            
            self.coordinator.stop()
        }
    }
}

extension PreviewVideoVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? ItemVideoCell {
            cell.stopVideo()

            var video: Video?

            switch self.videoCategoryType {
            case .trending:
                let index = indexPath.row
                let groupSize = Const.adsStep + 2
                let positionInGroup = index % groupSize
                let groupIndex = index / groupSize
                
                if positionInGroup < Const.adsStep {
                    let videoIndex = groupIndex * Const.adsStep + positionInGroup
                    video = self.presenter.getVideo(at: videoIndex)
                }

           case .filtered(idCategory: _), .listVideo(videos: _):
                if self.isAdsPosition(at: indexPath) && !self.presenter.getListNativeAd().isEmpty {
                    return
                }
                
                let adCountBefore = (indexPath.row + 1) / (Const.adsStep + 1)
                let videoIndex = !self.presenter.getListNativeAd().isEmpty ? (indexPath.row - adCountBefore) : indexPath.row
                video = self.presenter.getVideo(at: videoIndex)
            }

            if let video = video {
                Analytics.logEvent("Preview Video", parameters: [
                    "name": "PV_\(video.name?.replaceSpaceAnalytics() ?? "")"
                ])
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? ItemVideoCell {
            cell.startVideo()
        }
    }
}

extension PreviewVideoVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        switch self.videoCategoryType {
        case .trending:
                let hasAds = !presenter.getListNativeAd().isEmpty
                let groupSize = Const.adsStep + (hasAds ? 2 : 1)
                let positionInGroup = indexPath.row % groupSize
                let groupIndex = indexPath.row / groupSize
                
                if positionInGroup < Const.adsStep {
                    let videoIndex = groupIndex * Const.adsStep + positionInGroup
                    let video = self.presenter.getVideo(at: videoIndex)

                    if video.isPlay {
                        self.stopVideo()
                    } else {
                        self.startVideo()
                    }
                }
            
                return

       case .filtered(idCategory: _), .listVideo(videos: _):
            if self.isAdsPosition(at: indexPath) && !self.presenter.getListNativeAd().isEmpty {
                return
            }
            
            let adCountBefore = (indexPath.row + 1) / (Const.adsStep + 1)
            let videoIndex = !self.presenter.getListNativeAd().isEmpty ? (indexPath.row - adCountBefore) : indexPath.row
            let video = self.presenter.getVideo(at: videoIndex)

            if video.isPlay {
                self.stopVideo()
            } else {
                self.startVideo()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let totalItems = self.presenter.getNumberOfItems(adsStep: Const.adsStep)
        var topicCells = 0
        
        switch self.videoCategoryType {
        case .trending:
            topicCells = totalItems / Const.swipeCountToShowTopic
        case .filtered(idCategory: _), .listVideo(videos: _):
            topicCells = 0
        }
        
        return totalItems + topicCells
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.videoCategoryType {
        case .trending:
            let hasAds = !presenter.getListNativeAd().isEmpty
            let groupSize = Const.adsStep + (hasAds ? 2 : 1)
            let positionInGroup = indexPath.row % groupSize
            let groupIndex      = indexPath.row / groupSize
            
            if positionInGroup < Const.adsStep {
                let videoIndex = groupIndex * Const.adsStep + positionInGroup
                guard let cell = collectionView.dequeueCell(type: ItemVideoCell.self,
                                                            indexPath: indexPath) else {
                    return UICollectionViewCell()
                }
                
                let video = presenter.getVideo(at: videoIndex)
                cell.configure(with: video.source ?? "", video: video)
                cell.setUpCategoryType(videoCategoryType: videoCategoryType)
                return cell
                
            } else if hasAds && positionInGroup == Const.adsStep {
                return configureAdsCell(at: indexPath)
                
            } else {
                guard let cell = collectionView.dequeueCell(type: TopicSuggestVideoCell.self,
                                                            indexPath: indexPath) else {
                    return UICollectionViewCell()
                }
                
                let cats = presenter.getVideocategory()
                cell.cofigData(videoCategories: cats)
                cell.callBackUpdateData = { [weak self] name in
                    Analytics.logEvent("Preview Video", parameters: [
                        "name": "PV_Select_\(name.replaceSpaceAnalytics())"
                    ])
                    self?.presenter.updateData(name: name)
                }
                
                return cell
            }
            
       case .filtered(idCategory: _), .listVideo(videos: _):
            if self.isAdsPosition(at: indexPath) && !self.presenter.getListNativeAd().isEmpty {
                return self.configureAdsCell(at: indexPath)
            } else {
                guard let cell = collectionView.dequeueCell(type: ItemVideoCell.self, indexPath: indexPath) else {
                    return UICollectionViewCell()
                }
                
                let adCountBefore = (indexPath.row + 1) / (Const.adsStep + 1)
                let videoIndex = !self.presenter.getListNativeAd().isEmpty ? (indexPath.row - adCountBefore) : indexPath.row
                let video = self.presenter.getVideo(at: videoIndex)
                
                cell.setUpCategoryType(videoCategoryType: self.videoCategoryType)
                cell.configure(with: video.source ?? "", video: video)
                return cell
            }
        }
    }
}

extension PreviewVideoVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Const.lineSpace
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Const.interitemSpace
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

extension PreviewVideoVC: PreviewVideoView {
    func updateUI() {
        let firstItemIndexPath = IndexPath(row: 0, section: 0)
        
        self.collectionView.scrollToItem(at: firstItemIndexPath, at: .top, animated: false)
        self.collectionView.reloadData()
    }
}

extension PreviewVideoVC: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        switch self.videoCategoryType {
        case .trending:
            self.bannerContainView.isHidden = true
        case .filtered(idCategory: _), .listVideo(videos: _):
            self.bannerContainView.isHidden = false
        }
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        self.bannerContainView.isHidden = true
        self.collectionView.reloadData()
    }
    
    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
    }
}

extension PreviewVideoVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCells = self.collectionView.visibleCells
        
        var hasDominantAdsCell = false
        for cell in visibleCells {
            if let adsCell = cell as? AdsPreviewVideoCell {
                let cellFrame = adsCell.convert(adsCell.bounds, to: self.view)
                let cellVisibleHeight = cellFrame.intersection(self.view.bounds).height
                if cellVisibleHeight > (self.view.bounds.height * 0.5) {
                    hasDominantAdsCell = true
                    break
                }
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.bannerContentView.alpha = hasDominantAdsCell ? 0 : 1
            self.completion?(hasDominantAdsCell)
        }
    }
}

extension PreviewVideoVC: SLNativeAdsLoaderDelegate {
    func slNativeAdsLoader(_ loader: SLNativeAdsLoader, didFinishLoading nativeAds: [NativeAd]) {
        self.presenter.updateListNativeAds(listNativeAd: nativeAds)
        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
            
            self.collectionView.performBatchUpdates(nil) { _ in
                self.scrollToIndexPath()
            }
        }
    }
}
