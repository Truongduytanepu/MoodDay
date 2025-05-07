//
//  ListItemSoundByHashtagVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 02/05/2025.
//

import UIKit

private struct Const {
    static let insetLeftRightSound: CGFloat = 13
    static let minimumInteritemSpacingSound: CGFloat = 14
    static let minimumLineSpacingSound: CGFloat = 16
    static let ratioCellSound: CGFloat = 160 / 215
    static let numberColumsSound: CGFloat = 2
    static let insetForSectionAt = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 13)
}

class ListItemSoundByHashtagVC: BaseVC<ListItemSoundByHashtagPresenter, ListItemSoundByHashtagView> {
    @IBOutlet private weak var hashtagLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var coordinator: ListItemSoundByHashtagCoordinator!
    var nameHashtag : String = ""
    var videos: [Video] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    // MARK: - Config
    private func config() {
        self.setupCollectionView()
        self.setupUI()
    }
    
    private func setupCollectionView() {
        self.collectionView.registerCell(type: ListItemSoundByHashtagCell.self)
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
    
    @IBAction private func backButtonDidTap(_ sender: Any) {
        self.coordinator.stop()
    }
}

extension ListItemSoundByHashtagVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let navigationController = self.navigationController else { return }
        let sounds = self.presenter.loadSoundByHashtag(nameHashtag: nameHashtag)
        let sound = self.presenter.loadSoundByHashtag(nameHashtag: nameHashtag)[indexPath.row]
        self.startPlaySound(navigationController: navigationController,
                            sound: sound,
                            sounds: sounds,
                            videos: self.videos)
    }
}

extension ListItemSoundByHashtagVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter.getNumberOfItems(nameHashtag: nameHashtag)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: ListItemSoundByHashtagCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        let sound = self.presenter.loadSoundByHashtag(nameHashtag: nameHashtag)[indexPath.row]
        sound.assignRandomColorsIfNeeded()
        cell.configureSound(sound: sound)
        return cell
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

extension ListItemSoundByHashtagVC: ListItemSoundByHashtagView {
    
}
