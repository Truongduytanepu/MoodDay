//
//  firstCell.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 04/05/2025.
//

import UIKit

class ItemLikeCell: UICollectionViewCell {
    
    @IBOutlet private weak var parentView: UIView!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var childView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupFont()
    }
    
    private func setupFont() {
        self.itemNameLabel.font = AppFont.font(.mPLUS2Bold, size: 11)
    }
    
    private func setupUI() {
        self.childView.cornerRadius = self.childView.frame.height / 2
    }
    
    func configure(sound: Sound) {
        if let thumb = sound.thumb,
           let encodedString = thumb.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedString) {
            self.itemImageView.sd_setImage(with: url, completed: nil)
        }
        
        self.itemNameLabel.text = sound.name
        self.parentView.backgroundColor = sound.bgColor0?.toColor()
        self.childView.backgroundColor = sound.bgColor1?.toColor()
    }
}
