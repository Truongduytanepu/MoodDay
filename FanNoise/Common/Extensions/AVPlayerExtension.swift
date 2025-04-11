//
//  AVPlayerExtension.swift
//  PlantIdentification
//
//  Created by Manh Nguyen Ngoc on 12/10/2021.
//

import AVFoundation
import UIKit

extension AVPlayer {
    func seek(to time: CMTime) {
        self.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void) {
        self.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: completionHandler)
    }
}
