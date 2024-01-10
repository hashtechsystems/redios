//
//  Histroy.swift
//  REDE
//
//  Created by Riddhi Makwana on 20/12/23.
//

import Foundation

struct HistoryResponse : Codable {
    let status : Bool?
    let data : [History]?

    enum CodingKeys: String, CodingKey {

        case status = "status"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Bool.self, forKey: .status)
        data = try values.decodeIfPresent([History].self, forKey: .data)
    }

}
struct History : Codable {
    let id : Int?
    let site_name : String?
    let charger_name : String?
    let amount : Double?
    let meter_diff : Double?
    let created_at : String?
    let status : String?
    let duration : String?
    let on_going_duration : String?
    let diffInSeconds : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case site_name = "site_name"
        case charger_name = "charger_name"
        case amount = "amount"
        case meter_diff = "meter_diff"
        case created_at = "created_at"
        case status = "status"
        case duration = "duration"
        case on_going_duration = "on_going_duration"
        case diffInSeconds = "diffInSeconds"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        site_name = try values.decodeIfPresent(String.self, forKey: .site_name)
        charger_name = try values.decodeIfPresent(String.self, forKey: .charger_name)
        amount = try values.decodeIfPresent(Double.self, forKey: .amount)
        meter_diff = try values.decodeIfPresent(Double.self, forKey: .meter_diff)
        created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        duration = try values.decodeIfPresent(String.self, forKey: .duration)
        on_going_duration = try values.decodeIfPresent(String.self, forKey: .on_going_duration)
        diffInSeconds = try values.decodeIfPresent(String.self, forKey: .diffInSeconds)
    }

}
