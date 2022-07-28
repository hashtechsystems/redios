//
//  User.swift
//  REDE
//
//  Created by Avishek on 27/07/22.
//

import Foundation

struct LoginResponse: Codable {
    let success: Bool
    let token: String
    let user: User
}

// MARK: - User
struct User: Codable {
    let id: Int
    var name, email, phoneNumber, profilePic: String
    var imagePath: String

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case phoneNumber = "phone_number"
        case profilePic = "profile_pic"
        case imagePath = "image_path"
    }
}
