//
//  PreviewVideoPresenter.swift
//  FanNoise
//
//  Created by ADMIN on 4/25/25.
//

import UIKit

protocol PreviewVideoPresenter {
    func loadData(idCategory: String)
    func getNumberOfItems() -> Int
    func getVideo(at index: Int) -> Video
    func updateData(name: String)
    func getAllVideo()
    func getVideocategory() -> [SoundCategory]
    func updateDataListVideo(videos: [Video])
}

class PreviewVideoPresenterImpl: BasePresenter<PreviewVideoView>, PreviewVideoPresenter {
    
    private var videoCategoryList: [Video] = []
    
    func loadData(idCategory: String) {
        self.videoCategoryList = HomeCategoryManager.shared.getVideoCategory(idCategory: idCategory)
    }
    
    func getAllVideo() {
        self.videoCategoryList = HomeCategoryManager.shared.getAllVideo()
    }
    
    func updateData(name: String) {
        self.videoCategoryList = HomeCategoryManager.shared.getVideosWithCategoryName(targetName: name)
        self.view?.updateUI()
    }
    
    func getNumberOfItems() -> Int {
        return self.videoCategoryList.count
    }
    
    func getVideo(at index: Int) -> Video {
        return self.videoCategoryList[index]
    }
    
    func getVideocategory() -> [SoundCategory] {
        return HomeCategoryManager.shared.getVideoCategory()
    }
    
    func updateDataListVideo(videos: [Video]) {
        self.videoCategoryList = videos
    }
}
