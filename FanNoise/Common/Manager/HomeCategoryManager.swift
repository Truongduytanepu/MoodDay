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
    
    func getVideoCategory(_ idCategory: String) -> [Video] {
        if let category = categories.first(where: { $0.id == idCategory }) {
            return category.videos
        }
        
        return []
    }
    
    func getAllVideos() -> [Video] {
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
}
