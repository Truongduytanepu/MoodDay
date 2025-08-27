//
//  FilterModel.swift
//  RankingFilterTop10
//
//  Created by Trương Duy Tân on 17/6/25.
//

import UIKit

struct FilterModel: Codable {
    let videos: [Video]
    let images: [String]
    let banner: String?
    let name: String
    let thumb: String
    var isSelected: Bool = false
    var videoThumbImage: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case videos
        case images
        case banner
        case name
        case thumb
    }
}

// MARK: - Video
struct Video: Codable {
    let source: String
    let name: String
    let thumb: String
    
    enum CodingKeys: String, CodingKey {
        case source
        case name
        case thumb
    }
}
