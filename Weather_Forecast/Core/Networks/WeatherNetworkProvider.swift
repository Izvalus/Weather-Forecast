//
//  WeatherNetworkProvider.swift
//  Weather_Forecast
//
//  Created by Роман Мироненко on 22.10.2020.
//  Copyright © 2020 Роман Мироненко. All rights reserved.
//

import Foundation

final class WeatherNetworkProvider {
    let networkClient = NetworkClient()
    
    func currentWeather(respons: @escaping ((Result<Informa, NetworkClient.Error>) -> Void)) {
        
        networkClient.request(
            client: .openWeatherMap,
            endpoint: "weather",
            params: ["q": "Moscow", "units": "metric"],
            respons: respons
        )
    }
    
    func weatherForcast(
        count: Int,
        response: @escaping ((Result<HistoryWeatherForcast, NetworkClient.Error>) -> Void)
    ) {
        networkClient.request(
            client: .rapidAPI,
            endpoint: "daily",
            params: ["q": "moscow", "cnt": count, "units": "metric"],
            respons: response
        )
    }
}
