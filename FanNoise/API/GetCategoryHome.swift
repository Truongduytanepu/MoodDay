//
//  GetCategoryHome.swift
//  FanNoise
//
//  Created by Chiến Nguyễn on 24/04/2025.
//

import Foundation
import Alamofire

private class GetHomeCategoryResponse: Codable {
    var data: [HomeCategory]
}

class GetHomeCategory: API<[HomeCategory]> {
    
    override func path() -> String {
        return "api/sound/data-list"
    }
    
    override func baseURL() -> String {
        return Config.baseURL
    }
    
    override func method() -> HTTPMethod {
        return .get
    }
    
    override func getRequestType() -> RequestType {
        return .urlEncoded
    }
    
    override func convertObject(json: [String : Any], data: Data) throws -> [HomeCategory] {
        let entity = try DecodeAPIResponse(type: GetHomeCategoryResponse.self, data: data).data
        
        return entity
    }
}
