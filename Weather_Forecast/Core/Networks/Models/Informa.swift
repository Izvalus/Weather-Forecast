//
//  Informa.swift
//  Weather_Forecast
//
//  Created by Роман Мироненко on 22.10.2020.
//  Copyright © 2020 Роман Мироненко. All rights reserved.
//

import Foundation

// MARK: - Informa
struct Informa: Codable {
    let main: Main
    let name: String
}

extension Informa {
    struct Main: Codable {
        let temp: Float?
        let tempMin: Float
    }
}
