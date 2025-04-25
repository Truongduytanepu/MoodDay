//
//  HomeView.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 21/04/2025.
//

import UIKit

@objc protocol HomeView: BaseView {
    func onLoadHomeCategory(_ data: [HomeCategory])
    func onError(_ error: Error)
}
