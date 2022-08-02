//
//  RedeEndPoint.swift
//  AM2PM
//
//  Created by B@db0Y on 04/03/22.
//

import Foundation
import UIKit

public enum REDEApi {
    case uploadProfilePic
    case login(phone_number:String, password:String)
    case sites(lat:Double, long:Double)
    case fetchProfile
    case chargerDetails(chargerId: Int)
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
        case .chargerDetails:
            return "get-charging-station-by-id"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .login, .sites, .uploadProfilePic, .chargerDetails:
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
        case .uploadProfilePic:
            return .requestFormDataHeaders(additionHeaders: ["Authorization": "Bearer \(UserDefaults.standard.loggedInToken() ?? "")"])
        case .fetchProfile:
            return .requestParametersAndHeaders(bodyParameters: nil,
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: ["Authorization": "Bearer \(UserDefaults.standard.loggedInToken() ?? "")"])
        case .chargerDetails(let chargerId):
            return .requestParametersAndHeaders(bodyParameters: ["charger_id":chargerId],
                                                bodyEncoding: .jsonEncoding,
                                                urlParameters: nil,
                                                additionHeaders: ["Authorization": "Bearer \(UserDefaults.standard.loggedInToken() ?? "")"])
        }
    }
}
