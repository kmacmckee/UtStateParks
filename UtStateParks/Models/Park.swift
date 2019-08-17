//
//  Park.swift
//  UtStateParks
//
//  Created by Kobe McKee on 8/10/19.
//  Copyright © 2019 Kobe McKee. All rights reserved.
//

import Foundation

struct Data: Codable {
    var data: [Park]
}

struct Park: Codable {
    var states: String
    var latLong: String
    var parkCode: String
    var directionsInfo: String
    var fullName: String
    var url: String
    var weatherInfo: String
}
