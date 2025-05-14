//
//  PreviewVideoPresenter.swift
//  FanNoise
//
//  Created by ADMIN on 4/25/25.
//

import UIKit
import GoogleMobileAds

protocol PreviewVideoPresenter {
    func loadData(idCategory: String)
    func getNumberOfItems(adsStep: Int) -> Int
    func getVideo(at index: Int) -> Video
    func updateData(name: String)
    func getAllVideo()
    func getVideocategory() -> [SoundCategory]
    func updateDataListVideo(videos: [Video])
    func updateListNativeAds(listNativeAd: [NativeAd])
    func getListNativeAd() -> [NativeAd]
}

class PreviewVideoPresenterImpl: BasePresenter<PreviewVideoView>, PreviewVideoPresenter {
    
    private var videoCategoryList: [Video] = []
    private var listNativeAd: [NativeAd] = []
    
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
    
    func getNumberOfItems(adsStep: Int) -> Int {
        if listNativeAd.isEmpty {
            return self.videoCategoryList.count
        }
        
        return self.videoCategoryList.count + self.videoCategoryList.count / adsStep
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
    
    func updateListNativeAds(listNativeAd: [NativeAd]) {
        self.listNativeAd = listNativeAd
    }
    
    func getListNativeAd() -> [NativeAd] {
        return self.listNativeAd
    }
}
