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
    case updateProfile(id: Int, name:String, email:String, phone_number:String, address: String)
    case uploadProfilePic(image: UIImage, key: String)
    case login(phone_number:String, password:String)
    case sites(lat:Double, long:Double)
    case fetchProfile
    case chargerDetails(qrCode: String)
    case makePayment(qrCode: String, /*cardDate: String, cardNumber: String,*/ cryptogram: String, connector_id: Int)
    case startCharging(ocppCbid: String, sequenceNumber: Int, authId: String)
    case stopCharging(ocppCbid: String, transactionId: Int)
    case updatePaymentWithTransaction(authId: String, sessionId: Int)
    case updatePayment(authId: String, sessionId: Int)
    case getTransactionDetails(transactionId: Int)
    case deleteUser
    case otp(phone_number: String)
    case verifyOtp(phone_number: String, otp: String)
    case resetPassword(phone_number: String, password: String, password_confirmation: String)
    case mobilepaymentsettlement(authId: String)
}

extension REDEApi: EndPointType {
    
    var url: URL {
//        guard let url = URL(string: "http://44.196.217.181/redepay/redepay_laravel/index.php/api/") else { fatalError("baseURL could not be configured.")}
        
        //guard let url = URL(string: "http://13.59.84.54/laravel/index.php/api/") else { fatalError("baseURL could not be configured.")}
        
        guard let url = URL(string: "https://pay.rede.network/laravel/index.php/api/") else { fatalError("baseURL could not be configured.")}
        
//        guard let url = URL(string: "http://paydev.rede.network/laravel/index.php/api/") else { fatalError("baseURL could not be configured.")}
        
        switch self {
        case .register:
            return url.appendingPathComponent("register-user")
        case .login:
            return url.appendingPathComponent("login")
        case .sites:
            return url.appendingPathComponent("search-site")
        case .updateProfile:
            return url.appendingPathComponent("update-profile")
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
        case .updatePaymentWithTransaction:
            return url.appendingPathComponent("update-payment-with-transaction")
        case .updatePayment:
            return url.appendingPathComponent("update-payment")
        case .getTransactionDetails(let transactionId):
            return url.appendingPathComponent("get-transaction-detail-by-id/\(transactionId)")
        case .deleteUser:
            return url.appendingPathComponent("delete-user")
        case .otp:
            return url.appendingPathComponent("send-otp")
        case .verifyOtp:
            return url.appendingPathComponent("verify-otp")
        case .resetPassword:
            return url.appendingPathComponent("reset-password")
        case .mobilepaymentsettlement:
            return url.appendingPathComponent("mobile-payment-settlement-by-auth-id")
        }
    }
    
    
    var httpBody: Parameters? {
        switch self {
        case .register(let name, let email, let phone_number, let password):
            return ["phone_number": phone_number, "email": email, "name": name,
                    "password": password]
        case .updateProfile(let id, let name, let email, let phone_number, let address):
            return ["id": id, "phone_number": phone_number, "email": email, "name": name, "address" : address]
        case .login(let phone_number, let password):
            return ["phone_number": phone_number,
                    "password": password]
        case .sites(let lat, let long):
            return ["latitude": lat,
                    "longitude": long]
        case .uploadProfilePic(let image, let key):
            return [key: image]
        case .fetchProfile, .getTransactionDetails, .deleteUser:
            return nil
        case .chargerDetails(let qrCode):
            return ["qr_code": qrCode]
        case .startCharging(let ocppCbid, let sequenceNumber, let authId):
            return ["ocpp_cbid": ocppCbid, "connector_id": sequenceNumber, "auth_id": authId]
        case .stopCharging(let ocppCbid, let transactionId):
            return ["ocpp_cbid": ocppCbid, "transactionId": transactionId]
        case .makePayment(let qrCode, /*let cardDate, let cardNumber,*/ let cryptogram, let connector_id):
            return ["qr_code": qrCode, /*"card_date": cardDate, "card_number": cardNumber,*/ "cryptogram": cryptogram, "connector_id" : connector_id]
        case .updatePayment(let authId, let sessionId):
            return ["auth_id": authId, "session_id": sessionId]
        case .updatePaymentWithTransaction(let authId, let sessionId):
            return ["auth_id": authId, "session_id": sessionId]
        case .otp(let phone_number):
            return ["phone_number": phone_number]
        case .verifyOtp(let phone_number, let otp):
            return ["phone_number": phone_number, "otp": otp]
        case .resetPassword(let phone_number, let password, let password_confirmation):
            return ["phone_number": phone_number, "password": password, "password_confirmation": password_confirmation]
        case .mobilepaymentsettlement(let auth_id):
            return ["auth_id":auth_id]
        }
        
    }

    var httpHeaders: HTTPHeaders? {
        switch self {
        case .login, .register, .otp, .verifyOtp:
            return nil
        case .sites, .chargerDetails, .fetchProfile, .uploadProfilePic, .startCharging, .stopCharging, .makePayment, .updatePayment, .getTransactionDetails, .updatePaymentWithTransaction, .deleteUser, .updateProfile, .resetPassword,.mobilepaymentsettlement:
            return ["Authorization": "Bearer \(UserDefaults.standard.loggedInToken() ?? "")"]
        }
    }
    
    var httpEncoding: ParameterEncoding {
        switch self {
        case .login, .sites, .fetchProfile, .chargerDetails, .register, .startCharging, .stopCharging, .makePayment, .updatePayment, .getTransactionDetails, .updatePaymentWithTransaction, .deleteUser, .updateProfile, .otp, .verifyOtp, .resetPassword,.mobilepaymentsettlement:
            return .jsonEncoding
        case .uploadProfilePic:
            return .formData
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .login, .sites, .uploadProfilePic, .chargerDetails, .register, .startCharging, .stopCharging, .makePayment, .updatePayment, .updatePaymentWithTransaction, .deleteUser, .updateProfile, .otp, .verifyOtp, .resetPassword,.mobilepaymentsettlement:
            return .post
        case .fetchProfile, .getTransactionDetails:
            return .get
        }
    }
}
