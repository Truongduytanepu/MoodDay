//
//  ItemTopicCell.swift
//  FanNoise
//
//  Created by ADMIN on 4/28/25.
//

import UIKit

class ItemTopicCell: UICollectionViewCell {

    @IBOutlet private weak var topicNameLbl: UILabel!
    @IBOutlet private weak var topicImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpFont()
    }
    
    private func setUpFont() {
        self.topicNameLbl.font = AppFont.font(.mPLUS2ExtraBold, size: 14)
    }
    
    func configData(soundCategory: SoundCategory) {
        if let thumb = soundCategory.thumb,
           let encodedString = thumb.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedString) {
            
            self.topicImg.sd_setImage(with: url, completed: nil)
        }
        
        self.topicNameLbl.text = soundCategory.name
    }
}
