//
//  NetworkManager.swift
//  NetworkLayer
//
//  Created by Malcolm Kumwenda on 2018/03/11.
//  Copyright © 2018 Malcolm Kumwenda. All rights reserved.
//

import Foundation
import UIKit

enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

enum Result<String>{
    case success
    case failure(String)
}

struct NetworkManager {

    let router = Router<REDEApi>()
    
    func generateOtp(phone_number: String) async -> (Bool, String?){
        await withCheckedContinuation({ continuation in
            router.request(.otp(phone_number: phone_number)) { data, response, error in
                if let error = error {
                    continuation.resume(returning: (false, error.localizedDescription))
                    return
                }
                
                guard let responseData = data else {
                    continuation.resume(returning: (false, NetworkResponse.noData.rawValue))
                    return
                }
                
                do {
                    let apiResponse = try JSONDecoder().decode(ForgetPasswordResponse.self, from: responseData)
                    continuation.resume(returning: (apiResponse.status, apiResponse.message ?? "Unkown error."))
                }catch {
                    continuation.resume(returning: (false, error.localizedDescription))
                }
            }
        })
    }
    
    func verifyOtp(phone_number: String, otp: String) async -> (Bool, String?){
        await withCheckedContinuation({ continuation in
            router.request(.verifyOtp(phone_number: phone_number, otp: otp)) { data, response, error in
                if let error = error {
                    continuation.resume(returning: (false, error.localizedDescription))
                    return
                }
                
                guard let responseData = data else {
                    continuation.resume(returning: (false, NetworkResponse.noData.rawValue))
                    return
                }
                
                do {
                    let apiResponse = try JSONDecoder().decode(ForgetPasswordResponse.self, from: responseData)
                    continuation.resume(returning: (apiResponse.status, apiResponse.message ?? "Unkown error."))
                }catch {
                    continuation.resume(returning: (false, error.localizedDescription))
                }
            }
        })
    }
    
    func resetPassword(phone_number: String, password: String, confirmPassword: String) async -> (Bool, String?){
        await withCheckedContinuation({ continuation in
            router.request(.resetPassword(phone_number: phone_number, password: password, password_confirmation: confirmPassword)) { data, response, error in
                if let error = error {
                    continuation.resume(returning: (false, error.localizedDescription))
                    return
                }
                
                guard let responseData = data else {
                    continuation.resume(returning: (false, NetworkResponse.noData.rawValue))
                    return
                }
                
                do {
                    let apiResponse = try JSONDecoder().decode(ForgetPasswordResponse.self, from: responseData)
                    continuation.resume(returning: (apiResponse.status, apiResponse.message ?? "Unkown error."))
                }catch {
                    continuation.resume(returning: (false, error.localizedDescription))
                }
            }
        })
    }

    
    func register(name: String, email: String, phone_number: String, password: String, completion: @escaping (_ response: String?,_ error: String?) -> ()) {
        router.request(.register(name: name, email: email, phone_number: phone_number, password: password)) { data, response, error in
            
            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                //print(responseData)
                _ = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                //print(jsonData)
                let apiResponse = try JSONDecoder().decode(RegistrationResponse.self, from: responseData)
                
                if apiResponse.status {
                    completion(apiResponse.data, nil)
                }
                else {
                    completion(nil, apiResponse.message ?? "Unkown error occured. Error message not found.")
                }
            }catch {
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    func login(phone_number: String, password: String, completion: @escaping (_ response: User?,_ error: String?) -> ()) {
        router.request(.login(phone_number: phone_number, password: password)) { data, response, error in

            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                //print(responseData)
                //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                //print(jsonData)
                let apiResponse = try JSONDecoder().decode(LoginResponse.self, from: responseData)
                
                if apiResponse.success {
                    UserDefaults.standard.setLoggedInToken(value: apiResponse.token)
                    UserDefaults.standard.setUser(value: apiResponse.user)
                    completion(apiResponse.user, nil)
                }
                else {
                    completion(nil, apiResponse.message ?? "Unkown error occured. Error message not found.")
                }
            }catch {
                //print(error)
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    func updateProfile(id: Int, name: String, email: String, phone_number: String, address: String, completion: @escaping (_ response: String?,_ error: String?) -> ()) {
        router.request(.updateProfile(id: id, name: name, email: email, phone_number: phone_number, address: address)) { data, response, error in

            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                //print(responseData)
                //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                //print(jsonData)
                let apiResponse = try JSONDecoder().decode(ProfileUpdateResponse.self, from: responseData)
                
                if apiResponse.status {
                    completion(apiResponse.data, nil)
                }
                else {
                    completion(nil, apiResponse.message ?? "Unkown error occured. Error message not found.")
                }
                
            }catch {
                //print(error)
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    
    func sites(lat: Double, long: Double, completion: @escaping (_ response: [Site],_ error: String?) -> ()) {
        router.request(.sites(lat: lat, long: long)) { data, response, error in

            if let error = error {
                completion( [], error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion( [], NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                //print(responseData)
                //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                //print(jsonData)
                let apiResponse = try JSONDecoder().decode(SiteResponse.self, from: responseData)
                
                if apiResponse.status {
                    completion(apiResponse.data ?? [], nil)
                }
                else {
                    completion([], apiResponse.message ?? "Unkown error occured. Error message not found.")
                }
                
            }catch {
                print(error)
                completion([], error.localizedDescription)
            }
        }
    }
    
    
    
    func uploadProfilePic(image: UIImage, key: String, completion: @escaping (_ response: String?, _ error: String?) -> ()) {
        router.request(.uploadProfilePic(image: image, key: key)) { data, response, error in

            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                //print(responseData)
                //let str = String(decoding: responseData, as: UTF8.self)
                //print(str)
                //let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
                //print(jsonData)
                let apiResponse = try JSONDecoder().decode(ProfileUpdateResponse.self, from: responseData)
                
                if apiResponse.status {
                    completion(apiResponse.data, nil)
                }
                else {
                    completion(nil, apiResponse.message ?? "Unkown error occured. Error message not found.")
                }
            }catch {
                //print(error)
                completion(nil, error.localizedDescription)
            }
            
        }
    }


    func fetchProfile( user: User?, completion: @escaping (_ user: User?, _ error: String?) -> ()) {
        router.request(.fetchProfile) { data, response, error in

            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(FetchProfileResponse.self, from: responseData)
                
                if apiResponse.status {
                    UserDefaults.standard.setUser(value: apiResponse.data)
                    completion(apiResponse.data, nil)
                }
                else {
                    completion(nil, apiResponse.message ?? "Unkown error occured. Error message not found.")
                }
            }catch {
                //print(error)
                completion(nil, error.localizedDescription)
            }
            
        }
    }
    
    
    func fetchChargerDetails( qrCode: String, completion: @escaping (_ user: ChargerStation?, _ error: String?) -> ()) {
        
        router.request(.chargerDetails(qrCode: qrCode)) { data, response, error in

            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(ChargerStationDetailsResponse.self, from: responseData)
                
                if apiResponse.status {
                    completion(apiResponse.data, nil)
                }
                else {
                    completion(nil, apiResponse.message ?? "Charger unavailable.")
                }
            }catch {
                //print(error)
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    
    func startCharging( ocppCbid: String, sequenceNumber: Int, authId: String, completion: @escaping (_ transaction: Transaction?, _ error: String?) -> ()) {
        router.request(.startCharging(ocppCbid: ocppCbid, sequenceNumber: sequenceNumber, authId: authId)) { data, response, error in

            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(Transaction.self, from: responseData)
                
                guard let message = apiResponse.result else {
                    completion(apiResponse, nil)
                    return
                }
                
                completion(nil, message)
                
            }catch {
                //print(error)
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    func stopCharging( ocppCbid: String, transactionId: Int, completion: @escaping (_ transaction: Transaction?, _ error: String?) -> ()) {
        router.request(.stopCharging(ocppCbid: ocppCbid, transactionId: transactionId)) { data, response, error in
            
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(Transaction.self, from: responseData)
                
                guard let message = apiResponse.result else {
                    completion(apiResponse, nil)
                    return
                }
                
                completion(nil, message)
            }catch {
                //print(error)
                completion(nil, error.localizedDescription)
            }
            
        }
    }

    func makePayment(qrCode: String, /*cardDate: String, cardNumber: String,*/ cryptogram: String, connectorId: Int, completion: @escaping (_ success: Bool, _ authId: String?, _ error: String?) -> ()){
        router.request(.makePayment(qrCode: qrCode, /*cardDate: cardDate, cardNumber: cardNumber,*/ cryptogram: cryptogram, connector_id: connectorId)) { data, response, error in
            
            if let error = error {
                completion(false, nil, error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion(false, nil, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(PaymentResponse.self, from: responseData)
                
                if apiResponse.status {
                    completion(apiResponse.status, apiResponse.authId, nil)
                }
                else {
                    completion(false, nil, apiResponse.message ?? "Unkown error occured. Error message not found.")
                }
            }catch {
                //print(error)
                completion(false, nil, error.localizedDescription)
            }
        }
    }
    
    
    func updatePaymentWithTransaction(authId: String, sessionId: Int, completion: @escaping (_ response: UpdatePaymentResponse?, _ error: String?) -> ()){
        router.request(.updatePaymentWithTransaction(authId: authId, sessionId: sessionId)) { data, response, error in
            
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(UpdatePaymentResponse.self, from: responseData)
                
                if apiResponse.status {
                    completion(apiResponse, nil)
                }
                else {
                    completion(nil, apiResponse.message ?? "Unkown error occured. Error message not found.")
                }
                
            }catch {
                //print(error)
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    
    func updatePayment(authId: String, sessionId: Int, completion: @escaping (_ response: UpdatePaymentResponse?, _ error: String?) -> ()){
        router.request(.updatePayment(authId: authId, sessionId: sessionId)) { data, response, error in
            
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(UpdatePaymentResponse.self, from: responseData)
                
                if apiResponse.status {
                    completion(apiResponse, nil)
                }
                else {
                    completion(nil, apiResponse.message ?? "Unkown error occured. Error message not found.")
                }
                
            }catch {
                //print(error)
                completion(nil, error.localizedDescription)
            }
            
        }
    }
    
    
    func getTransactionDetails(transactionId: Int, completion: @escaping (_ response: TransactionDetails?, _ error: String?) -> ()) {
       
        router.request(.getTransactionDetails(transactionId: transactionId)) { data, response, error in
            
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                var apiResponse = try JSONDecoder().decode(TransactionDetailsResponse.self, from: responseData)
                
                if apiResponse.status {
                    apiResponse.data?.parseMeterValues()
                    completion(apiResponse.data, nil)
                }
                else {
                    completion(nil, apiResponse.message ?? "Unkown error occured. Error message not found.")
                }
            }catch {
                //print(error)
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    func deleteUser(completion: @escaping (_ success: Bool, _ message: String?) -> ()) {
        router.request(.deleteUser) { data, response, error in

            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            guard let responseData = data else {
                completion(false, NetworkResponse.noData.rawValue)
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(ProfileUpdateResponse.self, from: responseData)

                if apiResponse.status {
                    completion(apiResponse.status, apiResponse.data)
                }
                else {
                    completion(false, apiResponse.message ?? "Unkown error occured. Error message not found.")
                }
                
                
            }catch {
                //print(error)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
