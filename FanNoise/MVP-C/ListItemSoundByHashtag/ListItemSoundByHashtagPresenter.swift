//
//  ListItemSoundByHashtagPresenter.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 02/05/2025.
//

import UIKit

protocol ListItemSoundByHashtagPresenter {
    func loadSoundByHashtag(nameHashtag: String) -> [Sound]
    func getNumberOfItems(nameHashtag: String) -> Int
}

class ListItemSoundByHashtagPresenterImpl: BasePresenter<ListItemSoundByHashtagView>, ListItemSoundByHashtagPresenter {
    func loadSoundByHashtag(nameHashtag: String) -> [Sound] {
        return HomeCategoryManager.shared.getSoundsByHashtag(nameHashtag)
    }
    
    func getNumberOfItems(nameHashtag: String) -> Int {
        return HomeCategoryManager.shared.getSoundsByHashtag(nameHashtag).count
    }
}
