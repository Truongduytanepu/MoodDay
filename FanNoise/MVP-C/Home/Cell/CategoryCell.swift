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
    
    private func setupFont() {
        self.bottomTitleLabel.font = AppFont.font(.mPLUS2Black, size: 16)
        self.leftTitleLabel.font = AppFont.font(.mPLUS2Black, size: 30)
        self.descriptionLabel.font = AppFont.font(.mPLUS2Regular, size: 15)
    }
    
    func configure(_ category: HomeCategory) {
        self.categoryImageView.image = nil
        self.bottomTitleLabel.text = nil
        self.leftTitleLabel.text = nil
        
        if let thumb = category.thumb,
           let encodedString = thumb.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedString) {
        self.categoryImageView.sd_setImage(with: url, completed: nil)
        }
        
        self.bottomTitleLabel.text = category.name
        self.leftTitleLabel.text = category.name
        self.setupFont()
    }
    
    func setupTitleLabel(index: Int) {
        self.stackView.isHidden = false
        self.bottomTitleLabel.isHidden = false
        if index == 0 {
            self.bottomTitleLabel.isHidden = true
        } else {
            self.stackView.isHidden = true
        }
    }
}
