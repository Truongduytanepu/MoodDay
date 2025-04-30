//
//  HashtagCell.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 28/04/2025.
//

import UIKit

class HashtagCell: UICollectionViewCell {
    @IBOutlet private weak var hashTagLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupFont()
        self.setupUI()
    }
    
    private func setupFont() {
        self.hashTagLabel.font = AppFont.font(.mPLUS2Medium, size: 10)
    }
    
    private func setupUI() {
        self.contentView.cornerRadius = 5
    }

    func configureHashtag(hashtag: String) {
        self.hashTagLabel.text = "#\(hashtag)"
    }
}
