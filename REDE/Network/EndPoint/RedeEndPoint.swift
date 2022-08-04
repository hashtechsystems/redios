//
//  RedeEndPoint.swift
//  AM2PM
//
//  Created by B@db0Y on 04/03/22.
//

import Foundation
import UIKit

public enum REDEApi {
    case uploadProfilePic(image: UIImage, key: String)
    case login(phone_number:String, password:String)
    case sites(lat:Double, long:Double)
    case fetchProfile
    case chargerDetails(chargerId: Int)
}

extension REDEApi: EndPointType {
    
    var url: URL {
        guard let url = URL(string: "http://44.196.217.181/redepay/redepay_laravel/index.php/api/") else { fatalError("baseURL could not be configured.")}
        switch self {
        case .login:
            return url.appendingPathComponent("login")
        case .sites:
            return url.appendingPathComponent("search-site")
        case .uploadProfilePic:
            return url.appendingPathComponent("change-profile-pic")
        case .fetchProfile:
            return url.appendingPathComponent("get-profile")
        case .chargerDetails:
            return url.appendingPathComponent("get-charging-station-by-id")
        }
    }
    
    
    var httpBody: Parameters? {
        switch self {
        case .login(let phone_number, let password):
            return ["phone_number": phone_number,
                    "password": password]
        case .sites(let lat, let long):
            return ["latitude": lat,
                    "longitude": long]
        case .uploadProfilePic(let image, let key):
            return [key: image]
        case .fetchProfile:
            return nil
        case .chargerDetails(let chargerId):
            return ["charger_id": chargerId]
        }
    }
    
    var httpHeaders: HTTPHeaders? {
        switch self {
        case .login:
            return nil
        case .sites, .chargerDetails, .fetchProfile, .uploadProfilePic:
            return ["Authorization": "Bearer \(UserDefaults.standard.loggedInToken() ?? "")"]
        }
    }
    
    var httpEncoding: ParameterEncoding {
        switch self {
        case .login, .sites, .fetchProfile, .chargerDetails:
            return .jsonEncoding
        case .uploadProfilePic:
            return .formData
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
}
