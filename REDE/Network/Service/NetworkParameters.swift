//
//  NetworkParameters.swift
//  REDE
//
//  Created by Avishek on 04/08/22.
//

import Foundation
import UIKit

public typealias Parameters = [String:Any]

extension Parameters{
    
    func data(encoding: ParameterEncoding, boundary: String? = nil) throws -> Data?{
        switch encoding {
        case .urlEncoding:
            var urlComponents = URLComponents()
            urlComponents.queryItems = [URLQueryItem]()
            for (key, value) in self{
                let queryItem = URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                urlComponents.queryItems?.append(queryItem)
            }
            return urlComponents.query?.data(using: .utf8)
        case .jsonEncoding:
            return try JSONSerialization.data(withJSONObject: self)
        case .formData:
            guard let boundary = boundary else { return nil }
            var data = Data()
            for (key, value) in self {
                if(value is String || value is NSString) {
                    data.append("--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                    data.append("\(value)\r\n".data(using: .utf8)!)
                }else if let image = value as? UIImage {
                    let r = arc4random()
                    let filename = "image_\(r).png"
                    data.append("--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
                    data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
                    data.append(image.pngData()!)
                    data.append("\r\n".data(using: .utf8)!)
                }
            }
            data.append("--\(boundary)--\r\n".data(using: .utf8)!)
            return data
        }
    }
    
}



