//
//  AVAudioPlayerNodeExtensions.swift
//  PlantIdentification
//
//  Created by Viet Le Van on 11/20/20.
//

import Foundation
import AVFoundation

extension AVAudioPlayerNode {
    var currentTime: TimeInterval {
        if let nodeTime = lastRenderTime,let playerTime = playerTime(forNodeTime: nodeTime) {
            return Double(playerTime.sampleTime) / playerTime.sampleRate
        }
        return 0
    }
}
