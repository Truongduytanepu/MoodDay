//
//  FilterManager.swift
//  RankingFilterTop10
//
//  Created by Trương Duy Tân on 17/6/25.
//

import AVFoundation
import UIKit

class FilterManager {

    static let shared = FilterManager()
    
    private init() { }
    private var filters: [FilterModel] = []
    
    func getFilters() -> [FilterModel] {
        return self.filters
    }
    
    func updateFilters(_ filters: [FilterModel]) {
        self.filters = filters
    }
    
    func getRandomFilters(count: Int = 9) -> [FilterModel] {
        return Array(self.filters.prefix(count))
    }
    
    func getFilters(named names: [String]) -> [FilterModel] {
        let lowercasedNames = names.map { $0.lowercased() }
        let matched = self.filters.filter { lowercasedNames.contains($0.name.lowercased()) }
        return matched
    }
    
    func getFilterTrending(completion: @escaping ([FilterModel]) -> Void) {
        let validFilters = filters.filter { !$0.videos.isEmpty }
        var updatedFilters = validFilters
        let group = DispatchGroup()

        for index in 0..<updatedFilters.count {
            let video = updatedFilters[index].videos.first
            if let source = video?.source, let url = URL(string: source) {
                group.enter()
                self.generateThumbnail(url: url) { image in
                    updatedFilters[index].videoThumbImage = image
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion(updatedFilters)
        }
    }

    private func generateThumbnail(url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 0, preferredTimescale: 600)
        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, cgImage, _, _, _ in
            let image = cgImage.map { UIImage(cgImage: $0) }
            completion(image)
        }
    }
}
