//
//  PlaySoundVC.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 02/05/2025.
//

import UIKit
import AVFoundation

private struct Const {
    static let likeRatioCell: CGFloat = 138 / 111
    static let funnyRatioCell: CGFloat = 210 / 120
    static let othersRatioCell: CGFloat = 138 / 111
    static let cellSpacing: CGFloat = 12
    static let cellInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
}

class PlaySoundVC: BaseVC<PlaySoundPresenter, PlaySoundView> {
    
    @IBOutlet private weak var firstFanImageView: UIImageView!
    @IBOutlet private weak var secondFanImageView: UIImageView!
    @IBOutlet private weak var lastFanImageView: UIImageView!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var fanView: UIView!
    @IBOutlet private weak var nameSoundLabel: UILabel!
    @IBOutlet private weak var setTimeButton: UIButton!
    @IBOutlet private weak var hashtagLabel: UILabel!
    @IBOutlet private weak var likeTitleLabel: UILabel!
    @IBOutlet private weak var funnyTitleLabel: UILabel!
    @IBOutlet private weak var otherTitleLabel: UILabel!
    @IBOutlet private weak var likeCollectionView: UICollectionView!
    @IBOutlet private weak var funnyCollectionView: UICollectionView!
    @IBOutlet private weak var othersCollectionView: UICollectionView!
    
    private var isRotating = false
    private var rotationTimer: Timer?
    var coordinator: PlaySoundCoordinator!
    var soundItem: Sound!
    var listSound: [Sound] = []
    var listVideo: [Video] = []
    private var audioPlayer: AVPlayer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewDidLayoutSubviews() {
        self.setupUI()
    }
    
    // MARK: - Config
    private func config() {
        self.setupFont()
        self.setupFirtCollectionView()
        self.setupSecondCollectionView()
        self.setupLastCollectionView()
        self.loadData()
    }
    
    private func startRotatingSmoothly(imageView: UIImageView) {
        // Xoá animation cũ nếu có
        imageView.layer.removeAnimation(forKey: "rotation")
        
        // Reset layer state đầy đủ
        imageView.layer.speed = 0.05  //  tốc độ cực chậm ban đầu
        imageView.layer.timeOffset = 0
        imageView.layer.beginTime = 0
        
        // Thêm lại animation
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = 1.0
        rotation.repeatCount = .infinity
        rotation.isRemovedOnCompletion = false
        rotation.fillMode = .forwards
        
        imageView.layer.add(rotation, forKey: "rotation")
        
        //  Đặt lại tốc độ quay ban đầu
        imageView.layer.speed = 0.05  // tốc độ cực chậm ban đầu
        imageView.layer.timeOffset = 0
        imageView.layer.beginTime = CACurrentMediaTime()
        
        // Tăng tốc mượt
        self.accelerateRotation(imageView: imageView)
    }
    
    private func accelerateRotation(imageView: UIImageView) {
        var speed: Float = 0.1
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if speed >= 1.0 {
                timer.invalidate()
            } else {
                speed += 0.05
                imageView.layer.speed = speed
            }
        }
    }
    
    private func loadData() {
        self.presenter.loadData(sounds: self.listSound)
        self.presenter.getRandomSounds(sound: self.listSound)
        self.presenter.getRandomVideos(videos: self.listVideo)
    }
    
    private func stopRotating(imageView: UIImageView) {
        // Stop animation cleanly
        imageView.layer.removeAnimation(forKey: "rotation")
        imageView.layer.speed = 1.0
        imageView.layer.timeOffset = 0
        imageView.layer.beginTime = 0
    }
    
    private func playAudio(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        self.audioPlayer = AVPlayer(playerItem: playerItem)
        self.audioPlayer?.play()
    }
    
    private func setupFont() {
        self.nameSoundLabel.font = AppFont.font(.mPLUS2Bold, size: 20)
        self.hashtagLabel.font = AppFont.font(.mPLUS2Regular, size: 10)
        self.likeTitleLabel.font = AppFont.font(.mPLUS2SemiBold, size: 14)
        self.funnyTitleLabel.font = AppFont.font(.mPLUS2SemiBold, size: 14)
        self.otherTitleLabel.font = AppFont.font(.mPLUS2SemiBold, size: 14)
    }
    
    private func setupFirtCollectionView() {
        self.likeCollectionView.delegate = self
        self.likeCollectionView.dataSource = self
        self.likeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.likeCollectionView.registerCell(type: ItemLikeCell.self)
    }
    
    private func setupSecondCollectionView() {
        self.funnyCollectionView.delegate = self
        self.funnyCollectionView.dataSource = self
        self.funnyCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.funnyCollectionView.registerCell(type: ItemFunnyCell.self)
    }
    
    private func setupLastCollectionView() {
        self.othersCollectionView.delegate = self
        self.othersCollectionView.dataSource = self
        self.othersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.othersCollectionView.registerCell(type: ItemOthersCell.self)
    }
    
    private func setupUI() {
        if self.soundItem.isRotate == true {
            let imageViews = [firstFanImageView, secondFanImageView, lastFanImageView]
            
            if let frames = self.soundItem.frames {
                for (index, imageView) in imageViews.enumerated() {
                    if frames.indices.contains(index),
                       let encodedString = frames[index].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let url = URL(string: encodedString) {
                        imageView?.sd_setImage(with: url, completed: nil)
                        imageView?.isHidden = false
                    } else {
                        imageView?.isHidden = true
                    }
                }
            }
        } else {
            if let thumb = soundItem.thumb,
               let encodedString = thumb.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: encodedString) {
                self.firstFanImageView.sd_setImage(with: url, completed: nil)
            }
        }
        
        self.nameSoundLabel.text = self.soundItem.name
        self.hashtagLabel.text = self.soundItem.hashtag
        self.fanView.cornerRadius = self.fanView.frame.height / 2
        self.fanView.backgroundColor = self.soundItem.bgColor1?.toColor()
        self.setTimeButton.cornerRadius = self.setTimeButton.frame.height / 2
    }
    
    private func startRoting() {
        if self.soundItem.isRotate == true {
            self.startRotatingSmoothly(imageView: firstFanImageView)
            if self.soundItem.rotateFrame == 3 {
                self.startRotatingSmoothly(imageView: firstFanImageView)
            } else {
                self.startRotatingSmoothly(imageView: firstFanImageView)
            }
        }
    }
    
    private func stopRotating() {
        if self.soundItem.isRotate == true {
            if self.soundItem.rotateFrame == 3 {
                self.stopRotating(imageView: secondFanImageView)
            } else {
                self.stopRotating(imageView: firstFanImageView)
            }
        }
    }
    
    @IBAction private func backButtonDidTap(_ sender: Any) {
        self.coordinator.stop()
    }
    
    @IBAction private func setTimeButtonDidTap(_ sender: Any) {
        
    }
    
    @IBAction private func playButtonDidTap(_ sender: Any) {
        if self.isRotating {
            self.audioPlayer?.pause()
            self.playButton.setImage(UIImage(named: "ic_playsound_pause"), for: .normal)
            self.stopRotating()
        } else {
            let soundLink = self.soundItem.source
            self.playAudio(from: soundLink ?? "")
            self.playButton.setImage(UIImage(named: "ic_playsound_play"), for: .normal)
            self.startRoting()
        }
        
        self.isRotating.toggle()
    }
}

extension PlaySoundVC: UICollectionViewDelegate {
    
}

extension PlaySoundVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.likeCollectionView {
            return self.presenter.getLikeSound().count
        } else if collectionView == self.funnyCollectionView {
            return self.presenter.getFunVideo().count
        } else if collectionView == self.othersCollectionView {
            return self.presenter.getOtherSound().count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.likeCollectionView {
            guard let cell = collectionView.dequeueCell(type: ItemLikeCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            
            cell.configure(sound: self.presenter.getLikeSound()[indexPath.row])
            return cell
        } else if collectionView == self.funnyCollectionView {
            guard let cell = collectionView.dequeueCell(type: ItemFunnyCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            
            cell.configure(video: self.presenter.getFunVideo()[indexPath.row])
            return cell
        } else if collectionView == self.othersCollectionView {
            guard let cell = collectionView.dequeueCell(type: ItemOthersCell.self, indexPath: indexPath) else {
                return UICollectionViewCell()
            }
            
            cell.configure(sound: self.presenter.getOtherSound()[indexPath.row])
            
            return cell
        } else {
            // Default case (optional)
            return UICollectionViewCell()
        }
    }
}

extension PlaySoundVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.likeCollectionView {
            let height = collectionView.frame.height
            let width = height / Const.likeRatioCell
            return CGSize(width: width, height: height)
        } else if collectionView == self.funnyCollectionView {
            let height = collectionView.frame.height
            let width = height / Const.funnyRatioCell
            return CGSize(width: width, height: height)
        } else if collectionView == self.othersCollectionView {
            let height = collectionView.frame.height
            let width = height / Const.othersRatioCell
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Const.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Const.cellInset
    }
}

extension PlaySoundVC: PlaySoundView {
    
}
