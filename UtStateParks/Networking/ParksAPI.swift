//
//  ParksAPI.swift
//  UtStateParks
//
//  Created by Kobe McKee on 8/10/19.
//  Copyright © 2019 Kobe McKee. All rights reserved.
//

import Foundation

class ParksAPI {
    
    private let parksBaseURL = "https://developer.nps.gov/api/v1/parks"
    private let parksAPIKey = "oEB2w0Kdr1T85hF5FIeNIYgXdl11M023Q7pjkXGS"
    
    private let trailsBaseURL = URL(string: "https://www.hikingproject.com/data/get-trails")!
    private let trailsAPIKey = "200554629-1d6c855aff169c41e8ea471dd91a0c9f"
    
    
    var utParks: [Park] = []
    
    
    func getParks(completion: @escaping ([Park]?, Error?) -> Void) {
        
        var components = URLComponents(string: parksBaseURL)!
        components.queryItems = [
            URLQueryItem(name: "stateCode", value: "Ut"),
            URLQueryItem(name: "api_key", value: parksAPIKey)
        ]
        let requestURL = components.url!
        
        
        print(requestURL)
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching parks: \(error)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned when fetching parks")
                completion(nil, NSError())
                return
            }
            
            do {
                let allParks = try JSONDecoder().decode(Data.self, from: data)
                
                
                for park in allParks.data {
                    if park.states == "UT" {
                        self.utParks.append(park)
                    }
                }
                
                completion(self.utParks, nil)
                return
                
            } catch {
                NSLog("Error decoding parks: \(error)")
                completion(nil, error)
                return
            }
            
        }
        dataTask.resume()
        
    }
    
    
    
    func getTrails(lat: String, long: String) {
        
        
        
        
    }
    
    
}
