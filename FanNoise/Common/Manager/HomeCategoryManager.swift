//
//  HomeCategoryManager.swift
//  FanNoise
//
//  Created by ADMIN on 4/25/25.
//

class HomeCategoryManager {
    static let shared = HomeCategoryManager()
    
    private var categories: [HomeCategory] = []
    private init() { }
    
    func getCategories() -> [HomeCategory] {
        return categories
    }
    
    func updateCategories(_ categories: [HomeCategory]) {
        self.categories = categories
    }
    
    func getVideoCategory(idCategory: String) -> [Video] {
        if let category = categories.first(where: { $0.id == idCategory }) {
            return category.videos
        }
        
        return []
    }
    
    func getVideoCategory() -> [SoundCategory] {
        var result: [SoundCategory] = []
        var uniqueNames: Set<String> = Set()
        
        for category in categories {
            let videos = category.videos
            for video in videos {
                if let soundCategory = video.category, let name = soundCategory.name {
                    if !uniqueNames.contains(name) {
                        uniqueNames.insert(name)
                        result.append(soundCategory)
                    }
                }
            }
        }
        
        return result
    }
    
    func getAllVideo() -> [Video] {
        return categories.flatMap { $0.videos }
    }
    
    func getAllSound() -> [Sound] {
        return categories.flatMap{$0.sounds}
    }
    
    func getSoundNameAndThumb(_ idCategory: String) -> [SoundCategory] {
        var result: [SoundCategory] = []
        var uniqueNames: Set<String> = Set()
        
        guard let category = categories.first(where: { $0.id == idCategory }) else {
            return result
        }
        
        for sound in category.sounds  {
            if let soundCategory = sound.category, let name = soundCategory.name {
                if !uniqueNames.contains(name) {
                    uniqueNames.insert(name)
                    result.append(soundCategory)
                }
            }
        }
        
        return result
    }
    
    func getVideosWithCategoryName(targetName: String) -> [Video] {
        var result: [Video] = []
        
        for category in categories {
            let filteredVideos = category.videos.filter { video in
                guard let soundCategory = video.category else { return false }
                return soundCategory.name == targetName
            }
            
            result.append(contentsOf: filteredVideos)
        }
        
        return result
    }
    
    func getSoundCategory(_ idCategory: String) -> [Sound] {
        if let categorySound = categories.first(where: { $0.id == idCategory }) {
            return categorySound.sounds
        }
        
        return []
    }
    
    func getSoundsByHashtag(_ nameHashtag: String) -> [Sound] {
        let targetHashtag = "#\(nameHashtag.lowercased())"
        var result: [Sound] = []
        
        for category in categories {
            let matchedSounds = category.sounds.filter { sound in
                guard let hashtagString = sound.hashtag else { return false }
                
                let hashtags = hashtagString
                    .lowercased()
                    .split(separator: " ")
                    .map { String($0) }
                
                return hashtags.contains(targetHashtag)
            }
            
            result.append(contentsOf: matchedSounds)
        }
        
        return result
    }
    
    func getSoundByCategory(_ nameCategory: String) -> [Sound] {
        var result: [Sound] = []
        
        for category in categories {
            let sounds = category.sounds
            let matchedSounds = sounds.filter { sound in
                sound.category?.name?.lowercased() == nameCategory.lowercased()
            }
            
            result.append(contentsOf: matchedSounds)
        }
        
        return result
    }
    
    func getVideoByCategory(_ nameCategory: String) -> [Video] {
        var result: [Video] = []
        
        for category in categories {
            let matchedVideos = category.videos.filter { video in
                video.category?.name?.lowercased() == nameCategory.lowercased()
            }
            
            result.append(contentsOf: matchedVideos)
        }
        
        return result
    }
    
    func getFilteredAndRandomSounds(soundsToExclude: [Sound]) -> [Sound] {
        let allSounds = self.getAllSound()
        let filteredSounds = allSounds.filter { sound in
            !soundsToExclude.contains(where: { $0.id == sound.id })
        }
        
        return Array(filteredSounds.shuffled().prefix(10))
    }
}
