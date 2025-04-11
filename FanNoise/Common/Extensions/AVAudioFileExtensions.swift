//
//  AVAudioFileExtensions.swift
//  PlantIdentification
//
//  Created by Viet Le Van on 11/20/20.
//

import Foundation
import AVFoundation
extension AVAudioFile {
    var duration: TimeInterval {
        let sampleRateSong = Double(processingFormat.sampleRate)
        let lengthSongSeconds = Double(length) / sampleRateSong
        return lengthSongSeconds
    }
}
