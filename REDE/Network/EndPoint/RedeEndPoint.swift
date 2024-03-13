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
    case transactionHistory
    case saveCardInfo(cardnumber : String , year : String, month : String)
    case getCardList
    case chargeCustomer(id : Int , qrcode : String)
    case makeApplePayment(qrcode : String,cryptogram:String)
    case deleteCard(id:Int)
    case checkrfid(site_id : Int,charger_id : Int)
    case siteDetails(id:Int)
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
        case .transactionHistory:
            return url.appendingPathComponent("get-payment-detail")
        case .saveCardInfo:
            return url.appendingPathComponent("create-customer-profile")
        case .getCardList:
            return url.appendingPathComponent("get-user-cards")
        case .chargeCustomer:
            return url.appendingPathComponent("charge-customer-profile")
        case .makeApplePayment:
            return url.appendingPathComponent("make-apple-payment")
        case .deleteCard:
            return url.appendingPathComponent("delete-user-card")
        case .checkrfid:
            return url.appendingPathComponent("check-rfid")
        case .siteDetails:
            return url.appendingPathComponent("get-site-by-id")
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
        case .fetchProfile, .getTransactionDetails, .deleteUser,.transactionHistory:
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
        case .saveCardInfo(let cardnumber, let year, let month):
            return ["card_number":cardnumber,"year":year,"month":month]
        case .getCardList:
            return nil
        case .chargeCustomer(let id, let qrcode):
            return ["id":id,"qr_code":qrcode]
        case .makeApplePayment(let qrcode, let cryptogram):
            return ["qr_code":qrcode,"cryptogram":cryptogram]
        case .deleteCard(let id):
            return ["id":id]
        case .checkrfid(let site_id,let charger_id):
            return ["site_id":site_id,"charger_id":charger_id]
        case .siteDetails(let id):
            return ["id":id]
        }
        
    }

    var httpHeaders: HTTPHeaders? {
        switch self {
        case .login, .register, .otp, .verifyOtp:
            return nil
        case .sites, .chargerDetails, .fetchProfile, .uploadProfilePic, .startCharging, .stopCharging, .makePayment, .updatePayment, .getTransactionDetails, .updatePaymentWithTransaction, .deleteUser, .updateProfile, .resetPassword,.mobilepaymentsettlement,.transactionHistory,.saveCardInfo,.getCardList,.chargeCustomer,.makeApplePayment,.deleteCard,.checkrfid,.siteDetails:
            return ["Authorization": "Bearer \(UserDefaults.standard.loggedInToken() ?? "")"]
        }
    }
    
    var httpEncoding: ParameterEncoding {
        switch self {
        case .login, .sites, .fetchProfile, .chargerDetails, .register, .startCharging, .stopCharging, .makePayment, .updatePayment, .getTransactionDetails, .updatePaymentWithTransaction, .deleteUser, .updateProfile, .otp, .verifyOtp, .resetPassword,.mobilepaymentsettlement,.transactionHistory,.saveCardInfo,.getCardList,.chargeCustomer,.makeApplePayment,.deleteCard,.checkrfid,.siteDetails:
            return .jsonEncoding
        case .uploadProfilePic:
            return .formData
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .login, .sites, .uploadProfilePic, .chargerDetails, .register, .startCharging, .stopCharging, .makePayment, .updatePayment, .updatePaymentWithTransaction, .deleteUser, .updateProfile, .otp, .verifyOtp, .resetPassword,.mobilepaymentsettlement,.saveCardInfo,.chargeCustomer,.makeApplePayment,.deleteCard,.checkrfid,.siteDetails:
            return .post
        case .fetchProfile, .getTransactionDetails,.transactionHistory,.getCardList:
            return .get
        }
    }
}
