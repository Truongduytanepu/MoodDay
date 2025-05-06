//
//  secondCell.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 04/05/2025.
//

import UIKit

class ItemFunnyCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!
    
    func configure(video: Video) {
        if let thumb = video.thumb,
           let encodedString = thumb.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedString) {
            self.imageView.sd_setImage(with: url, completed: nil)
        }
    }
}
