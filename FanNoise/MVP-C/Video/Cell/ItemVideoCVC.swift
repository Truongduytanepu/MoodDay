//
//  ItemVideoCVC.swift
//  FanNoise
//
//  Created by ADMIN on 4/25/25.
//

import UIKit
import AVKit

class ItemVideoCVC: UICollectionViewCell {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        if playerLayer == nil {
            self.playerLayer = AVPlayerLayer(player: player)
            self.playerLayer?.videoGravity = .resizeAspectFill
            self.contentView.layer.addSublayer(self.playerLayer!)
        }
    }

    func configure(with videoURLString: String) {
        guard let encodedURLString = videoURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let videoURL = URL(string: encodedURLString) else {
            print("Invalid URL")
            return
        }

        self.player = AVPlayer(url: videoURL)
        
        self.playerLayer?.player = self.player
        self.playerLayer?.frame = contentView.bounds
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        
        self.player?.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = contentView.bounds
    }
}
