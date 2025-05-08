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
        
        container.register(LanguagePresenter.self) { (_, view: LanguageView) -> LanguagePresenter in
            return LanguagePresenterImpl(view: view)
        }
        
        container.register(TabbarPresenter.self) { (_, view: TabbarView) -> TabbarPresenter in
            return TabbarPresenterImpl(view: view)
        }
        
        container.register(PreviewVideoPresenter.self) { (_, view: PreviewVideoView) -> PreviewVideoPresenter in
            return PreviewVideoPresenterImpl(view: view)
        }
        
        container.register(NaturalSoundWhiteNoisePresenter.self) { (_, view: NaturalSoundWhiteNoiseView) -> NaturalSoundWhiteNoisePresenter in
            return NaturalSoundWhiteNoisePresenterImpl(view: view)
        }
        
        container.register(ListItemSoundPresenter.self) { (_, view: ListItemSoundView) -> ListItemSoundPresenter in
            return ListItemSoundPresenterImpl(view: view)
        }
        
        container.register(ListItemSoundByHashtagPresenter.self) { (_, view: ListItemSoundByHashtagView) -> ListItemSoundByHashtagPresenter in
            return ListItemSoundByHashtagPresenterImpl(view: view)
        }
        
        container.register(PlaySoundPresenter.self) { (_, view: PlaySoundView) -> PlaySoundPresenter in
            return PlaySoundPresenterImpl(view: view)
        }
        
        container.register(SetTimerDialogPresenter.self) { (_, view: SetTimerDialogView) -> SetTimerDialogPresenter in
            return SetTimerDialogPresenterImpl(view: view)
        }
    }
}
