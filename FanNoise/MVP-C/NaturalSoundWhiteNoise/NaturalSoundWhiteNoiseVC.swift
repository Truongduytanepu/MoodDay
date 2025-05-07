//
//  NaturalSoundWhiteNoiseVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 28/04/2025.
//

import UIKit

private struct Const {
    static let ratioCell: CGFloat = 336 / 99
    static let cellSpacing: CGFloat = 12
    static let insetForSectionAt = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
}

class NaturalSoundWhiteNoiseVC: BaseVC<NaturalSoundWhiteNoisePresenter, NaturalSoundWhiteNoiseView> {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Lifecycle
    var categoryName : String = ""
    var categoryId : String = ""
    private var soundData: [SoundCategory] = []
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
    
    @IBAction private func backButtonDidTap(_ sender: Any) {
        self.coordinator.stop()
    }
}

extension NaturalSoundWhiteNoiseVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let navigationController = self.navigationController else { return }
        let sounds = self.soundData[indexPath.row]
        let soundByName = self.presenter.getSoundByCategoryName(nameCategory: sounds.name ?? "")
        let videoByName = self.presenter.getVideoByCategoryName(nameCategory: sounds.name ?? "")
        self.startListItemSound(navigationController: navigationController,
                                sound: soundByName,
                                video: videoByName,
                                categoryID: self.categoryId)
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

extension NaturalSoundWhiteNoiseVC: NaturalSoundWhiteNoiseView {
    
}
