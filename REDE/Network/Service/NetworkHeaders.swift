//
//  HTTPTask.swift
//  NetworkLayer
//
//  Created by Malcolm Kumwenda on 2018/03/05.
//  Copyright © 2018 Malcolm Kumwenda. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String:String]

extension HTTPHeaders{
    func configure(request: inout URLRequest){
        for (key, value) in self {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
