//
//  VideoModel.swift
//  RankingFilterTop10
//
//  Created by ADMIN on 6/24/25.
//

import RealmSwift

class VideoModel: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var fileName: String = ""
    @Persisted var duration: Double = 0.0
    @Persisted var thumbnailData: Data
    @Persisted var createdAt: Date = Date()

    var fileURL: URL {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docURL.appendingPathComponent(fileName)
    }
}
