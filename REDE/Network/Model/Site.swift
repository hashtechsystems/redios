//
//  Site.swift
//  REDE
//
//  Created by Avishek on 28/07/22.
//

import Foundation

struct SiteResponse: Codable {
    let status: Bool
    let data: [Site]
}

// MARK: - Datum
struct Site: Codable {
    let distance, id: Int
    let name, address, city, state: String
    let postalCode: String
    let status: Int
    let chargerStations: [ChargerStation]
    let latitude, longitude: String

    enum CodingKeys: String, CodingKey {
        case distance, id, name, address, city, state, latitude, longitude
        case postalCode = "postal_code"
        case status
        case chargerStations = "charger_stations"
    }
}

// MARK: - ChargerStation
struct ChargerStation: Codable {
    let id, siteID: Int
    let name: String
    let connectors: [Connector]

    enum CodingKeys: String, CodingKey {
        case id
        case siteID = "site_id"
        case name, connectors
    }
}

// MARK: - Connector
struct Connector: Codable {
    let id, chargingStationID, voltage: Int

    enum CodingKeys: String, CodingKey {
        case id
        case chargingStationID = "charging_station_id"
        case voltage
    }
}
