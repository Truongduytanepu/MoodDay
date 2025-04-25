//
//  HomePresenter.swift
//  FanNoise
//
//  Created by Manh Nguyen Ngoc on 21/4/25.
//

import UIKit

protocol HomePresenter {
    func getHomeCategory()
}

class HomePresenterImpl: BasePresenter<HomeView>, HomePresenter {
    func getHomeCategory() {
        GetHomeCategory().exe().subscribe { [weak self] data in
            guard let self = self else {return}
            self.view?.onLoadHomeCategory(data)
            self.view?.saveDataCategory(data)
        } onError: { [weak self] (error) in
            guard let self = self else {return}
            self.view?.onError(error)
        }.disposed(by: self.disposeBag)
    }
}
