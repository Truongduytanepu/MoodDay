//
//  VideoVC.swift
//  FanNoise
//
//  Created by ADMIN on 4/25/25.
//

import UIKit

class VideoVC: BaseVC<VideoPresenter, VideoView> {
    // MARK: - Lifecycle
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var coordinator: VideoCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    private func config() {
        self.setupCollectionView()
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerCell(type: ItemVideoCVC.self)
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension VideoVC: VideoView {
    
}

extension VideoVC: UICollectionViewDelegate {
    
}

extension VideoVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HomeCategoryManager.shared.getVideoCategory("67ef52793054a2b6c96086cc").count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: ItemVideoCVC.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        let videoCategory = HomeCategoryManager.shared.getVideoCategory("67ef52793054a2b6c96086cc")[indexPath.row]
        cell.configure(with: videoCategory.source ?? "")
        
        return cell
    }
}

extension VideoVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
