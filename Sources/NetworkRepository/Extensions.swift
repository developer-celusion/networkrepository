//
//  Extensions.swift
//  
//  https://nshipster.com/swift-documentation/
//  Created by Swapnil Nandgave on 21/11/19.
//

import Foundation

// MARK: Encodable
extension Encodable {
    
    /**
     Helper method to get data for Encodable Protocol implemented classes and structs
     
     - Parameter Self
     
     - Returns: Data
     */
    public var dataValue: Data? {
        do {
            return try NetworkRepository.shared.encoder.encode(self)
        } catch {
            if NetworkRepository.shared.enableLogs {
                print("Data Value Encodable Network Repository ->")
                print(error)
            }
            return nil
        }
    }
    
    /**
     Helper method to get Dictionary for Encodable Protocol implemented classes and structs
     
     - Parameter Self
     
     - Returns: Dictionary
     */
    public var dictValue: [String:Any]? {
        if let value = self.dataValue {
            return value.dictValue
        } else {
            return nil
        }
    }
    
}

// MARK: Dictionary
extension Dictionary where Key == String, Value == Any  {
    
    /**
     Helper method to generate URL Query String from Dictionary
     
     - Parameter Self
     
     - Returns: String
     */
    public var queryString: String {
        var output: String = ""
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }
    
    /**
     Helper method to generate UTF8 Encoded Data for URL Query String
     
     - Parameter Self
     
     - Returns: Data
     */
    public var queryData: Data? {
        return queryString.data(using: .utf8)
    }
    
    /**
     Helper method to generate JSON Sesialised Data
     
     - Parameter Self
     
     - Returns: Data
     */
    public var dataValue: Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self)
        } catch {
            if NetworkRepository.shared.enableLogs {
                print("Data Value Network Repository ->")
                print(error)
            }
            return nil
        }
    }
    
    /**
     Helper method to search specified key. It uses keyPath method of NSDictionary Internally.
     
     - Parameter keyPath:Key to be searched
     
     - Returns: T
     */
    public func keyPathValue<T>(_ keyPath: String)-> T? {
        if let value = (self as NSDictionary).value(forKeyPath: keyPath) {
            return value as? T
        } else {
            return nil
        }
    }
    
    /**
     Helper method to try to parse Dictionary to Codable  Implemented Struct or Class
     
     - Parameter type:Codable Implemented Struct or Class Type
     
     - Returns: T
     */
    public func parse<T: Codable>(_ type: T.Type)->T? {
        if let value = self.dataValue {
            return value.parse(type)
        } else {
            return nil
        }
    }
    
}

// MARK: Array
extension Array where Element == [String: Any] {
    
    /**
     Helper method to get data for Encodable Protocol implemented classes and structs
     
     - Parameter Self
     
     - Returns: Data
     */
    public var dataValue: Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self)
        } catch {
            if NetworkRepository.shared.enableLogs {
                print("Array Data Value Network Repository ->")
                print(error)
            }
            return nil
        }
    }
    
    /**
     Helper method to try to parse Array to Array of Codable  Implemented Struct or Class
     
     - Parameter type:Codable Implemented Struct or Class Type
     
     - Returns: T
     */
    public func parseArray<T: Codable>(type: T.Type)-> [T]? {
        if let value = self.dataValue {
            return value.parseArray(type)
        } else {
            return nil
        }
    }
    
}

// MARK: String
extension String {
    
    /**
     Helper method to generate UTF8 Encoded Data
     
     - Parameter Self
     
     - Returns: Data
     */
    public var dataValue: Data? {
        return self.data(using: .utf8)
    }
    
    /**
     Helper method to generate Dictionary from JSON String
     
     - Parameter Self
     
     - Returns: [String: Any]
     */
    public var dictValue: [String: Any]? {
        if let data = dataValue {
            return data.dictValue
        }
        return nil
    }
    
    /**
    Helper method to generate Array from JSON String
    
    - Parameter Self
    
    - Returns: Array of [String: Any]
    */
    public var arrayValue: [[String: Any]]? {
        if let data = dataValue {
            return data.arrayValue
        }
        return nil
    }
    
    /**
    Helper method to try to parse JSON String to Codable  Implemented Struct or Class directly
    
    - Parameter type:Codable Implemented Struct or Class Type
    
    - Returns: T
    */
    public func parse<T: Codable>(_ type: T.Type)->T? {
        if let value = self.dataValue {
            return value.parse(type)
        } else {
            return nil
        }
    }
    
    /**
    Helper method to try to parse JSON Array to Codable  Implemented Struct or Class directly
    
    - Parameter type:Codable Implemented Struct or Class Type
    
    - Returns: T
    */
    public func parseArray<T: Codable>(type: T.Type)-> [T]? {
        if let value = self.dataValue {
            return value.parseArray(type)
        } else {
            return nil
        }
    }
    
}

// MARK: Data
extension Data {
    
    /**
    Helper method to generate String by UTF8 Encoding
    
    - Parameter Self
    
    - Returns: String
    */
    public var stringValue: String? {
        return String(data: self, encoding: .utf8)
    }
    
    /**
    Helper method to generate Dictionary from JSON Data
    
    - Parameter Self
    
    - Returns: [String: Any]
    */
    public var dictValue: [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any]
        } catch {
            if NetworkRepository.shared.enableLogs {
                print("Dict Value Network Repository ->")
                print(error)
            }
            return nil
        }
    }
    
    /**
    Helper method to generate Array of Dictionary from JSON Data
    
    - Parameter Self
    
    - Returns: Array [String: Any]
    */
    public var arrayValue: [[String: Any]]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as? [[String: Any]]
        } catch {
            if NetworkRepository.shared.enableLogs {
                print("Array Value Network Repository ->")
                print(error)
            }
            return nil
        }
    }
    
    /**
    Helper method to try to parse JSON Data to Codable  Implemented Struct or Class directly
    
    - Parameter type:Codable Implemented Struct or Class Type
    
    - Returns: T
    */
    public func parse<T: Codable>(_ type: T.Type)->T? {
        do {
            let item = try NetworkRepository.shared.decoder.decode(T.self, from: self)
            return item
        } catch {
            if NetworkRepository.shared.enableLogs {
                print("Parse Network Repository ->")
                print(error)
            }
            return nil
        }
    }
    
    /**
    Helper method to try to parse JSON Data to Array of Codable  Implemented Struct or Class directly
    
    - Parameter type:Codable Implemented Struct or Class Type
    
    - Returns: Array of T
    */
    public func parseArray<T: Codable>(_ type: T.Type)-> [T]? {
        do {
            let item = try NetworkRepository.shared.decoder.decode([T].self, from: self)
            return item
        } catch {
            if NetworkRepository.shared.enableLogs {
                print("Parse Array Network Repository ->")
                print(error)
            }
            return nil
        }
    }
    
}
