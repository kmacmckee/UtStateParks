//
//  FetchForecastOp.swift
//  UtStateParks
//
//  Created by Kobe McKee on 8/24/19.
//  Copyright © 2019 Kobe McKee. All rights reserved.
//

import Foundation
import ForecastIO

class FetchForecastOp: ConcurrentOperation {
    
    private(set) var weatherIconString: String?
    private(set) var temperature: Int?
    
    let forecast: ForecastClient
    let lat: Double
    let long: Double
    
    init(lat: Double, long: Double, forecast: ForecastClient, session: URLSession = URLSession.shared) {
        self.lat = lat
        self.long = long
        self.forecast = forecast
        super.init()
    }

    
    override func start() {
        super.start()
        state = .isExecuting
        print("getForecast running")
        
        forecast.client.getForecast(latitude: lat, longitude: long, excludeFields: [Forecast.Field.alerts, Forecast.Field.daily, Forecast.Field.flags, Forecast.Field.hourly, Forecast.Field.minutely]) { (result) in
            defer { self.state = .isFinished }
            switch result {
            case .success(let currentForecast, _):
                
                self.weatherIconString = currentForecast.currently?.icon?.rawValue
                self.temperature = Int(currentForecast.currently?.apparentTemperature ?? 0)
                                
            case .failure(let error):
                
                NSLog("Error getting forecast: \(error)")
                return
            }
        }
    }
    
}
