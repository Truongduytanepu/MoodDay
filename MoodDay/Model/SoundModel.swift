//
//  SoundModel.swift
//  RankingFilterTop10
//
//  Created by ADMIN on 6/16/25.
//

struct SoundModel: Codable {
    let name: String
    var isSelected: Bool = false
    var isPlaying: Bool = false
    let duration: Double
    var source: String
    var currentTime: Double = 0.0

    var currentTimeString: String {
        return formatTime(currentTime)
    }
    
    var durationString: String {
        return formatTime(duration)
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case duration
        case source
    }
}
