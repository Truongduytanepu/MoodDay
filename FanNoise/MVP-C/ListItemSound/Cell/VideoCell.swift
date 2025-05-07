//
//  VideoCell.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 06/05/2025.
//

import UIKit

class VideoCell: UICollectionViewCell {
    @IBOutlet private weak var videoImageView: UIImageView!
    @IBOutlet private weak var videoHashtagLabel: UILabel!
    
    override func awakeFromNib() {
        self.setupFont()
    }
    
    private func setupFont() {
        self.videoHashtagLabel.font = AppFont.font(.mPLUS2SemiBold, size: 10)
    }
    
    func configure(video: Video) {
        if let thumb = video.thumb,
           let encodedString = thumb.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedString) {
            self.videoImageView.sd_setImage(with: url, completed: nil)
        }
        
        self.videoHashtagLabel.text = video.hashtag
    }
}
