//
//  ForecastClient.swift
//  UtStateParks
//
//  Created by Kobe McKee on 8/17/19.
//  Copyright © 2019 Kobe McKee. All rights reserved.
//

import Foundation
import ForecastIO

class ForecastClient {
    
    let client = DarkSkyClient(apiKey: Config.forecastAPIKey)
    
}
