//
//  PresenterRegisterer.swift
//  PlantIdentification
//
//  Created by thanhvu on 6/30/20.
//  Copyright © 2020 Solar. All rights reserved.
//

import Foundation
import Swinject

class PresenterRegisterer {
    static func registerDependencyForPresenters(container: Container) {
        container.register(SplashPresenter.self) { (_, view: SplashView) -> SplashPresenter in
            return SplashPresenterImpl(view: view)
        }
        
        container.register(HomePresenter.self) { (_, view: HomeView) -> HomePresenter in
            return HomePresenterImpl(view: view)
        }
        
        container.register(IntroPresenter.self) { (_, view: IntroView) -> IntroPresenter in
            return IntroPresenterImpl(view: view)
        }
        
        
    }
}
