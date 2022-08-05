//
//  User.swift
//  REDE
//
//  Created by Avishek on 27/07/22.
//

import Foundation


struct RegistrationResponse: Codable {
    let status: Bool
    let data: String
}

struct LoginResponse: Codable {
    let success: Bool
    let token: String
    let user: User
}

// MARK: - User
public struct User: Codable {
    let id: Int
    var name, email, phoneNumber, profilePic, address: String
    var imagePath: String

    enum CodingKeys: String, CodingKey {
        case id, name, email, address
        case phoneNumber = "phone_number"
        case profilePic = "profile_pic"
        case imagePath = "image_path"
    }
}


struct ProfilePicUpdateResponse: Codable {
    let status: Bool
    let data: String
}


struct FetchProfileResponse: Codable {
    let status: Bool
    let data: User
}
