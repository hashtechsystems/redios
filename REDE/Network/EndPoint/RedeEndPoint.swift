//
//  RedeEndPoint.swift
//  AM2PM
//
//  Created by B@db0Y on 04/03/22.
//

import Foundation
import UIKit

public enum REDEApi {
    case register(name:String, email:String, phone_number:String, password:String)
    case uploadProfilePic(image: UIImage, key: String)
    case login(phone_number:String, password:String)
    case sites(lat:Double, long:Double)
    case fetchProfile
    case chargerDetails(qrCode: String)
    case makePayment(qrCode: String, /*cardDate: String, cardNumber: String,*/ cryptogram: String)
    case startCharging(ocppCbid: String)
    case stopCharging(ocppCbid: String, transactionId: Int)
    case updatePayment(authId: String, sessionId: Int)
    case getTransactionDetails(transactionId: Int)
}

extension REDEApi: EndPointType {
    
    var url: URL {
//        guard let url = URL(string: "http://44.196.217.181/redepay/redepay_laravel/index.php/api/") else { fatalError("baseURL could not be configured.")}
        
        //guard let url = URL(string: "http://13.59.84.54/laravel/index.php/api/") else { fatalError("baseURL could not be configured.")}
        
        guard let url = URL(string: "https://pay.rede.network/laravel/index.php/api/") else { fatalError("baseURL could not be configured.")}
        
        switch self {
        case .register:
            return url.appendingPathComponent("register-user")
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
        case .startCharging:
            return url.appendingPathComponent("socket-remote-start")
        case .stopCharging:
            return url.appendingPathComponent("socket-remote-stop")
        case .makePayment:
            return url.appendingPathComponent("make-mobile-payment")
        case .updatePayment:
            return url.appendingPathComponent("update-payment-with-transaction")//("update-payment")
        case .getTransactionDetails(let transactionId):
            return url.appendingPathComponent("get-transaction-detail-by-id/\(transactionId)")
        }
    }
    
    
    var httpBody: Parameters? {
        switch self {
        case .register(let name, let email, let phone_number, let password):
            return ["phone_number": phone_number, "email": email, "name": name,
                    "password": password]
        case .login(let phone_number, let password):
            return ["phone_number": phone_number,
                    "password": password]
        case .sites(let lat, let long):
            return ["latitude": lat,
                    "longitude": long]
        case .uploadProfilePic(let image, let key):
            return [key: image]
        case .fetchProfile, .getTransactionDetails:
            return nil
        case .chargerDetails(let qrCode):
            return ["qr_code": qrCode]
        case .startCharging(let ocppCbid):
            return ["ocpp_cbid": ocppCbid]
        case .stopCharging(let ocppCbid, let transactionId):
            return ["ocpp_cbid": ocppCbid, "transactionId": transactionId]
        case .makePayment(let qrCode, /*let cardDate, let cardNumber,*/ let cryptogram):
            return ["qr_code": qrCode, /*"card_date": cardDate, "card_number": cardNumber,*/ "cryptogram": cryptogram]
        case .updatePayment(let authId, let sessionId):
            return ["auth_id": authId, "session_id": sessionId]
        }
    }

    var httpHeaders: HTTPHeaders? {
        switch self {
        case .login, .register:
            return nil
        case .sites, .chargerDetails, .fetchProfile, .uploadProfilePic, .startCharging, .stopCharging, .makePayment, .updatePayment, .getTransactionDetails:
            return ["Authorization": "Bearer \(UserDefaults.standard.loggedInToken() ?? "")"]
        }
    }
    
    var httpEncoding: ParameterEncoding {
        switch self {
        case .login, .sites, .fetchProfile, .chargerDetails, .register, .startCharging, .stopCharging, .makePayment, .updatePayment, .getTransactionDetails:
            return .jsonEncoding
        case .uploadProfilePic:
            return .formData
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .login, .sites, .uploadProfilePic, .chargerDetails, .register, .startCharging, .stopCharging, .makePayment, .updatePayment:
            return .post
        case .fetchProfile, .getTransactionDetails:
            return .get
        }
    }
}
