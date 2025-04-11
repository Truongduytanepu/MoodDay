//
//  Utils.swift
//  PlantIdentification
//
//  Created by Thanh Vu on 18/11/2020.
//

import Foundation

private struct Const {
    static let gbCapacity = 1024*1024
    static let mbCapacity = 1024
}

// swiftlint:disable identifier_name
func TimeStringFromSeconds(seconds: Int) -> String {
    let minute = seconds/60
    let second = seconds % 60

    return String.init(format: "%02d:%02d", minute, second)
}

// swiftlint:disable identifier_name
func FuckNan<T:FloatingPoint>(_ value: T) -> T {
    return value.isNaN ? T(0) : value
}

func DecodeAPIResponse<ResponseType:Codable>(type: ResponseType.Type, data: Data) throws -> ResponseType {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

    do {
        let response = try jsonDecoder.decode(type, from: data)
        return response
    } catch {
        let errorUserInfo = (error as NSError).userInfo
        print("Error: \(errorUserInfo)")
        throw APIError(domain: APIError.APIErrorDomain, code: APIError.Code.parseError.rawValue, userInfo: errorUserInfo)
    }
}
