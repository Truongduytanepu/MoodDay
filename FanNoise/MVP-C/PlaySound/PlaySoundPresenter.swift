//
//  PlaySoundPresenter.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 02/05/2025.
//

import UIKit

protocol PlaySoundPresenter {
    func getSoundByCatogory(nameCategory: String) -> [Sound]
    func numberOfItem(nameCategory: String) -> Int
}

class PlaySoundPresenterImpl: BasePresenter<PlaySoundView>, PlaySoundPresenter {
    func numberOfItem(nameCategory: String) -> Int {
        return HomeCategoryManager.shared.getSoundByCategory(nameCategory).count
    }
    
    func getSoundByCatogory(nameCategory: String) -> [Sound] {
        return HomeCategoryManager.shared.getSoundByCategory(nameCategory)
    }
}
