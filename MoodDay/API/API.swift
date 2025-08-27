//
//  API.swift
//  TimeStamp
//
//  Created by Manh Nguyen Ngoc on 31/10/2022.
//
// swiftlint:disable all

import UIKit
import RxSwift
import Alamofire

enum RequestType {
    case urlEncoded, formData
}

class CommonResponseID<T: Codable>: Codable {
    var body: T
}

class CommonResponse<T: Codable>: Codable {
    var results: T
}

class APICommonErrorResponse: Codable {
    var status: Int
    var message: String?
}

class BaseAPI {
    func encoding() -> ParameterEncoding {
        return JSONEncoding.default
    }
    
    func parameters() -> [String: Any]? {
        return nil
    }
    
    func path() -> String {
        fatalError("Missing path")
    }
    
    func baseURL() -> String {
        return Config.baseURL
    }
    
    final func url() -> URL {
        let url = "\(baseURL())/\(path())"
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return URL(string: urlString!)!
    }
    
    func method() -> HTTPMethod {
        // Default http method is GET
        return .get
    }
    
    func headers() -> [String: String]? {
        return nil
    }
    
    func getRequestType() -> RequestType {
        return .urlEncoded
    }
}

class API<T>: BaseAPI {
    var currentRequest: DataRequest!
    private var isCancel: Bool = false
    
    func getUserAgent() -> String {
        let listUserAgent = [
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36",
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.125 Safari/537.36",
            "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36",
            "Opera/9.80 (Windows NT 6.1; WOW64) Presto/2.12.388 Version/12.18",
            "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36 OPR/43.0.2442.991",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36 OPR/56.0.3051.52",
            "Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14",
            "Opera/9.80 (Windows NT 5.1; U; ru) Presto/2.9.168 Version/11.50",
            "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36 OPR/43.0.2442.1144",
            "Mozilla/5.0 (Windows NT 6.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36 OPR/42.0.2393.94",
            "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)",
            "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)",
            "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; KTXN)",
            "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)",
            "Mozilla/5.0 (Windows NT 6.3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 YaBrowser/17.6.1.749 Yowser/2.5 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 YaBrowser/18.3.1.1232 Yowser/2.5 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 YaBrowser/17.3.1.840 Yowser/2.5 Safari/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/605.1.15 (KHTML, like Gecko)"
        ]
        
        return listUserAgent.randomElement()!
    }
    
    lazy var sessionManager: SessionManager = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        config.httpAdditionalHeaders = ["User-Agent": getUserAgent()]
        let manager = SessionManager(configuration: config)
        return manager
    }()
    
    func convertObject(json: [String: Any], data: Data) throws -> T {
        fatalError("Missing convert Object")
    }
    
    func exe() -> Observable<T> {
        let type = getRequestType()
        isCancel = false
        
        return Observable.create { (observer) -> Disposable in
            if type == .urlEncoded {
                self.urlEncoded(observer)
            } else {
                self.formData(observer)
            }
            
            return Disposables.create()
        }.take(1)
    }
    
    func urlEncoded(_ observer: AnyObserver<T>) {
        currentRequest = self.sessionManager.request(self.url(), method: self.method(), parameters: self.parameters(), encoding: self.encoding(), headers: self.headers()).responseJSON { (response) in
            if self.isCancel {
                return
            }
            
            Logging.log("📬 Received response from request: \n\(response.request!.cURL)")
            
            guard let httpResponse = response.response else {
                let err = APIError(code: APIError.Code.systemFail, message: response.error?.localizedDescription, api: self)
                observer.onError(err)
                return
            }
            
            if httpResponse.statusCode < 200 || httpResponse.statusCode > 300 {
                var error: APIError
                switch response.response?.statusCode {
                case 400:
                    error = APIError(code: APIError.Code.badRequest, api: self)
                case 404:
                    error = APIError(code: APIError.Code.systemFail, api: self)
                case 405:
                    error = APIError(code: APIError.Code.methodNotAllow, api: self)
                case 500:
                    error = APIError(code: APIError.Code.internalServerError, api: self)
                default:
                    error = APIError(code: APIError.Code.systemFail, message: response.error?.localizedDescription, api: self)
                }
                
                observer.onError(error)
            }
            
            if let json = response.value as? [String: Any], let data = response.data {
                
                let result = Result { try self.convertObject(json: json, data: data) }
               
                switch result {
                case .success(let output):
                    observer.onNext(output)
                case .failure(let error):
                    observer.onError(error)
                }
            } else {
                observer.onError(APIError(code: .systemFail, message: "Somethings went wrong", api: self))
            }
        }
    }
    
    func formData(_ observer: AnyObserver<T>) {
        self.sessionManager.upload(multipartFormData: { (multipartFormData) in
            
        }, to: self.url(), method: self.method(), headers: self.headers()) { (result) in
            switch result {
            case .success(let upload, _, _):
                self.currentRequest = upload.responseJSON { response in
                    if self.isCancel {
                        return
                    }
                    
                    if let error = response.error {
                        observer.onError(error)
                        return
                    }
                    
                    if let json = response.value as? [String: Any], let data = response.data {
                        
                        let result = Result { try self.convertObject(json: json, data: data) }
                        
                        switch result {
                        case .failure(let error):
                            observer.onError(error)
                        case .success(let output):
                            observer.onNext(output)
                        }
                    } else {
                        observer.onError(APIError(code: .systemFail, message: "Something went wrong", api: self))
                    }
                }
                
            case .failure(let error):
                observer.onError(error)
            }
        }
    }
    
    func cancelRequest() {
        isCancel = true
        currentRequest.cancel()
    }
    
    static func getAPI(from error: Error) -> BaseAPI? {
        let err = error as NSError
        let userInfo = err.userInfo
        if let api = userInfo[APIError.apiUserInfoKey] as? BaseAPI {
            return api
        }
        
        return nil
    }
}

