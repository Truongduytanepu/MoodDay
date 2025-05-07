//
//  ItemVideoCell.swift
//  FanNoise
//
//  Created by ADMIN on 4/25/25.
//

import UIKit
import AVKit

class ItemVideoCell: UICollectionViewCell {
    
    @IBOutlet private weak var videoView: UIView!
    @IBOutlet private weak var stateVideoImg: UIImageView!
    @IBOutlet private weak var hashtagVideoLabel: UILabel!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    
    var video: Video?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpPlayerLayer()
        self.updateUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.videoView.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: self.playerItem)
    }
    
    private func setUpPlayerLayer() {
        guard self.playerLayer == nil else { return }
        
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer?.videoGravity = .resizeAspectFill
        self.videoView.layer.addSublayer(self.playerLayer!)
    }
    
    private func updateUI() {
        self.stateVideoImg.image = self.video?.isPlay == true ? UIImage(named: "ic_video_play") : UIImage(named: "ic_video_pause")
    }
    
    func setUpCategoryType(videoCategoryType: VideoCategoryType) {
        switch videoCategoryType {
        case .trending:
            self.stateVideoImg.isHidden = true
            self.hashtagVideoLabel.isHidden = true
        case .filtered(let idCategory):
            self.stateVideoImg.isHidden = false
            self.hashtagVideoLabel.isHidden = false
        }
    }
    
    func configure(with videoURLString: String, video: Video) {
        guard let encodedURLString = videoURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let videoURL = URL(string: encodedURLString) else {
            print("Invalid URL")
            return
        }
        
        self.video = video
        self.playerItem = AVPlayerItem(url: videoURL)
        self.player = AVPlayer(playerItem: self.playerItem)
        self.hashtagVideoLabel.text = video.hashtag
        self.hashtagVideoLabel.font = AppFont.font(.mPLUS2SemiBold, size: 14)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        
        self.playerLayer?.player = self.player
        self.playerLayer?.frame = self.videoView.bounds
        self.videoView.setNeedsLayout()
        self.videoView.layoutIfNeeded()
    }
    
    func startVideo() {
        self.player?.play()
        self.video?.isPlay = true
        self.updateUI()
    }
    
    func stopVideo() {
        self.player?.pause()
        self.video?.isPlay = false
        self.updateUI()
    }
    
    @objc private func playerDidFinishPlaying() {
        self.player?.seek(to: CMTime.zero)
        self.player?.play()
    }
}
