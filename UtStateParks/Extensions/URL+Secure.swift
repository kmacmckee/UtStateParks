//
//  URL+Secure.swift
//  UtStateParks
//
//  Created by Kobe McKee on 8/24/19.
//  Copyright © 2019 Kobe McKee. All rights reserved.
//

import Foundation

extension URL {
    var usingHTTPS: URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
        components.scheme = "https"
        return components.url
    }
}
