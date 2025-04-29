//
//  TopicSuggestVideoCell.swift
//  FanNoise
//
//  Created by ADMIN on 4/28/25.
//

import UIKit

private struct Const {
    static let marginLeftRight: CGFloat = 14
    static let marginTop: CGFloat = 38
    static let marginBot: CGFloat = 0
    static let spaceCell: CGFloat = 12
    static let topicCount = 4
    static let itemRatio = 1.5
}

class TopicSuggestVideoCell: UICollectionViewCell {

    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var videoCategories: [SoundCategory] = []
    var callBackUpdateData: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpCollectionView()
        self.setUpFont()
    }
    
    private func setUpCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerCell(type: ItemTopicCell.self)
    }
    
    private func setUpFont() {
        self.titleLbl.font = AppFont.font(.mPLUS2SemiBold, size: 14)
    }
    
    func cofigData(videoCategories: [SoundCategory]) {
        self.videoCategories = Array(videoCategories.prefix(Const.topicCount))
    }
}

extension TopicSuggestVideoCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return Const.topicCount
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: ItemTopicCell.self,
                                                    indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        cell.configData(soundCategory: self.videoCategories[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let topicName = self.videoCategories[indexPath.row].name ?? ""
        self.callBackUpdateData?(topicName)
    }
}

extension TopicSuggestVideoCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (UIScreen.main.bounds.width - Const.marginLeftRight * 2 - Const.spaceCell) / 2
        let height = width * Const.itemRatio
        
        return CGSize(width: width,
                      height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: Const.marginTop,
                            left: Const.marginLeftRight,
                            bottom: Const.marginBot,
                            right: Const.marginLeftRight)
    }
}

extension TopicSuggestVideoCell: UICollectionViewDelegate {
    
}
