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
}
