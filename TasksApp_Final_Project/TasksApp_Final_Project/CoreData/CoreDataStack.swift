//
//  CoreDataStack.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 11/27/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack{
    var container:NSPersistentContainer{
        let container = NSPersistentContainer(name: "Tasks")
        container.loadPersistentStores{ (description, error) in
            guard error == nil else{
                print("Error: \(error!)")
                return
            }
        }
        return container
    }
    
    var managedContext: NSManagedObjectContext{
        return container.viewContext
    }
}
