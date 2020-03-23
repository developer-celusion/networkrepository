//
//  SessionRequest.swift
//  
//
//  Created by Swapnil Nandgave on 21/11/19.
//

import Foundation

//MARK: HTTP Method
public enum URLSessionMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PATCH = "PATCH"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

/**
 Outlined most famous Headers like JSON, FORM_URL_ENCODING and GZIP
 */
//MARK: Session Header
public enum SessionHeader: String {
    
    public static let HEADER_KEY_CONTENT_TYPE = "Content-Type"
    
    case JSON = "application/json"
    case FORM_URL_ENCODING = "application/x-www-form-urlencoded"
    case gzip = "gzip"
}

/**
 Status codes
 */
//MARK: Status Codes
extension Int {
    public static let INVALID_STATUS_CODE = -1
    public static let UNAUTHORISED = 401
    public static let URL_NOT_FOUND = 404
    public static let BAD_REQUEST = 400
}

/**
 Createe Request with default URLSession. It works only in foreground not in background.
 - Parameter identifier: Unique ID for session request. Default value is UUID().uuidString
 - Parameter url: URL
 - Parameter method: Http Method like GET or POST
 - Parameter headers: It identifier the request and adds headers before execution e.g application/json for POST Request with JSON Data.
 - Parameter httpBody: You can use helper methods of Request to generate Data. JSON Data or Http Form Data
 */
public class SessionRequest {
    
    public static let HEADER_X_WWW_FORM_ENCODING = [SessionHeader.HEADER_KEY_CONTENT_TYPE: SessionHeader.FORM_URL_ENCODING.rawValue]
    public static let HEADER_JSON_ENCODING = [SessionHeader.HEADER_KEY_CONTENT_TYPE: SessionHeader.JSON.rawValue]
    
    public static let PRIORITY_HIGH = URLSessionTask.highPriority
    public static let PRIORITY_LOW = URLSessionTask.lowPriority
    
    var identifier: String = UUID().uuidString
    var url: URL
    var method: URLSessionMethod = .GET
    var headers: [String: String]? = nil
    var httpBody: Data? = nil
    var priority: Float = URLSessionTask.defaultPriority
    
    public init(identifier: String = UUID().uuidString, url: URL, method: URLSessionMethod = .GET, headers: [String: String]? = nil, httpBody: Data? = nil, priority: Float = URLSessionTask.defaultPriority) {
        self.identifier = identifier
        self.url = url
        self.method = method
        self.headers = headers
        self.httpBody = httpBody
        self.priority = priority
    }
    
}

//MARK: Session Request Extension methods
extension SessionRequest {
    
    /**
     It appends list of GET Parameters into Request. It adds only which are passed without replacing existing e.g. name=<Name>&address=<address>
     */
    public func appendUrl(with params: [String: Any]) {
        if var sUrl = URLComponents(url: url, resolvingAgainstBaseURL: true), params.count > 0 {
            sUrl.queryItems = params.map({ (keyValue) -> URLQueryItem in
                let (key, value) = keyValue
                return URLQueryItem(name: key, value: String(describing: value))
            })
            sUrl.percentEncodedQuery = sUrl.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            self.url = sUrl.url!
        }
    }
    
    /**
    Set http body by converting Codable object into JSON Data
    */
    public func setHttpBody<T: Codable>(with item: T) {
        if let dict = item.dictValue {
            setHttpBody(item: dict)
        }
    }
    /**
     Set http body by converting Array of Codable object into JSON Data
     */
    public func setHttpBody<T: Codable>(with items:[T]) {
        var array = [[String:Any]]()
        for item in items {
            array.append(item.dictValue!)
        }
        setHttpBody(items: array)
    }
    
    /**
     Set http body by converting dictionary into JSON Data
     */
    public func setHttpBody(item: [String: Any], urlEncoding: Bool = false) {
        let newHeaders = urlEncoding ? SessionRequest.HEADER_X_WWW_FORM_ENCODING : SessionRequest.HEADER_JSON_ENCODING
        if let data = (urlEncoding ? item.queryData : item.dataValue) {
            self.httpBody = data
            
        }
        if let headers = self.headers, headers.count > 0 {
            for (key,value) in newHeaders {
                self.headers?[key] = value
            }
        } else {
            self.headers = newHeaders
        }
    }
    
    /**
     Set http body by converting Array of dictionary into JSON Data
     */
    public func setHttpBody(items: [[String: Any]]) {
        let newHeaders = SessionRequest.HEADER_JSON_ENCODING
        if let data = items.dataValue {
            self.httpBody = data
        }
        if let headers = self.headers, headers.count > 0 {
            for (key,value) in newHeaders {
                self.headers?[key] = value
            }
        } else {
            self.headers = newHeaders
        }
    }
    
}

// MARK: Session Response
public protocol SessionResponse {
    
    var identifier: String { get }
    var statusCode: Int { get set }
    var response: URLResponse? { get set }
    var error: Error? { get set }
    
}

extension SessionResponse {
    
    /**
    Checks whether request is executed or not
    */
    public var isValid: Bool {
        statusCode != Int.INVALID_STATUS_CODE
    }
    
    /**
    Checks whether request is successed or not. It is based on status code. As per standard HTTP request success range is 200-299
    */
    public var isSuccess: Bool {
        (200..<300).contains(statusCode)
    }
    
    /**
    Checks whether request is errored from client side or not. It is based on status code. As per standard HTTP request client error range is 400-499
    */
    public var hasClientError: Bool {
        (400..<500).contains(statusCode)
    }
    
    /**
    Checks whether request is errored from server side or not. It is based on status code. As per standard HTTP request client error range is 400-499
    */
    public var hasServerError: Bool {
        (500..<600).contains(statusCode)
    }
    
}

/**
 Implemented Class of Session Response
 - Parameter identifier: Unique identifier for Session Request
 - Parameter statusCode: Status code of HttpURLResponse
 - Parameter response: URLResponse of dataRequest
 - Parameter error: Error of dataRequest
 - Parameter data: Results data
 - Parameter sessionRequest: session request
 */
public class DataSessionResponse: SessionResponse {
    
    public var identifier: String
    public var statusCode = Int.INVALID_STATUS_CODE
    public var response: URLResponse?
    public var error: Error?
    public var data: Data?
    public var sessionRequest: SessionRequest?
    
    public init(sessionRequest: SessionRequest, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        self.identifier = sessionRequest.identifier
        self.data = data
        self.response = response
        self.error = error
        self.sessionRequest = sessionRequest
    }
    
}

extension DataSessionResponse {
    
    /**
    Helper method to generate String by UTF8 Encoding
    
    - Parameter Self
    
    - Returns: String
    */
    public var stringValue: String? {
        if let value = data {
            return value.stringValue
        } else {
            return nil
        }
    }
    
    /**
    Helper method to generate Dictionary from JSON Data
    
    - Parameter Self
    
    - Returns: [String: Any]
    */
    public var dictValue: [String: Any]? {
        if let data = self.data {
            return data.dictValue
        }
        return nil
    }
    
    /**
    Helper method to generate Array of Dictionary from JSON Data
    
    - Parameter Self
    
    - Returns: Array [String: Any]
    */
    public var arrayValue: [[String: Any]]? {
        if let data = self.data {
            return data.arrayValue
        }
        return nil
    }
    
    /**
    Helper method to try to parse JSON Data to Codable  Implemented Struct or Class directly
    
    - Parameter type:Codable Implemented Struct or Class Type
    
    - Returns: T
    */
    public func parse<T: Codable>(_ type: T.Type)->T? {
        if let data = self.data {
            return data.parse(type)
        } else {
           return nil
        }
    }
    
    /**
    Helper method to try to parse JSON Data to Array of Codable  Implemented Struct or Class directly
    
    - Parameter type:Codable Implemented Struct or Class Type
    
    - Returns: Array of T
    */
    public func parseArray<T: Codable>(_ type: T.Type)-> [T]? {
        if let data = self.data {
            return data.parseArray(type)
        } else {
           return nil
        }
    }
    
}


