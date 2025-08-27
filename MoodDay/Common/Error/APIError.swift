//
//  APIError.swift
//  PlantIdentification
//
//  Created by Manh Nguyen Ngoc on 01/04/2021.
//

import Foundation

class APIError: NSError {
    static let APIErrorDomain = "APIErrorDomain"
    static let apiUserInfoKey = "API"

    enum Code: Int {
        case systemFail = -1
        case success = 200
        case parseError = -1000
        case paramsError = -1001
        case badRequest = 400
        case notFound = 404
        case methodNotAllow = 405
        case internalServerError = 500
        case sessionTimeout = -2
    }

    init(error: APICommonErrorResponse, api: BaseAPI? = nil) {
        var userInfo: [String:Any] = [NSLocalizedDescriptionKey: error.message ?? ""]
        if api != nil {
            userInfo[APIError.apiUserInfoKey] = api
        }
        
        super.init(domain: APIError.APIErrorDomain, code: error.status, userInfo: userInfo)
    }
    
    init(code: APIError.Code, message: String? = nil, api: BaseAPI? = nil) {
        var userInfo: [String:Any] = [NSLocalizedDescriptionKey: message ?? ""]
        if api != nil {
            userInfo[APIError.apiUserInfoKey] = api
        }
        
        super.init(domain: APIError.APIErrorDomain, code: code.rawValue, userInfo: userInfo)
    }

    override init(domain: String, code: Int, userInfo dict: [String : Any]? = nil) {
        super.init(domain: domain, code: code, userInfo: dict)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static var parseError: APIError {
        return APIError(code: Code.parseError)
    }
}
