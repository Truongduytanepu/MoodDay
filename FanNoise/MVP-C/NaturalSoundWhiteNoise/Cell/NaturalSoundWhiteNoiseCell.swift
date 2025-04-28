//
//  NaturalSoundWhiteNoiseCell.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 28/04/2025.
//

import UIKit

class NaturalSoundWhiteNoiseCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupFont()
    }
    
    private func setupFont() {
        self.titleLabel.font = AppFont.font(.mPLUS2SemiBold, size: 16)
        self.setupCell()
    }
    
    private func setupCell() {
        self.contentView.cornerRadius = 16
    }
    
    func configure(soundCategory: SoundCategory) {
        // Xử lý hình ảnh
        if let thumb = soundCategory.thumb,
           let encodedString = thumb.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedString) {
            self.imageView.sd_setImage(with: url, completed: nil)
        } else {
            self.imageView.image = nil // hoặc đặt ảnh placeholder nếu cần
        }
        
        // Xử lý tên
        self.titleLabel.text = soundCategory.name
    }
}
