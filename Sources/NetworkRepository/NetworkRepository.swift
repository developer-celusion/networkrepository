//
//  NetworkRepository.swift
//
//
//  Created by Swapnil Nandgave on 21/11/19.
//  https://useyourloaf.com/blog/completion-handlers-as-an-alternative-to-delegation/

import Foundation

public protocol NetworkRepositoryDelegate {
    
    func networkRepositoryDefaultSessionHeaders() -> [String: String]?
    
}

open class NetworkRepository: NetworkRepositoryDelegate {
    
    public static let shared = NetworkRepository()
    
    private var sharedSession = URLSession.shared
    
    private var dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZZ"
    
    private var sessionHeaders: [String: String]? = nil
    
    var encoder = JSONEncoder()
    
    var decoder = JSONDecoder()
    
    var dateFormatter = DateFormatter()
    
    var oAuth2SessionRequestDelegate: OAuth2SessionRequestDelegate? = nil
    
    public private(set) var sessionConfiguration = URLSessionConfiguration.default
    
    private init() {
        self.setDateFormatter()
        self.timeout(60.0)
    }
    
    private func setDateFormatter() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.dateFormat
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    public func dateFormat(format:String) {
        self.dateFormat = format
        setDateFormatter()
    }
    
    public func timeout(_ timeoutInterval: TimeInterval, waitsForConnectivity: Bool = true) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        if #available(iOS 11, *) {
          configuration.waitsForConnectivity = waitsForConnectivity
        }
        self.sessionConfiguration = configuration
        self.sharedSession = URLSession(configuration: configuration)
    }
    
    public func setSessionHeaders(_ headers: [String: String]) {
        if headers.count > 0 {
            self.sessionHeaders = headers
        }
    }
    
    public func setOAuth2Delegate(delegate: OAuth2SessionRequestDelegate) {
        self.oAuth2SessionRequestDelegate = delegate
    }
    
    private func urlRequest(for request: SessionRequest) -> URLRequest {
        var dataRequest = URLRequest(url: request.url)
        dataRequest.httpMethod = request.method.rawValue
        dataRequest.allHTTPHeaderFields = request.headers
        if let headers = self.networkRepositoryDefaultSessionHeaders() {
            for (key, value) in headers {
                dataRequest.allHTTPHeaderFields?[key] = value
            }
        }
        dataRequest.httpBody = request.httpBody
        return dataRequest
    }
    
    public func execute(request: SessionRequest, completion: @escaping(DataSessionResponse)->Void) {
        let task = self.sharedSession.dataTask(with: urlRequest(for:request)) { (data, response, error) in
            DispatchQueue.main.async {
                let sessionResponse = DataSessionResponse(sessionRequest: request, data: data, response: response, error: error)
                guard error == nil else {
                    completion(sessionResponse)
                    return
                }
                guard data != nil else {
                    completion(sessionResponse)
                    return
                }
                if let response = (response as? HTTPURLResponse) {
                    sessionResponse.statusCode = response.statusCode
                }
                if let oAuth2Delegate = self.oAuth2SessionRequestDelegate {
                    if sessionResponse.statusCode == Int.UNAUTHORISED {
                        oAuth2Delegate.unauthoriseOAuth2SessionRequestFor(request, oldRequestCompletion: completion)
                    } else {
                        completion(sessionResponse)
                    }
                } else {
                    completion(sessionResponse)
                }
            }
        }
        task.taskDescription = request.identifier
        task.resume()
        
    }
    
    public func networkRepositoryDefaultSessionHeaders() -> [String : String]? {
        var allHTTPHeaderFields = [String: String]()
        if let headers = self.sessionHeaders {
            for (key, value) in headers {
                allHTTPHeaderFields[key] = value
            }
        }
        if let oAuth2Delegate = self.oAuth2SessionRequestDelegate, let headers = oAuth2Delegate.oAuth2SessionRequestHeaders() {
            for (key, value) in headers {
                allHTTPHeaderFields[key] = value
            }
        }
        return allHTTPHeaderFields.count > 0 ? allHTTPHeaderFields : nil
    }
    
}

extension SessionRequest {
    
    public func execute(completion: @escaping(DataSessionResponse)->Void) {
        NetworkRepository.shared.execute(request: self, completion: completion)
    }
    
    public func urlRequest(delegate: NetworkRepositoryDelegate)-> URLRequest {
        var dataRequest = URLRequest(url: self.url)
        dataRequest.httpMethod = self.method.rawValue
        dataRequest.allHTTPHeaderFields = self.headers
        if let headers = delegate.networkRepositoryDefaultSessionHeaders() {
            for (key, value) in headers {
                dataRequest.allHTTPHeaderFields?[key] = value
            }
        }
        dataRequest.httpBody = self.httpBody
        return dataRequest
    }
    
}
