//
//  LanguageCell.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 22/04/2025.
//

import UIKit

class LanguageCell: UICollectionViewCell {
    
    @IBOutlet private weak var nationalFlagImageView: UIImageView!
    @IBOutlet private weak var languageNameLabel: UILabel!
    @IBOutlet private weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.config()
    }
    
    private func config() {
        self.setupFont()
        self.setupCheckImageView()
    }
    
    private func setupFont() {
        self.languageNameLabel.font = AppFont.font(.mPLUS2Bold, size: 13)
    }
    
    private func setupCheckImageView() {
        self.checkImageView.isHidden = true
        self.contentView.borderColor = .clear
    }
    
    func config(language: Language) {
        self.nationalFlagImageView.image = UIImage(named: language.ensign)
        self.languageNameLabel.text = language.name
    }
    
    func select() {
        self.checkImageView.isHidden = false
        self.contentView.borderColor = UIColor(rgb: 0x2D2C2B)
    }
    
    func deselect() {
        self.checkImageView.isHidden = true
        self.contentView.borderColor = .clear
    }
}
