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

// MARK: - UpdatePaymentResponse
struct UpdatePaymentResponse: Codable {
    let status: Bool
    let data: String?
    
    enum CodingKeys: String, CodingKey {
        case status, data
    }
}


// MARK: - Welcome
struct TransactionDetailsResponse: Codable {
    let status: Bool
    var data: TransactionDetails
}

// MARK: - DataClass
struct TransactionDetails: Codable {
    let id, connectorID: Int?
    let averageVoltage: Double?
    let meterStart, meterEnd: Int?
    let status: String?
    let sequenceNumber: Int?
    let chargingStationName, siteName: String?
    let amount: Double?
    let ocppCbid: String?
    let finalAmount: Double?
    let createdAt, sessionStart, sessionEnd: String?
    let meterDiff: Int?
    var meterData: [MeterData]?

    enum CodingKeys: String, CodingKey {
        case id
        case connectorID = "connector_id"
        case averageVoltage = "average_voltage"
        case meterStart = "meter_start"
        case meterEnd = "meter_end"
        case status
        case sequenceNumber = "sequence_number"
        case chargingStationName = "charging_station_name"
        case siteName = "site_name"
        case amount
        case ocppCbid = "ocpp_cbid"
        case finalAmount = "final_amount"
        case createdAt = "created_at"
        case meterData = "meter_data"
        case sessionStart = "session_start"
        case sessionEnd = "session_end"
        case meterDiff = "meter_diff"
    }
}

struct MeterData: Codable {
    let timestamp: String?
    let sampledValue: [SampledValue]?
}

struct SampledValue: Codable {
    let unit, value, format: String?
    let location, measurand: String?
}
