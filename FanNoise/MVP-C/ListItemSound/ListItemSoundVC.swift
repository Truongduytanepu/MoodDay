//
//  ListItemSoundVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 26/04/2025.
//

import UIKit

private struct Const {
    static let insetLeftRightSound: CGFloat = 13
    static let minimumInteritemSpacingSound: CGFloat = 14
    static let minimumInteritemSpacingHashtag: CGFloat = 8
    static let minimumLineSpacingSound: CGFloat = 16
    static let minimumLineSpacingHashtag: CGFloat = 0
    static let ratioCellSound: CGFloat = 160 / 215
    static let numberColumsSound: CGFloat = 2
    static let insetForSectionAt = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 13)
    static let spacingTopLeft : CGFloat = 8
}

enum MediaType {
    case sound
    case video
}

class ListItemSoundVC: BaseVC<ListItemSoundPresenter, ListItemSoundView> {
    
    @IBOutlet private weak var videoCollectionView: UICollectionView!
    @IBOutlet private weak var videoButton: UIButton!
    @IBOutlet private weak var soundButton: UIButton!
    @IBOutlet private weak var tabbarView: UIView!
    @IBOutlet private weak var hashtagCollectionView: UICollectionView!
    @IBOutlet private weak var soundCollectionView: UICollectionView!
    @IBOutlet private weak var videoView: UIView!
    @IBOutlet private weak var soundView: UIView!
    
    var coordinator : ListItemSoundCoordinator!
    var sounds: [Sound] = []
    var videos: [Video] = []
    var categoryID: String = ""
    private var mediaType: MediaType = .sound
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupTabbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configNetwork()
    }
    
    // MARK: - Config
    private func config() {
        self.setupHashTagCollectionView()
        self.setupSoundCollectionView()
        self.setupVideoCollectionView()
        self.setupFont()
    }
    
    
    private func configNetwork() {
        if MonitorNetwork.shared.isConnectedNetwork() {
            self.hashtagCollectionView.reloadData()
            self.soundCollectionView.reloadData()
            self.videoCollectionView.reloadData()
        } else {
            self.postAlert("Notification", message: "No Interner") { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.configNetwork()
            }
        }
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
        self.soundCollectionView.delegate = self
        self.soundCollectionView.dataSource = self
        self.soundCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupVideoCollectionView() {
        self.videoCollectionView.registerCell(type: VideoCell.self)
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
                                                videoCategoryType: .filtered(idCategory: categoryID),
                                                targetIndexPath: targetIndexPath)
        playVideo.start()
    }
    
    @IBAction private func backButtonDidTap(_ sender: Any) {
        self.coordinator.stop()
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
        if collectionView == self.hashtagCollectionView {
            guard let navigationController = self.navigationController else { return }
            let nameHashtag = self.presenter.getHashtag(sound: sounds)[indexPath.row]
            self.startListItemSoundByHashtag(navigationController: navigationController,
                                             nameHastag: nameHashtag,
                                             videos: self.videos)
            
        } else {
            switch self.mediaType {
            case .sound:
                guard let navigationController = self.navigationController else { return }
                
                self.startPlaySound(navigationController: navigationController,
                                    sound: sounds[indexPath.row],
                                    sounds: sounds,
                                    videos: videos)
            case .video:
                guard let navigationController = self.navigationController else { return }
                self.startPlayVideo(navigationController: navigationController,
                                    categoryID: self.categoryID,
                                    targetIndexPath: indexPath)
            }
        }
    }
}

extension ListItemSoundVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.hashtagCollectionView {
            return self.presenter.getHashtag(sound: sounds).count
        } else if collectionView == self.soundCollectionView {
            return self.sounds.count
        } else if collectionView == self.videoCollectionView {
            return self.videos.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.hashtagCollectionView {
            guard let cell = collectionView.dequeueCell(type: ItemHashtagCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            
            let hashtagString = self.presenter.getHashtag(sound: sounds)
            cell.configure(hashtag: hashtagString[indexPath.row])
            return cell
        } else if collectionView == self.soundCollectionView {
            guard let cell = collectionView.dequeueCell(type: ItemSoundCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            
            self.sounds[indexPath.row].assignRandomColorsIfNeeded()
            
            cell.configure(sound: sounds[indexPath.row])
            return cell
            
        } else if collectionView == self.videoCollectionView {
            guard let cell = collectionView.dequeueCell(type: VideoCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            
            self.videos[indexPath.row].assignRandomHashtagIfNeeded()
            cell.configure(video: videos[indexPath.row])
            return cell
        } else {
            return UICollectionViewCell()
        }
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

extension ListItemSoundVC: ListItemSoundView {
    
}
