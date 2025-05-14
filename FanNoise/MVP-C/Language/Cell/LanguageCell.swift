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
    @IBOutlet private weak var languageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.config()
    }
    
    private func config() {
        self.setupFont()
        self.setupCheckImageView()
        self.setupUI()
    }
    
    private func setupUI() {
        self.languageView.borderColor = .clear
        self.languageView.borderWidth = 0
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
        self.languageView.borderColor = UIColor(rgb: 0x2D2C2B)
        self.languageView.borderWidth = 1
    }
    
    func deselect() {
        self.checkImageView.isHidden = true
        self.languageView.borderColor = .clear
        self.languageView.borderWidth = 0
    }
}
