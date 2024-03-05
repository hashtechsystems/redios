//
//  User.swift
//  REDE
//
//  Created by Avishek on 27/07/22.
//

import Foundation


struct ForgetPasswordResponse: Codable {
    let status: Bool
    let message: String?
    let data: String?
}

struct RegistrationResponse: Codable {
    let status: Bool
    let data: String?
    let message: String?
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String?
    let token: String?
    let user: User?
}

// MARK: - User
public struct User: Codable {
    let id: Int
    var name, email, phoneNumber: String?
    let profilePic: String?
    var address: String?
    var imagePath: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email, address
        case phoneNumber = "phone_number"
        case profilePic = "profile_pic"
        case imagePath = "image_path"
    }
}


struct ProfileUpdateResponse: Codable {
    let status: Bool
    let data: String?
    let message: String?
}


struct FetchProfileResponse: Codable {
    let status: Bool
    let data: User?
    let message: String?
}

struct Response: Codable {
    let status: Bool
    let message: String?
}

struct rfidResponse: Codable {
    let status: Bool
    let data: String?
}

