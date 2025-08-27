//
//  SoundManager.swift
//  RankingFilterTop10
//
//  Created by ADMIN on 6/16/25.
//

class SoundManager {
    static let shared = SoundManager()
    
    private init() { }
    private var sounds: [SoundModel] = []
    
    func getSounds() -> [SoundModel] {
        return self.sounds
    }
    
    func updateSounds(_ sounds: [SoundModel]) {
        self.sounds = sounds
    }
}
