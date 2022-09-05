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
    let id: Int
    let name, address, city, state: String
    let postalCode: String
    let status: Int
    let chargerStations: [ChargerStation]?
    let latitude, longitude: String
    let pricePlanId: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, address, city, state, latitude, longitude
        case postalCode = "postal_code"
        case status
        case chargerStations = "charger_stations"
        case pricePlanId = "price_plan_id"
    }
    
    func getFullAdress() -> String {
        return "\(address), \(city), \(state) : \(postalCode)"
    }
}


struct ChargerStationDetailsResponse: Codable {
    let status: Bool
    let data: ChargerStation
}

// MARK: - ChargerStation
struct ChargerStation: Codable {
    let id, siteID: Int
    let name: String
    let ocppCbid: String?
    let qrCode: String?
    let site: Site?
    var connectors: [Connector]

    enum CodingKeys: String, CodingKey {
        case id
        case siteID = "site_id"
        case ocppCbid = "ocpp_cbid"
        case qrCode = "qr_code"
        case name, connectors, site
    }
}

// MARK: - Connector
struct Connector: Codable {
    let id, chargingStationID, voltage: Int
    let type: String

    enum CodingKeys: String, CodingKey {
        case id
        case chargingStationID = "charging_station_id"
        case voltage
        case type
    }
}

// MARK: - Transaction
struct Transaction: Codable {
    let transactionId: Int

    enum CodingKeys: String, CodingKey {
        case transactionId
    }
}

// MARK: - PaymentResponse
struct PaymentResponse: Codable {
    let status: Bool
    let data: String?
    let ocppCbid: String?
    let authId: String?
    let transactionId: String?

    enum CodingKeys: String, CodingKey {
        case status, data, ocppCbid
        case authId, transactionId
    }
}

