//
//  itemHashtagVideoCell.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 06/05/2025.
//

import UIKit

class ItemHashtagVideoCell: UICollectionViewCell {
    
    @IBOutlet weak var hashtagVideoLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupFont()
    }
    
    private func setupFont() {
        self.hashtagVideoLabel.font = AppFont.font(.mPLUS2SemiBold, size: 10)
    }
 
    func configure(hashtag: String) {
        self.hashtagVideoLabel.text = hashtag
    }
}
