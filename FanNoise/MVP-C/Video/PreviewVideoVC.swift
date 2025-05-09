//
//  PreviewVideoVC.swift
//  FanNoise
//
//  Created by ADMIN on 4/25/25.
//
import UIKit
import AVKit
import YYImage

private struct Const {
    static let lineSpace: CGFloat = 0
    static let interitemSpace: CGFloat = 0
    static let swipeCountToShowTopic: Int = 5
    static let gifSize: CGFloat = 200
    static let timeOutGif = 3.0
}

enum VideoCategoryType {
    case trending
    case filtered(idCategory: String)
    case listVideo(videos: [Video])
}

class PreviewVideoVC: BaseVC<PreviewVideoPresenter, PreviewVideoView> {
    
    @IBOutlet private weak var navigationView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var introGIFView: YYAnimatedImageView?
    var videoCategoryType: VideoCategoryType = .trending
    var idCategory: String = ""
    var targetIndexPath: IndexPath?
    
    var coordinator: PreviewVideoCoordinator!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollToIndexPath()
        self.autoPlayVideo()
        self.configNetwork()
    }
    
    private func config() {
        self.setUpHiddenCollectionView()
        self.showIntroGIF()
        self.setUpData()
        self.setupCollectionView()
        self.setUpNotification()
    }
    
    private func configNetwork() {
        if MonitorNetwork.shared.isConnectedNetwork() {
            self.collectionView.reloadData()
        } else {
            self.postAlert("Notification", message: "No Interner", titleButton: "Try again") { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.configNetwork()
            }
        }
    }
    
    private func setUpData() {
        switch self.videoCategoryType {
        case .trending:
            self.navigationView.isHidden = true
            self.presenter.getAllVideo()
        case .filtered(let idCategory):
            self.navigationView.isHidden = false
            self.presenter.loadData(idCategory: idCategory)
        case .listVideo(videos: let videos):
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
                        numberOfItemsInSection section: Int) -> Int {
        let totalItems = self.presenter.getNumberOfItems()
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
                        didSelectItemAt indexPath: IndexPath) {
        let video = self.presenter.getVideo(at: indexPath.row)
        if video.isPlay {
            self.stopVideo()
        } else {
            self.startVideo()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.videoCategoryType {
        case .trending:
            if (indexPath.row % Const.swipeCountToShowTopic == 0) && indexPath.row > 0 {
                guard let cell = collectionView.dequeueCell(type: TopicSuggestVideoCell.self,
                                                            indexPath: indexPath) else {
                    return UICollectionViewCell()
                }
                
                let videoCategory = self.presenter.getVideocategory()
                
                cell.cofigData(videoCategories: videoCategory)
                
                cell.callBackUpdateData = { [weak self] name in
                    guard let self = self else { return }
                    self.presenter.updateData(name: name)
                }
                
                return cell
            } else {
                let adjustedIndex = indexPath.row - (indexPath.row / Const.swipeCountToShowTopic)
                
                guard let cell = collectionView.dequeueCell(type: ItemVideoCell.self,
                                                            indexPath: indexPath) else {
                    return UICollectionViewCell()
                }
                
                let video = self.presenter.getVideo(at: adjustedIndex)
                cell.configure(with: video.source ?? "", video: video)
                cell.setUpCategoryType(videoCategoryType: self.videoCategoryType)
                return cell
            }
            
        case .filtered(_), .listVideo(videos: _):
            guard let cell = collectionView.dequeueCell(type: ItemVideoCell.self,
                                                        indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            
            let video = self.presenter.getVideo(at: indexPath.row)
            cell.setUpCategoryType(videoCategoryType: self.videoCategoryType)
            cell.configure(with: video.source ?? "", video: video)
            return cell
        }
    }
}

extension PreviewVideoVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
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
