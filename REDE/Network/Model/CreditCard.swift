//
//  CreditCard.swift
//  REDE
//
//  Created by Riddhi Makwana on 23/01/24.
//

import Foundation

struct CreditCardResponse : Codable {
    let status : Bool?
    let data : [CreditCard]?

    enum CodingKeys: String, CodingKey {

        case status = "status"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Bool.self, forKey: .status)
        data = try values.decodeIfPresent([CreditCard].self, forKey: .data)
    }

}
struct CreditCard: Codable {
    let id: Int
    let cardNumber, expiryDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case cardNumber = "card_number"
        case expiryDate = "expiry_date"
    }
}

struct SaveCardResponse: Codable {
    let status: Bool
    let customer_profile_id: String?
    let customer_payment_profile_id: String?
}

struct CardChargedResponse: Codable {
    let status: Bool
    let description: String?
    let ocppCbid: String?
    let transactionId: String?
    let authId: String?
    
}
