//
//  WeatherCoreDataProvider.swift
//  Weather_Forecast
//
//  Created by Роман Мироненко on 23.10.2020.
//  Copyright © 2020 Роман Мироненко. All rights reserved.
//

import Foundation

class WeatherCoreDataProvider {
    
    private let encoder = JSONEncoder()
    
    private let coreDataClient = CoreDataClient.shared
    
    func get() -> Result<[WeatherEntity], CoreDataClient.Error> {
       return coreDataClient.get(entityName: "Weather")
    }
    
    func getForcast() -> Result<[Forcast], CoreDataClient.Error> {
        return coreDataClient.get(entityName: "Forcast")
    }
    
    func save(informa: Informa) {
        let entity = WeatherEntity(context: coreDataClient.persistentContainer.viewContext)
        entity.create = Date()
        
       guard let encoded = try? encoder.encode(informa) else { return }
        entity.data = encoded
       try? coreDataClient.persistentContainer.viewContext.save()
    }
    
    func save(history: HistoryWeatherForcast) {
        let entity = Forcast(context: coreDataClient.persistentContainer.viewContext)
        entity.create = Date()
        
        guard let encoded = try? encoder.encode(history) else { return }
        entity.data = encoded
        try? coreDataClient.persistentContainer.viewContext.save()
    }
}
