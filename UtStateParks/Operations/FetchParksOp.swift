//
//  FetchParksOp.swift
//  UtStateParks
//
//  Created by Kobe McKee on 8/24/19.
//  Copyright © 2019 Kobe McKee. All rights reserved.
//

import Foundation

class FetchParksOp: ConcurrentOperation {
    
    private(set) var parks: [Park]?
    private var dataTask: URLSessionDataTask?
    private var session: URLSession
    
    
    let requestURL: URL
    
    
    init(requestURL: URL, session: URLSession = URLSession.shared) {
        self.requestURL = requestURL
        self.session = session
        super.init()
    }
    
    override func start() {
        super.start()
        state = .isExecuting
        
        let url = requestURL.usingHTTPS!
        let task = session.dataTask(with: url) { (data, repsonse, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            
            if let error = error {
                NSLog("Error fetching parks: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned when fetching parks")
                return
            }
            
            var utParks: [Park] = []
            do {
                let allParks = try JSONDecoder().decode(Data.self, from: data)
                
                for park in allParks.data {
                    if park.states == "UT" {
                        utParks.append(park)
                    }
                }
                self.parks = utParks

            } catch {
                NSLog("Error decoding parks: \(error)")
                return
            }
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        super.cancel()
        dataTask?.cancel()
    }
     
}
