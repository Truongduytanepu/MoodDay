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
    
    func getSoundNameAndThumb(_ idCategory: String) -> [SoundCategory] {
        var result: [SoundCategory] = []
        var uniqueNames: Set<String> = Set()
        
        guard let category = categories.first(where: { $0.id == idCategory }) else {
            return result
        }
        
        guard let sounds = category.sounds else {
            return result
        }
        
        for sound in sounds {
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
            return categorySound.sounds ?? []
        }
        
        return []
}
