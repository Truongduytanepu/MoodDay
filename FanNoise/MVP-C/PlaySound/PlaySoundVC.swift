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
    
    @IBOutlet private weak var setTimerBtn: UIButton!
    @IBOutlet private weak var firstFanImageView: UIImageView!
    @IBOutlet private weak var secondFanImageView: UIImageView!
    @IBOutlet private weak var lastFanImageView: UIImageView!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var fanView: UIView!
    @IBOutlet private weak var nameSoundLabel: UILabel!
    @IBOutlet private weak var hashtagLabel: UILabel!
    @IBOutlet private weak var likeTitleLabel: UILabel!
    @IBOutlet private weak var funnyTitleLabel: UILabel!
    @IBOutlet private weak var setTimerView: UIView!
    @IBOutlet private weak var otherTitleLabel: UILabel!
    @IBOutlet private weak var timeDialogLbl: UILabel!
    @IBOutlet private weak var likeCollectionView: UICollectionView!
    @IBOutlet private weak var funnyCollectionView: UICollectionView!
    @IBOutlet private weak var othersCollectionView: UICollectionView!
    
    private var isRotating = false
    private var isButtonDisabled = false
    private var rotationWorkItem: DispatchWorkItem? // Biến lưu trữ work item để hủy khi cần
    private var isTimerRunning = false
    var coordinator: PlaySoundCoordinator!
    var soundItem: Sound?
    var listSound: [Sound] = []
    var listVideo: [Video] = []
    private var minute: Int = 0
    private var second: Int = 0
    private var isOn: Bool = false
    private var audioPlayer: AVPlayer?
    private var timer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }
    
    override func viewDidLayoutSubviews() {
        guard let soundItem = self.soundItem else {
            print("soundItem is nil")
            return
        }
        
        self.setupUI(with: soundItem)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configNetwork()
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
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleAudioInterruption),
                                                   name: AVAudioSession.interruptionNotification,
                                                   object: AVAudioSession.sharedInstance())
        } catch {
            print("Failed to set up audio session: \(error)")
        }
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
            self.isRotating = false
        }
    }
    
    private func configNetwork() {
        if MonitorNetwork.shared.isConnectedNetwork() {
            self.likeCollectionView.reloadData()
            self.funnyCollectionView.reloadData()
            self.othersCollectionView.reloadData()
        } else {
            self.postAlert("Notification", message: "No Interner", titleButton: "Try again") { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.configNetwork()
            }
        }
    }

    @objc private func appWillResignActive() {
        self.stopSoundIfNeed()
        self.isRotating = false
    }
    
    @objc private func appWillTerminate() {
        self.stopSoundIfNeed()
        self.isRotating = false
    }
    
    private func startRotatingSmoothly(imageView: UIImageView) {
        // 1. Hủy mọi animation và work item cũ
        imageView.layer.removeAllAnimations()
        self.rotationWorkItem?.cancel()
        
        // 2. Kiểm tra nếu app đang trong background thì không chạy animation
        guard UIApplication.shared.applicationState != .background else {
            return
        }
        
        // 3. Tạo animation tăng tốc
        let accelerateRotation = CABasicAnimation(keyPath: "transform.rotation")
        accelerateRotation.fromValue = 0
        accelerateRotation.toValue = Double.pi * 2
        accelerateRotation.duration = 1.0
        accelerateRotation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        accelerateRotation.fillMode = .forwards
        accelerateRotation.isRemovedOnCompletion = false
        
        imageView.layer.add(accelerateRotation, forKey: "acceleration")
        
        // 4. Tạo work item mới với weak reference
        let newWorkItem = DispatchWorkItem { [weak self, weak imageView] in
            guard let self = self,
                  let imageView = imageView,
                  UIApplication.shared.applicationState == .active else {
                return
            }
            
            let steadyRotation = CABasicAnimation(keyPath: "transform.rotation")
            steadyRotation.fromValue = 0
            steadyRotation.toValue = Double.pi * 2
            steadyRotation.duration = 0.6
            steadyRotation.repeatCount = .infinity
            steadyRotation.isRemovedOnCompletion = false
            steadyRotation.fillMode = .forwards
            steadyRotation.timingFunction = CAMediaTimingFunction(name: .linear)
            
            imageView.layer.removeAllAnimations()
            imageView.layer.add(steadyRotation, forKey: "rotation")
        }
        
        self.rotationWorkItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: newWorkItem)
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
        self.timeDialogLbl.font = AppFont.font(.lexendSemiBold, size: 11)
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
                self.secondFanImageView.isHidden = true
                self.lastFanImageView.isHidden = true
                self.isRotating = false
            }
        }
        
        self.setTimerView.layoutIfNeeded()
        self.fanView.layoutIfNeeded()
        self.nameSoundLabel.text = sound.name
        self.hashtagLabel.text = sound.hashtag
        self.fanView.cornerRadius = self.fanView.frame.height / 2
        self.fanView.backgroundColor = sound.bgColor1?.toColor()
        self.setTimerView.cornerRadius = self.setTimerView.frame.height / 2
    }
    
    private func stopSoundIfNeed() {
        // Dừng player
        self.audioPlayer?.pause()
        // Dừng tất cả animation ngay lập tức
        [self.firstFanImageView, self.secondFanImageView, self.lastFanImageView].forEach { imageView in
            imageView?.layer.removeAllAnimations()
            imageView?.layer.transform = CATransform3DIdentity
            
            // Cập nhật UI
            self.playButton.setImage(UIImage(named: "ic_playsound_pause"), for: .normal)
            self.isRotating = false
        }
    }
    
    private func stopSoundSmoothlyIfNeed() {
        self.audioPlayer?.pause()
        // Dừng quạt từ từ
        [self.firstFanImageView, self.secondFanImageView, self.lastFanImageView].forEach {
            guard let imageView = $0 else { return }
            self.stopRotatingSmoothly(imageView: imageView)
        }
        
        // Cập nhật UI sau khi hoàn thành animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.playButton.setImage(UIImage(named: "ic_playsound_pause"), for: .normal)
            self.audioPlayer?.pause()
            self.audioPlayer?.seek(to: .zero)
        }
    }
    
    private func startSoundSmoothlyIfNeed() {
        let soundLink = self.soundItem?.source
        
        self.playButton.setImage(UIImage(named: "ic_playsound_play"), for: .normal)
        if self.soundItem?.isRotate == true {
            if self.soundItem?.rotateFrame == 2 {
                self.startRotatingSmoothly(imageView: self.secondFanImageView)
            } else {
                self.startRotatingSmoothly(imageView: self.firstFanImageView)
            }
        } else {
            [self.firstFanImageView, self.secondFanImageView, self.lastFanImageView].forEach { imageView in
                imageView?.layer.removeAllAnimations()
                imageView?.layer.transform = CATransform3DIdentity
            }
        }
        
        let totalTimeInSeconds = (self.minute * 60) + self.second
        if totalTimeInSeconds > 0 && self.isOn && !isTimerRunning {
            self.startTimer(duration: totalTimeInSeconds)
        }
        
        self.playAudio(from: soundLink ?? "")
    }
    
    private func startTimer(duration: Int) {
        self.isTimerRunning = true
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    private func resetTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.minute = 0
        self.second = 0
        self.isTimerRunning = false
    }
    
    @objc private func updateTime() {
        if self.minute == 0 && self.second == 0 {
            self.stopSoundAndUpdateUI()
        } else {
            if self.second == 0 {
                self.minute -= 1
                self.second = 59
            } else {
                self.second -= 1
            }
            
            self.timeDialogLbl.text = "\(self.minute):\(String(format: "%02d", self.second))"
            self.setTimerView.backgroundColor = UIColor(rgb: 0xFFC300)
        }
    }
    
    @objc private func stopSoundAndUpdateUI() {
        self.stopSoundSmoothlyIfNeed()
        self.isRotating.toggle()
        self.timeDialogLbl.text = "Set timer"
        self.resetTimer()
        self.setTimerView.backgroundColor = .clear
    }
    
    private func startPreviewVideo(navigationController: UINavigationController, videos: [Video], targetIndexPath: IndexPath) {
        let previewVideo = PreviewVideoCoordinator(navigation: navigationController,
                                                   videoCategoryType: .listVideo(videos: videos),
                                                   targetIndexPath: targetIndexPath)
        previewVideo.start()
    }
    
    private func startSetTimerDialog(navigationController: UINavigationController) {
        let setTimmerDialog = SetTimerDialogCoordinator(navigation: navigationController)
        
        setTimmerDialog.presentSetTimerDialog { [weak self] minute, second, isOn in
            guard let self = self else {
                return
            }
            
            self.resetTimer()
            self.timeDialogLbl.text = "\(minute):\(second)"
            self.setTimerView.backgroundColor = UIColor(rgb: 0xFFC300)
            self.minute = minute
            self.second = second
            self.isOn = isOn
            
            if !isOn {
                self.stopSoundSmoothlyIfNeed()
                self.stopSoundAndUpdateUI()
            }
            
            navigationController.dismiss(animated: true)
        }
    }
    
    @IBAction private func backButtonDidTap(_ sender: Any) {
        self.coordinator.stop()
        self.stopSoundSmoothlyIfNeed()
    }
    
    @IBAction private func setTimeButtonDidTap(_ sender: Any) {
        guard let navigationController = self.navigationController else {
            return
        }
        
        self.stopSoundSmoothlyIfNeed()
        self.isRotating = false
        self.startSetTimerDialog(navigationController: navigationController)
    }
    
    @IBAction private func playButtonDidTap(_ sender: Any) {
        self.configNetwork()
        guard !isButtonDisabled else { return }
        
        self.playButton.isEnabled = false
        self.setTimerBtn.isEnabled = false
        
        if self.isRotating {
            self.stopSoundSmoothlyIfNeed()
        } else {
            self.startSoundSmoothlyIfNeed()
        }
        
        // Toggle trạng thái sau khi thực hiện hành động
        self.isRotating.toggle()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.playButton.isEnabled = true
            self.setTimerBtn.isEnabled = true
        }
    }
}

extension PlaySoundVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.likeCollectionView {
            // 1. Reset item âm thanh hiện tại
            self.stopSoundIfNeed()
            self.setupObservers()

            // 2. Lấy âm thanh được chọn từ danh sách like
            let soundSelected = self.presenter.getLikeSound()[indexPath.row]
            
            // 3. Gán âm thanh mới và cập nhật giao diện
            self.soundItem = soundSelected
            self.setupUI(with: soundSelected)
            self.startSoundSmoothlyIfNeed()
        } else if collectionView == self.funnyCollectionView {
            guard let navigationController = self.navigationController else {
                return
            }
            
            self.stopSoundIfNeed()

            self.startPreviewVideo(navigationController: navigationController,
                                   videos: self.presenter.getFunVideo(),
                                   targetIndexPath: indexPath)
        } else {
            self.stopSoundIfNeed()
            self.setupObservers()

            self.soundItem = nil
            // 2. Lấy âm thanh được chọn từ danh sách like
            let soundSelected = self.presenter.getOtherSound()[indexPath.row]
            
            // 3. Gán âm thanh mới và cập nhật giao diện
            self.soundItem = soundSelected
            self.setupUI(with: soundSelected)
            self.startSoundSmoothlyIfNeed()
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
            
            self.presenter.getLikeSound()[indexPath.row].assignRandomColorsIfNeeded()
            
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
