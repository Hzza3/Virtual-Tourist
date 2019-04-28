//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Epic Systems on 4/26/19.
//  Copyright © 2019 AhmedHazzaa. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    static func shared() -> DataController {
        struct Singleton {
            static var shared = DataController(modelName: "Virtual_Tourist")
        }
        return Singleton.shared
    }
    
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    
}
