//
//  RedeEndPoint.swift
//  AM2PM
//
//  Created by B@db0Y on 04/03/22.
//

import Foundation
import UIKit

public enum REDEApi {
    case login(phone_number:String, password:String)
    case sites(lat:Double, long:Double)
    case uploadProfilePic(image: Data)
    case fetchProfile(user: User?)
}

extension REDEApi: EndPointType {
    
    var baseURL: URL {
        guard let url = URL(string: "http://44.196.217.181/redepay/redepay_laravel/index.php/api/") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .login:
            return "login"
        case .sites:
            return "search-site"
        case .uploadProfilePic:
            return "change-profile-pic"
        case .fetchProfile:
            return "get-profile"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .login, .sites, .uploadProfilePic:
            return .post
        case .fetchProfile:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .login(let phone_number, let password):
            return .requestParameters(bodyParameters: ["phone_number":phone_number,
                                                       "password":password],
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: nil)
        case .sites(let lat, let long):
            return .requestParametersAndHeaders(bodyParameters: ["latitude":lat,
                                                                 "longitude":long],
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: ["Authorization": "Bearer \(UserDefaults.standard.loggedInToken() ?? "")"])
        case .uploadProfilePic(let image):
            let data = MultipartFormData()
            data.addData(named: "profile_pic", data: image, mimeType: "img/jpeg")
            return .uploadFormDataAndHeaders(param: data, additionHeaders: ["Authorization": "Bearer \(UserDefaults.standard.loggedInToken() ?? "")"])
        case .fetchProfile:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: ["Authorization": "Bearer \(UserDefaults.standard.loggedInToken() ?? "")"])
        }
    }
    
//    var headers: HTTPHeaders? {
//        switch self {
//        case .login, .sites, .uploadProfilePic:
//            return nil
//        }
//    }
}
