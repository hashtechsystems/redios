//
//  ParameterEncoding.swift
//  NetworkLayer
//
//  Created by Malcolm Kumwenda on 2018/03/05.
//  Copyright © 2018 Malcolm Kumwenda. All rights reserved.
//

import Foundation

public enum ParameterEncoding {
    case urlEncoding
    case jsonEncoding
    case formData
}
    
   
extension ParameterEncoding{
    
    func encode(request: inout URLRequest, body: Parameters?) throws {
        do {
            switch self {
            case .urlEncoding:
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = try body?.data(encoding: self)
            case .jsonEncoding:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try body?.data(encoding: self)
            case .formData:
                let boundary = UUID().uuidString
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = try body?.data(encoding: self, boundary: boundary)
            }
        }catch {
            throw error
        }
    }
}


public enum NetworkError : String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}
