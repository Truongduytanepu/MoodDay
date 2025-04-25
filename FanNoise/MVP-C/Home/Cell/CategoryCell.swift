//
//  CategoryCell.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 24/04/2025.
//

import UIKit
import SDWebImage

class CategoryCell: UICollectionViewCell {

    @IBOutlet private weak var categoryImageView: UIImageView!
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var bottomTitleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var leftTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.config()
    }
    
    private func config() {
        self.setupCell()
        self.setupFont()
    }
    
    private func setupFont() {
        self.bottomTitleLabel.font = AppFont.font(.mPLUS2Black, size: 16)
        self.leftTitleLabel.font = AppFont.font(.mPLUS2Black, size: 30)
        self.descriptionLabel.font = AppFont.font(.mPLUS2Regular, size: 15)
    }
    
    private func setupCell() {
        self.contentView.cornerRadius = 20
    }
    
    func configure(_ category: HomeCategory) {
        if let thumb = category.thumb,
           let encodedString = thumb.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedString) {
            
            self.categoryImageView.sd_setImage(with: url, completed: nil)
        }
        
        self.bottomTitleLabel.text = category.name
        self.leftTitleLabel.text = category.name
    }
    
    func setupTitleLabel(index: Int) {
        if index == 0 {
            self.bottomTitleLabel.isHidden = true
        } else {
            self.stackView.isHidden = true
        }
    }
}
