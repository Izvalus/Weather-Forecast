//
//  HistoryWeatherForcast.swift
//  Weather_Forecast
//
//  Created by Роман Мироненко on 22.10.2020.
//  Copyright © 2020 Роман Мироненко. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct HistoryWeatherForcast: Codable {
    let city: City
    let list: [List]
}


extension HistoryWeatherForcast {
    
    // MARK: - City
    struct City: Codable {
        let name: String
    }
    
    
    // MARK: - List
    struct List: Codable {
        let dt: Int
        let temp: Temp
    }

    // MARK: - Temp
    struct Temp: Codable {
        let day, min, max, night: Double
        let eve, morn: Double
    }

}

