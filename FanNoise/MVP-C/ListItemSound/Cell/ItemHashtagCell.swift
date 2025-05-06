//
//  HashtagCell.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 28/04/2025.
//

import UIKit

class ItemHashtagCell: UICollectionViewCell {
    @IBOutlet private weak var hashTagLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupFont()
    }
    
    private func setupFont() {
        self.hashTagLabel.font = AppFont.font(.mPLUS2Medium, size: 10)
    }

    func configure(hashtag: String) {
        self.hashTagLabel.text = "#\(hashtag)"
    }
}
