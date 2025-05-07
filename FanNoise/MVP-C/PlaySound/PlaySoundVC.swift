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
        self.setupUI(with: soundItem)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Config
    private func config() {
        self.setupFont()
        self.setupFirtCollectionView()
        self.setupSecondCollectionView()
        self.setupLastCollectionView()
        self.loadData()
        self.setupObservers()
        self.setupAudioInterruptionObserver()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillTerminate),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }
    
    private func setupAudioInterruptionObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAudioInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
    }
    
    @objc private func handleAudioInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        if type == .began {
            // Gián đoạn bắt đầu (cuộc gọi đến, báo thức...)
            self.stopSoundIfNeed()
        } else if type == .ended {
            // Gián đoạn kết thúc, bạn có thể phát lại nếu cần
            // Ví dụ:
            // try? AVAudioSession.sharedInstance().setActive(true)
            // self.audioPlayer?.play()
        }
    }

    @objc private func appWillResignActive() {
        self.stopSoundIfNeed()
    }

    @objc private func appWillTerminate() {
        self.stopSoundIfNeed()
    }
    
    private func startRotatingSmoothly(imageView: UIImageView) {
        // Xoá animation cũ nếu có
        imageView.layer.removeAnimation(forKey: "rotation")

        // Bước 1: Tạo animation quay nhanh dần (ease-in)
        let accelerateRotation = CABasicAnimation(keyPath: "transform.rotation")
        accelerateRotation.fromValue = 0
        accelerateRotation.toValue = Double.pi * 2
        accelerateRotation.duration = 1.0
        accelerateRotation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        accelerateRotation.fillMode = .forwards
        accelerateRotation.isRemovedOnCompletion = false

        // Gán animation tăng tốc ban đầu
        imageView.layer.add(accelerateRotation, forKey: "acceleration")

        // Bước 2: Sau khi tăng tốc xong, chuyển sang quay đều
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let steadyRotation = CABasicAnimation(keyPath: "transform.rotation")
            steadyRotation.fromValue = 0
            steadyRotation.toValue = Double.pi * 2
            steadyRotation.duration = 0.6  // tốc độ quay ổn định
            steadyRotation.repeatCount = .infinity
            steadyRotation.isRemovedOnCompletion = false
            steadyRotation.fillMode = .forwards
            steadyRotation.timingFunction = CAMediaTimingFunction(name: .linear)

            imageView.layer.removeAnimation(forKey: "acceleration") // Xoá animation cũ
            imageView.layer.add(steadyRotation, forKey: "rotation")
        }
    }
    
    private func loadData() {
        self.presenter.loadData(sounds: self.listSound)
        self.presenter.getRandomSounds(sound: self.listSound)
        self.presenter.getRandomVideos(videos: self.listVideo)
    }
    
    private func stopRotatingSmoothly(imageView: UIImageView) {
        guard imageView.layer.animation(forKey: "rotation") != nil else { return }

        // Lấy góc xoay hiện tại từ presentation layer
        guard let presentationLayer = imageView.layer.presentation() else { return }
        let currentTransform = presentationLayer.transform
        let currentRotation = atan2(currentTransform.m12, currentTransform.m11)

        // Xoá animation hiện tại
        imageView.layer.removeAllAnimations()
        imageView.layer.transform = CATransform3DMakeRotation(currentRotation, 0, 0, 1)

        // Tạo animation quay chậm dần thêm 90 độ rồi dừng
        let slowDown = CABasicAnimation(keyPath: "transform.rotation.z")
        slowDown.fromValue = currentRotation
        slowDown.toValue = currentRotation + .pi / 2  // quay thêm 90 độ
        slowDown.duration = 1.0
        slowDown.timingFunction = CAMediaTimingFunction(name: .easeOut)
        slowDown.fillMode = .forwards
        slowDown.isRemovedOnCompletion = false

        imageView.layer.add(slowDown, forKey: "slowStop")

        // Sau khi animation kết thúc, cố định lại transform
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            imageView.layer.removeAllAnimations()
            imageView.layer.transform = CATransform3DMakeRotation(currentRotation + .pi / 2, 0, 0, 1)
        }
    }

    private func playAudio(from urlString: String) {
        // 1. Reset player cũ nếu có
        self.audioPlayer?.pause()
        self.audioPlayer = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        // 2. Mã hoá URL
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            print("❌ Invalid or improperly encoded URL")
            return
        }

        // 3. Tạo player mới
        let playerItem = AVPlayerItem(url: url)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioDidFinish),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        
        self.audioPlayer = AVPlayer(playerItem: playerItem)
        self.audioPlayer?.play()
    }

    @objc private func audioDidFinish(notification: Notification) {
        print("🔁 Replaying audio...")
        self.audioPlayer?.seek(to: .zero)
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
    
    private func setupUI(with sound: Sound) {
        if sound.isRotate == true {
            let imageViews = [firstFanImageView, secondFanImageView, lastFanImageView]
            
            if let frames = sound.frames {
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
            if let thumb = sound.thumb,
               let encodedString = thumb.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: encodedString) {
                self.firstFanImageView.sd_setImage(with: url, completed: nil)
            }
        }
        
        self.nameSoundLabel.text = sound.name
        self.hashtagLabel.text = sound.hashtag
        self.fanView.cornerRadius = self.fanView.frame.height / 2
        self.fanView.backgroundColor = sound.bgColor1?.toColor()
        self.setTimeButton.cornerRadius = self.setTimeButton.frame.height / 2
    }
    
    private func stopSoundIfNeed() {
        // Dừng player
        self.audioPlayer?.pause()
        
        // Dừng tất cả animation ngay lập tức
        [self.firstFanImageView, self.secondFanImageView, self.lastFanImageView].forEach { imageView in
            imageView?.layer.removeAllAnimations()
            imageView?.layer.transform = CATransform3DIdentity
        }
        
        // Cập nhật UI
        self.playButton.setImage(UIImage(named: "ic_playsound_pause"), for: .normal)
        self.isRotating = false
    }
    
    private func stopSoundSmoothlyIfNeed() {
        self.playButton.setImage(UIImage(named: "ic_playsound_pause"), for: .normal)
        [self.firstFanImageView, self.secondFanImageView, self.lastFanImageView].forEach {
            guard let imageView = $0 else { return }
            self.stopRotatingSmoothly(imageView: imageView)
        }
        
        self.audioPlayer?.pause()
    }
    
    private func startSoundSmoothlyIfNeed() {
        self.stopSoundIfNeed()

        let soundLink = self.soundItem.source
        self.playButton.setImage(UIImage(named: "ic_playsound_play"), for: .normal)
        if self.soundItem.isRotate == true {
            if self.soundItem.rotateFrame == 2 {
                self.startRotatingSmoothly(imageView: self.secondFanImageView)
            } else {
                self.startRotatingSmoothly(imageView: self.firstFanImageView)
            }
        }
        
        self.playAudio(from: soundLink ?? "")
    }
    
    @IBAction private func backButtonDidTap(_ sender: Any) {
        self.coordinator.stop()
    }
    
    @IBAction private func setTimeButtonDidTap(_ sender: Any) {
        
    }
    
    @IBAction private func playButtonDidTap(_ sender: Any) {
        if self.isRotating {
            self.stopSoundSmoothlyIfNeed()
        } else {
            self.startSoundSmoothlyIfNeed()
        }
        
        self.isRotating.toggle()
    }
}

extension PlaySoundVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.stopSoundIfNeed()
        if collectionView == self.likeCollectionView {
            let soundSelected = self.presenter.getLikeSound()[indexPath.row]
            self.soundItem = soundSelected
            self.setupUI(with: soundSelected)
        } else if collectionView == self.funnyCollectionView {
            
            
        } else {
            let soundSelected = self.presenter.getOtherSound()[indexPath.row]
            self.soundItem = soundSelected
            self.setupUI(with: soundSelected)
        }
    }
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
            
            self.presenter.getOtherSound()[indexPath.row].assignRandomColorsIfNeeded()
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
