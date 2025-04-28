//
//  PreviewVideoVC.swift
//  FanNoise
//
//  Created by ADMIN on 4/25/25.
//

import UIKit
import AVKit

private struct Const {
    static let lineSpace: CGFloat = 0
    static let interitemSpace: CGFloat = 0
}

class PreviewVideoVC: BaseVC<PreviewVideoPresenter, PreviewVideoView> {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var coordinator: PreviewVideoCoordinator!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    private func config() {
        self.presenter.loadData()
        self.setupCollectionView()
        self.setUpNotification()
    }
    
    private func setUpNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appInterrupted),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerCell(type: ItemVideoCell.self)
        self.collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    @objc private func appMovedToBackground() {
        if let cell = collectionView.getCurrentCell() as? ItemVideoCell {
            cell.stopVideo()
        }
    }
    
    @objc private func appInterrupted(notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        switch type {
        case .began:
            if let cell = collectionView.getCurrentCell() as? ItemVideoCell {
                cell.stopVideo()
            }
            
        case .ended:
            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    if let cell = collectionView.getCurrentCell() as? ItemVideoCell {
                        cell.startVideo()
                    }
                }
            }
        @unknown default:
            break
        }
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
        return self.presenter.getNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = self.presenter.getVideo(at: indexPath.row)
        guard let cell = collectionView.getCurrentCell() as? ItemVideoCell else { return }
        if video.isPlay {
            cell.stopVideo()
        } else {
            cell.startVideo()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: ItemVideoCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        let video = presenter.getVideo(at: indexPath.row)
        cell.configure(with: video.source ?? "", video: video)
        
        return cell
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

extension PreviewVideoVC: PreviewVideoView {}
