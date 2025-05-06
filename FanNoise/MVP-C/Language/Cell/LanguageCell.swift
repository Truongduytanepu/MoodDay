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
        self.setupCell()
    }
    
    private func setupCell() {
        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.masksToBounds = true
        self.contentView.borderWidth = 1
    }
    
    private func setupFont() {
        self.languageNameLabel.font = AppFont.font(.mPLUS2Bold, size: 13)
    }
    
    private func setupCheckImageView() {
        self.checkImageView.isHidden = true
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
        self.contentView.layer.borderColor = UIColor.clear.cgColor
    }
}
