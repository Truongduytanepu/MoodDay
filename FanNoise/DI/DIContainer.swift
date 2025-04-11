//
//  DIContainer.swift
//  PlantIdentification
//
//  Created by Viet Le Van on 11/12/20.
//

import Foundation
import Swinject

class DIContainer {
    static let shared = DIContainer()
    private let container = Container()

    init() {
        register()
    }

    func register() {
        PresenterRegisterer.registerDependencyForPresenters(container: container)
        DaoRegisterer.registerDependencyForDaos(container: container)
    }

    // MARK: - Helper
    func resolve<Service>(_ serviceType: Service.Type) -> Service {
        if Thread.isMainThread {
            return self.container.resolve(serviceType)!
        } else {
            var service:Service?

            DispatchQueue.main.sync {[weak self] in
                service = self?.container.resolve(serviceType)
            }

            return service!
        }
    }

    func resolve<Service, Arg1>(_ serviceType: Service.Type, agrument: Arg1) -> Service {
        if Thread.isMainThread {
            return self.container.resolve(serviceType, argument: agrument)!
        } else {
            var service:Service?

            DispatchQueue.main.sync {[weak self] in
                service = self?.container.resolve(serviceType, argument: agrument)
            }

            return service!
        }
    }
}
