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
        self.scrollToIndexPath()
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
        self.setUpHiddenCollectionView()
        self.showIntroGIF()
        self.setUpData()
        self.setupCollectionView()
        self.setUpNotification()
        self.configNetwork()
        self.setupAdaptiveBanner()
    }
    
    private func configNetwork() {
        NotificationCenter.default.addObserver(self, selector: #selector(notificationNetwork), name: Notification.Name.didChangeConnectNetworkActivity, object: nil)
    }
    
    @objc private func notificationNetwork() {
        if !self.isShow { return }
        
        if !MonitorNetwork.shared.isConnectedNetwork() {
            self.postAlert("Notification", message: "No Interner")
            return
        }
        
        self.collectionView.reloadData()
    }
    
    private func setUpData() {
        switch self.videoCategoryType {
        case .trending:
            self.navigationView.isHidden = true
            self.bannerContainView.isHidden = true
            self.presenter.getAllVideo()
        case .filtered(let idCategory):
            self.navigationView.isHidden = false
            self.bannerContainView.isHidden = false
            self.presenter.loadData(idCategory: idCategory)
        case .listVideo(videos: let videos):
            self.bannerContainView.isHidden = false
            self.navigationView.isHidden = false
            self.presenter.updateDataListVideo(videos: videos)
        }
    }
    
    private func autoPlayVideo() {
        switch self.videoCategoryType {
        case .trending:
            self.startVideo()
        case .filtered(_), .listVideo(_):
            break
        }
    }
    
    private func setUpHiddenCollectionView() {
        switch videoCategoryType {
        case .trending:
            self.collectionView.isHidden = false
        case .filtered(_), .listVideo(_):
            self.collectionView.isHidden = true
        }
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerCell(type: ItemVideoCell.self)
        self.collectionView.registerCell(type: TopicSuggestVideoCell.self)
        self.collectionView.registerCell(type: AdsVideoCell.self)
        self.collectionView.contentInsetAdjustmentBehavior = .never
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
        if let indexPath = self.targetIndexPath {
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            self.collectionView.isHidden = false
        }
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
            self.nativeAdsLoader.loadNativeAd(key: UtilsADS.keyNativeListSound, rootViewController: self)
        } else {
            self.presenter.updateListNativeAds(listNativeAd: [])
        }
    }
    
    private func configureAdsCell(at indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueCell(type: AdsVideoCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            
            let adsIndex: Int
            switch videoCategoryType {
            case .trending:
                adsIndex = (indexPath.row / (Const.swipeCountToShowTopic + 1)) - 1
            case .filtered(_), .listVideo(_):
                adsIndex = (indexPath.row / Const.adsStep) - 1
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
                self.bannerContentView.isHidden = true
                self.collectionView.reloadData()
                return
            }
            
            self.bannerContentView.isHidden = false
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
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.coordinator.stop()
    }
}

extension PreviewVideoVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? ItemVideoCell {
            cell.stopVideo()
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
        let video = self.presenter.getVideo(at: indexPath.row)
        if video.isPlay {
            self.stopVideo()
        } else {
            self.startVideo()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let totalItems = self.presenter.getNumberOfItems(adsStep: Const.adsStep)
        var topicCells = 0
        
        switch self.videoCategoryType {
        case .trending:
            topicCells = totalItems / Const.swipeCountToShowTopic
        case .filtered(idCategory: _):
            topicCells = 0
        case .listVideo(videos: _):
            topicCells = 0
        }
        
        return totalItems + topicCells
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.videoCategoryType {
        case .trending:
            let adjustedIndex = indexPath.row
            
            if (adjustedIndex + 1) % (Const.swipeCountToShowTopic + 1) == 0 && adjustedIndex > 0 {
                return configureAdsCell(at: indexPath)
            } else if adjustedIndex % (Const.swipeCountToShowTopic + 1) == 0 && adjustedIndex > 0 {
                guard let cell = collectionView.dequeueCell(type: TopicSuggestVideoCell.self, indexPath: indexPath) else {
                    return UICollectionViewCell()
                }
                
                let videoCategory = self.presenter.getVideocategory()
                cell.cofigData(videoCategories: videoCategory)
                
                cell.callBackUpdateData = { [weak self] name in
                    self?.presenter.updateData(name: name)
                }
                
                return cell
            } else {
                let videoIndex = adjustedIndex - (adjustedIndex / (Const.swipeCountToShowTopic + 1)) - (adjustedIndex / (Const.swipeCountToShowTopic + 1))
                
                guard let cell = collectionView.dequeueCell(type: ItemVideoCell.self, indexPath: indexPath) else {
                    return UICollectionViewCell()
                }
                
                let video = self.presenter.getVideo(at: videoIndex)
                cell.configure(with: video.source ?? "", video: video)
                cell.setUpCategoryType(videoCategoryType: self.videoCategoryType)
                return cell
            }
            
        case .filtered(_), .listVideo(_):
            if (indexPath.row + 1) % Const.adsStep == 0 && indexPath.row > 0 {
                return self.configureAdsCell(at: indexPath)
            } else {
                let videoIndex = indexPath.row - (indexPath.row / Const.adsStep)
                
                guard let cell = collectionView.dequeueCell(type: ItemVideoCell.self,
                                                            indexPath: indexPath) else {
                    return UICollectionViewCell()
                }
                
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
        self.bannerContentView.isHidden = false
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        self.bannerContentView.isHidden = true
        self.bannerContentView.heightConstraint()?.constant = 0
        self.collectionView.reloadData()
    }

    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
    }
}

extension PreviewVideoVC: SLNativeAdsLoaderDelegate {
    func slNativeAdsLoader(_ loader: SLNativeAdsLoader, didFinishLoading nativeAds: [NativeAd]) {
        self.presenter.updateListNativeAds(listNativeAd: nativeAds)
        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
}
