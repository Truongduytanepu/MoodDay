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
    static let ratioCellSound: CGFloat = 160 / 255
    static let numberColumsSound: CGFloat = 2
    static let insetForSectionAt = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 13)
    static let spacingTopLeft : CGFloat = 8
}

class ListItemSoundVC: BaseVC<ListItemSoundPresenter, ListItemSoundView> {
    
    @IBOutlet private weak var videoButton: DimableView!
    @IBOutlet private weak var soundButton: DimableView!
    @IBOutlet private weak var tabbarView: UIView!
    @IBOutlet private weak var hashtagCollectionView: UICollectionView!
    @IBOutlet private weak var soundCollectionView: UICollectionView!
    
    var categoryId : String = ""
    var coordinator : ListItemSoundCoordinator!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    // MARK: - Config
    func config() {
        self.setupHashTagCollectionView()
        self.setupSoundCollectionView()
        self.setupTabbar()
    }
    
    private func setupHashTagCollectionView() {
        self.hashtagCollectionView.registerCell(type: HashtagCell.self)
        self.hashtagCollectionView.delegate = self
        self.hashtagCollectionView.dataSource = self
        self.hashtagCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSoundCollectionView() {
        self.soundCollectionView.registerCell(type: SoundCell.self)
        self.soundCollectionView.delegate = self
        self.soundCollectionView.dataSource = self
        self.soundCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupTabbar() {
        self.soundButton.cornerRadius = self.soundButton.frame.height / 2
        self.videoButton.cornerRadius = self.videoButton.frame.height / 2
        self.tabbarView.cornerRadius = self.tabbarView.frame.height / 2
    }
    
    @IBAction private func backButtonDidTap(_ sender: Any) {
        self.coordinator.stop()
    }
    
    @IBAction private func soundButonDidTap(_ sender: Any) {
    }
    
    @IBAction private func videoButtonDidTap(_ sender: Any) {
    }
}

extension ListItemSoundVC: UICollectionViewDelegate {
    
}

extension ListItemSoundVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.hashtagCollectionView {
            return self.presenter.getHashtag(categoryId: categoryId).count
        } else if collectionView == soundCollectionView {
            return self.presenter.getNumberOfItems(categoryId: categoryId)
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.hashtagCollectionView {
            guard let cell = collectionView.dequeueCell(type: HashtagCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            
            let hashtagString = self.presenter.getHashtag(categoryId: categoryId)[indexPath.row]
            cell.configureHashtag(hashtag: hashtagString)
            return cell
        } else { // soundCollectionView
            guard let cell = collectionView.dequeueCell(type: SoundCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            
            let sound = self.presenter.loadData(categoryId: categoryId)[indexPath.row]
            cell.configureSound(sound: sound)
            return cell
        }
    }
}

extension ListItemSoundVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.hashtagCollectionView {
            let text = self.presenter.getHashtag(categoryId: categoryId)[indexPath.row]
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
