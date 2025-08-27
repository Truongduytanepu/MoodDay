//
//  BaseCoordinator.swift
//  PlantIdentification
//
//  Created by Viet Le Van on 11/12/20.
//

import Foundation

protocol Coordinator {
    var started: Bool { get }

    func start()
    func stop()
}
