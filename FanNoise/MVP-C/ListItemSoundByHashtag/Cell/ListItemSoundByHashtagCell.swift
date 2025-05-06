//
//  SoundCell.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 02/05/2025.
//

import UIKit

class ListItemSoundByHashtagCell: UICollectionViewCell {
    
    @IBOutlet private weak var parentView: UIView!
    @IBOutlet private weak var childView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var hashtagLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupFont()
        self.setupUI()
    }
    
    private func setupFont() {
        self.titleLabel.font = AppFont.font(.mPLUS2SemiBold, size: 12)
        self.hashtagLabel.font = AppFont.font(.mPLUS2Medium, size: 8)
    }
    
    private func setupUI() {
        self.childView.cornerRadius = self.childView.bounds.width / 2
    }
    
    func configureSound(sound: Sound) {
        self.titleLabel.text = sound.name
        self.hashtagLabel.text = sound.hashtag
        self.parentView.backgroundColor = sound.bgColor0?.toColor()
        self.childView.backgroundColor = sound.bgColor1?.toColor()
        if let thumb = sound.thumb,
           let encodedString = thumb.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedString) {
            self.imageView.sd_setImage(with: url, completed: nil)
        }
    }
}

