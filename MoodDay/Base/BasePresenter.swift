//
//  BasePresenter.swift
//  PlantIdentification
//
//  Created by Viet Le Van on 11/12/20.
//

import Foundation
import RxSwift

class BasePresenter<View: AnyObject>: NSObject {
    weak var view: View?
    var disposeBag = DisposeBag()
    
    init(view: View) {
        self.view = view
    }
}
