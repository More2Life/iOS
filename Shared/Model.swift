//
//  Model.swift
//  More2Life
//
//  Created by Porter Hoskins on 7/29/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import CoreData

class Model {
    
}

let persistentContainer: NSPersistentContainer = {
    guard let modelURL = Bundle(for: Model.self).url(forResource: "Model", withExtension:"momd") else {
        fatalError("Error loading model from bundle")
    }
    
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
        fatalError("Error initializing mom from: \(modelURL)")
    }
    
    let container = NSPersistentContainer(name: "Model", managedObjectModel: mom)
    container.loadPersistentStores { description, error in
        if let error = error as NSError? {
            fatalError("Unresolved error creating store \(description) \(error), \(error.userInfo)")
        }
        
        if let url = description.url {
            print("URL for CoreData \(url.path)")
        }
    }
    return container
}()

public let viewContext = persistentContainer.viewContext
public var backgroundContext: NSManagedObjectContext {
    return persistentContainer.newBackgroundContext()
}

public extension NSManagedObjectContext {
    func persist() {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            let nserror = error as NSError
            assert(false, "Unresolved database error \(error), \(nserror.userInfo)")
        }
    }
}
