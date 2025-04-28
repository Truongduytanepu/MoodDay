//
//  PreviewVideoPresenter.swift
//  FanNoise
//
//  Created by ADMIN on 4/25/25.
//

import UIKit

protocol PreviewVideoPresenter {
    func loadData()
    func getNumberOfItems() -> Int
    func getVideo(at index: Int) -> Video
}

class PreviewVideoPresenterImpl: BasePresenter<PreviewVideoView>, PreviewVideoPresenter {
    
    private var videoCategoryList: [Video] = []
    
    func loadData() {
        self.videoCategoryList = HomeCategoryManager.shared.getVideoCategory("67ef52793054a2b6c96086cb")
    }
    
    func getNumberOfItems() -> Int {
        return self.videoCategoryList.count
    }
    
    func getVideo(at index: Int) -> Video {
        return self.videoCategoryList[index]
    }
}
