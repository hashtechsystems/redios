//
//  Site.swift
//  REDE
//
//  Created by Avishek on 28/07/22.
//

import Foundation

struct SiteResponse: Codable {
    let status: Bool
    let data: [Site]?
    let message: String?
}

// MARK: - Datum
struct Site: Codable {
    let id: Int
    let name, address, city, state: String
    let postalCode: String?
    let status: Int
    let chargerStations: [ChargerStation]?
    let latitude, longitude: String
    let pricePlanIdDC: Int?
    let pricePlanIdAC: Int?
    let price_plan : Price_plan?
    let ac_price_plan : Price_plan?
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, city, state, latitude, longitude
        case postalCode = "postal_code"
        case status
        case chargerStations = "charger_stations"
        case pricePlanIdDC = "price_plan_id"
        case pricePlanIdAC = "ac_price_plan_id"
        case price_plan = "price_plan"
        case ac_price_plan = "ac_price_plan"

    }
    
    
    func getFullAdress() -> String {
        return "\(address), \(city), \(state) : \(postalCode ?? "")"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)!
        name = try values.decodeIfPresent(String.self, forKey: .name)!
        address = try values.decodeIfPresent(String.self, forKey: .address)!
        city = try values.decodeIfPresent(String.self, forKey: .city)!
        state = try values.decodeIfPresent(String.self, forKey: .state)!
        postalCode = try values.decodeIfPresent(String.self, forKey: .postalCode)
        status = try values.decodeIfPresent(Int.self, forKey: .status)!
        latitude = try values.decodeIfPresent(String.self, forKey: .latitude)!
        longitude = try values.decodeIfPresent(String.self, forKey: .longitude)!
        pricePlanIdDC = try values.decodeIfPresent(Int.self, forKey: .pricePlanIdDC)
        pricePlanIdAC = try values.decodeIfPresent(Int.self, forKey: .pricePlanIdAC)
        chargerStations = try values.decodeIfPresent([ChargerStation].self, forKey: .chargerStations)
        price_plan = try values.decodeIfPresent(Price_plan.self, forKey: .price_plan)
        ac_price_plan = try values.decodeIfPresent(Price_plan.self, forKey: .ac_price_plan)
    }
}

struct Price_plan : Codable {
    let id : Int?
    let name : String?
    let fixed_fee : Double?
    let variable_fee : Double?
    let auth_amount : Int?
    let fee_type : String?
    let parking_fee : Double?
    let parking_fee_unit : String?
    let buffer_time : Int?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case name = "name"
        case fixed_fee = "fixed_fee"
        case variable_fee = "variable_fee"
        case auth_amount = "auth_amount"
        case fee_type = "fee_type"
        case parking_fee = "parking_fee"
        case parking_fee_unit = "parking_fee_unit"
        case buffer_time = "buffer_time"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        print(try values.decodeIfPresent(Int.self, forKey: .id))
        name = try values.decodeIfPresent(String.self, forKey: .name)
        fixed_fee = try values.decodeIfPresent(Double.self, forKey: .fixed_fee)
        variable_fee = try values.decodeIfPresent(Double.self, forKey: .variable_fee)
        auth_amount = try values.decodeIfPresent(Int.self, forKey: .auth_amount)
        fee_type = try values.decodeIfPresent(String.self, forKey: .fee_type)
        parking_fee = try values.decodeIfPresent(Double.self, forKey: .parking_fee)
        parking_fee_unit = try values.decodeIfPresent(String.self, forKey: .parking_fee_unit)
        buffer_time = try values.decodeIfPresent(Int.self, forKey: .buffer_time)
    }

}

struct ChargerStationDetailsResponse: Codable {
    let status: Bool
    let data: ChargerStation?
    let message: String?
}

// MARK: - ChargerStation
struct ChargerStation: Codable {
    let id, siteID: Int
    let name: String
    let ocppCbid: String?
    let qrCode: String?
    let manufacturer_id: Int?
    let site: Site?
    let chargerType: String?
    var connectors: [Connector]
    var charger_output : String?
    enum CodingKeys: String, CodingKey {
        case id, manufacturer_id
        case siteID = "site_id"
        case ocppCbid = "ocpp_cbid"
        case qrCode = "qr_code"
        case name, connectors, site
        case chargerType = "charger_type"
        case charger_output = "charger_output"
    }
    
    var pricePlanId: Int? {
        if chargerType?.uppercased().elementsEqual("AC") ?? false {
            return site?.pricePlanIdAC
        } else if chargerType?.uppercased().elementsEqual("DC") ?? false {
            return site?.pricePlanIdDC
        }
        return nil
    }
}

// MARK: - Connector
struct Connector: Codable {
    let id, chargingStationID, voltage, sequence_number, connector_output: Int
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case chargingStationID = "charging_station_id"
        case voltage
        case type
        case sequence_number, connector_output
    }
}

// MARK: - Transaction
struct Transaction: Codable {
    let status: Bool?
    let message: String?
    let result: String?
    let transactionId: Int
}

// MARK: - PaymentResponse
struct PaymentResponse: Codable {
    let status: Bool
    let data: String?
    let ocppCbid: String?
    let authId: String?
    let transactionId: String?
    let message: String?
}

// MARK: - UpdatePaymentResponse
struct UpdatePaymentResponse: Codable {
    let status: Bool
    let data: String?
    let message: String?
}


// MARK: - Welcome
struct TransactionDetailsResponse: Codable {
    let status: Bool
    var data: TransactionDetails?
    let message: String?
    let amount: Double?
}

// MARK: - DataClass
struct TransactionDetails: Codable {
    let id, connectorID: Int?
    let averageVoltage: Double?
    let meterStart, meterEnd: Double?
    let status: String?
    let sequenceNumber: Int?
    let chargingStationName, siteName: String?
    let amount: Double?
    let ocppCbid: String?
    let finalAmount: Double?
    let createdAt, sessionStart, sessionEnd: String?
    let meterDiff: Double?
    var meterValue: String?
    var meterData: [MeterData]?
    let chargerType: String?
    let connectorStatus: String?
    let duration: String?
    let price_plan_details : String?
    let on_going_duration : String?
    
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
        case meterValue = "meter_data"
        case sessionStart = "session_start"
        case sessionEnd = "session_end"
        case meterDiff = "meter_diff"
        case chargerType = "charger_type"
        case connectorStatus = "connector_status"
        case duration = "duration"
        case on_going_duration = "on_going_duration"
        case price_plan_details = "price_plan_details"

    }
    
    mutating func parseMeterValues(){
        
        guard let data = meterValue?.data(using: .utf8) else {
            return
        }
        self.meterData = try? JSONDecoder().decode([MeterData].self, from: data)
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
