//
//  Stations.swift
//  REDE
//
//  Created by Riddhi Makwana on 26/12/23.
//

import Foundation

struct StationsData {
    var StationName: String
    var status : String
    var ChargerData: [ChargerData]
}

struct ChargerData {
    var name: String
    var Output: String
}
