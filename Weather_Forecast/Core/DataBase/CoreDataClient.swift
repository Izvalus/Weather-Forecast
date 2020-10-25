//
//  CoreDataClient.swift
//  Weather_Forecast
//
//  Created by Роман Мироненко on 23.10.2020.
//  Copyright © 2020 Роман Мироненко. All rights reserved.
//

import Foundation
import CoreData

class CoreDataClient {
    
    static let shared = CoreDataClient()
    
    enum Error: Swift.Error{
        case fetchError(Swift.Error)
    }
    
    func get<Entity>(predicate: NSPredicate? = nil,
                     entityName: String) -> Result<[Entity], Error> where Entity: NSManagedObject {
        
        let fetchRequest = NSFetchRequest<Entity>(entityName: entityName)
        
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do {
            return .success(try persistentContainer.viewContext.fetch(fetchRequest) as [Entity])
        } catch {
            return Result.failure(Error.fetchError(error))
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
       
        let container = NSPersistentContainer(name: "Weather_Forecast")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
