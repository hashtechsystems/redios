//
//  EndPoint.swift
//  NetworkLayer
//
//  Created by Malcolm Kumwenda on 2018/03/05.
//  Copyright © 2018 Malcolm Kumwenda. All rights reserved.
//

import Foundation

protocol EndPointType {
    var url: URL { get }
    var httpMethod: HTTPMethod { get }
    var httpBody: Parameters? { get }
    var httpHeaders: HTTPHeaders? { get }
    var httpEncoding: ParameterEncoding { get }
}

