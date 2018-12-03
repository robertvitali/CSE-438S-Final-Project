//
//  Tasks+CoreDataProperties.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 12/2/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//
//

import Foundation
import CoreData


extension Tasks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tasks> {
        return NSFetchRequest<Tasks>(entityName: "Tasks")
    }

    @NSManaged public var name: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var notes: String?
    @NSManaged public var parent: Folders?

}
