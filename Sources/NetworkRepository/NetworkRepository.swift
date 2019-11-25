//
//  NetworkRepository.swift
//
//
//  Created by Swapnil Nandgave on 21/11/19.
//  https://useyourloaf.com/blog/completion-handlers-as-an-alternative-to-delegation/

import Foundation

open class NetworkRepository {
    
    public static let shared = NetworkRepository()
    
    private var sharedSession = URLSession.shared
    
    private var dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZZ"
    
    private var sessionHeaders: [String: String]? = nil
    
    var encoder = JSONEncoder()
    
    var decoder = JSONDecoder()
    
    var dateFormatter = DateFormatter()
    
    var oAuth2SessionRequestDelegate: OAuth2SessionRequestDelegate? = nil
    
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
    
    public func execute(request: SessionRequest, completion: @escaping(DataSessionResponse)->Void) {
        var dataRequest = URLRequest(url: request.url)
        dataRequest.httpMethod = request.method.rawValue
        dataRequest.allHTTPHeaderFields = request.headers
        if let headers = self.sessionHeaders {
            for (key, value) in headers {
                dataRequest.allHTTPHeaderFields?[key] = value
            }
        }
        if let oAuth2Delegate = self.oAuth2SessionRequestDelegate, let headers = oAuth2Delegate.oAuth2SessionRequestHeaders() {
            for (key, value) in headers {
                dataRequest.allHTTPHeaderFields?[key] = value
            }
        }
        dataRequest.httpBody = request.httpBody
        let task = self.sharedSession.dataTask(with: dataRequest) { (data, response, error) in
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
                completion(sessionResponse)
                if let oAuth2Delegate = self.oAuth2SessionRequestDelegate {
                    if sessionResponse.statusCode == Int.UNAUTHORISED {
                        oAuth2Delegate.unauthoriseOAuth2SessionRequestFor(request, oldRequestCompletion: completion)
                    }
                }
            }
        }
        task.taskDescription = request.identifier
        task.resume()
        
    }
    
}

extension SessionRequest {
    
    public func execute(completion: @escaping(DataSessionResponse)->Void) {
        NetworkRepository.shared.execute(request: self, completion: completion)
    }
    
}
