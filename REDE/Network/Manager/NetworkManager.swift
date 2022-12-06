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

    func register(name: String, email: String, phone_number: String, password: String, completion: @escaping (_ response: String?,_ error: String?) -> ()) {
        router.request(.register(name: name, email: email, phone_number: phone_number, password: password)) { data, response, error in

            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(RegistrationResponse.self, from: responseData)
                        completion(apiResponse.data,nil)
                    }catch {
                        print(error)
                        completion(nil, error.localizedDescription)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func login(phone_number: String, password: String, completion: @escaping (_ response: User?,_ error: String?) -> ()) {
        router.request(.login(phone_number: phone_number, password: password)) { data, response, error in

            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(LoginResponse.self, from: responseData)
                        UserDefaults.standard.setLoggedInToken(value: apiResponse.token)
                        UserDefaults.standard.setUser(value: apiResponse.user)
                        completion(apiResponse.user,nil)
                    }catch {
                        print(error)
                        completion(nil, error.localizedDescription)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func sites(lat: Double, long: Double, completion: @escaping (_ response: [Site],_ error: String?) -> ()) {
        router.request(.sites(lat: lat, long: long)) { data, response, error in

            if error != nil {
                completion([], "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion([], NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(SiteResponse.self, from: responseData)
                        completion(apiResponse.data,nil)
                    }catch {
                        print(error)
                        completion([], error.localizedDescription)
                    }
                case .failure(let networkFailureError):
                    completion([], networkFailureError)
                }
            }
        }
    }
    
    
    
    func uploadProfilePic(image: UIImage, key: String, completion: @escaping (_ response: String?, _ error: String?) -> ()) {
        router.request(.uploadProfilePic(image: image, key: key)) { data, response, error in

            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        print(responseData)
                        let str = String(decoding: responseData, as: UTF8.self)
                        print(str)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(ProfilePicUpdateResponse.self, from: responseData)
                        completion(apiResponse.data, nil)
                    }catch {
                        print(error)
                        completion(nil, error.localizedDescription)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }


    func fetchProfile( user: User?, completion: @escaping (_ user: User?, _ error: String?) -> ()) {
        router.request(.fetchProfile) { data, response, error in

            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(FetchProfileResponse.self, from: responseData)
                        UserDefaults.standard.setUser(value: apiResponse.data)
                        completion(apiResponse.data, nil)
                    }catch {
                        print(error)
                        completion(nil, error.localizedDescription)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func fetchChargerDetails( qrCode: String, completion: @escaping (_ user: ChargerStation?, _ error: String?) -> ()) {
        
        router.request(.chargerDetails(qrCode: qrCode)) { data, response, error in

            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(ChargerStationDetailsResponse.self, from: responseData)
                        completion(apiResponse.data, nil)
                    }catch {
                        print(error)
                        completion(nil, error.localizedDescription)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    func startCharging( ocppCbid: String, completion: @escaping (_ transaction: Transaction?, _ error: String?) -> ()) {
        router.request(.startCharging(ocppCbid: ocppCbid)) { data, response, error in

            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(Transaction.self, from: responseData)
                        completion(apiResponse, nil)
                    }catch {
                        print(error)
                        completion(nil, error.localizedDescription)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    func stopCharging( ocppCbid: String, transactionId: Int, completion: @escaping (_ transaction: Transaction?, _ error: String?) -> ()) {
        router.request(.stopCharging(ocppCbid: ocppCbid, transactionId: transactionId)) { data, response, error in
            
            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(Transaction.self, from: responseData)
                        completion(apiResponse, nil)
                    }catch {
                        print(error)
                        completion(nil, error.localizedDescription)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }

    func makePayment(qrCode: String, /*cardDate: String, cardNumber: String,*/ cryptogram: String, completion: @escaping (_ success: Bool, _ authId: String?, _ error: String?) -> ()){
        router.request(.makePayment(qrCode: qrCode, /*cardDate: cardDate, cardNumber: cardNumber,*/ cryptogram: cryptogram)) { data, response, error in
            
            if error != nil {
                completion(false, nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(false, nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(PaymentResponse.self, from: responseData)
                        completion(apiResponse.status, apiResponse.authId, nil)
                    }catch {
                        print(error)
                        completion(false, nil, error.localizedDescription)
                    }
                case .failure(let networkFailureError):
                    completion(false, nil, networkFailureError)
                }
            }
        }
    }
    
    
    func updatePayment(authId: String, sessionId: Int, completion: @escaping (_ response: UpdatePaymentResponse?, _ error: String?) -> ()){
        router.request(.updatePayment(authId: authId, sessionId: sessionId)) { data, response, error in
            
            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(UpdatePaymentResponse.self, from: responseData)
                        completion(apiResponse, nil)
                    }catch {
                        print(error)
                        completion(nil, error.localizedDescription)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    func getTransactionDetails(transactionId: Int, completion: @escaping (_ response: TransactionDetails?, _ error: String?) -> ()) {
       
        router.request(.getTransactionDetails(transactionId: transactionId)) { data, response, error in
            
            if error != nil {
                completion(nil, error!.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(TransactionDetailsResponse.self, from: responseData)
                        completion(apiResponse.data, nil)
                    }catch {
                        print(error)
                        completion(nil, error.localizedDescription)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
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
