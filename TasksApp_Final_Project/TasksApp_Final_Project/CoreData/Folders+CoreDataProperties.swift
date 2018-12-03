//
//  Folders+CoreDataProperties.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 12/2/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//
//

import Foundation
import CoreData


extension Folders {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folders> {
        return NSFetchRequest<Folders>(entityName: "Folders")
    }

    @NSManaged public var name: String?
    @NSManaged public var assignments: NSSet?

}

// MARK: Generated accessors for assignments
extension Folders {

    @objc(addAssignmentsObject:)
    @NSManaged public func addToAssignments(_ value: Tasks)

    @objc(removeAssignmentsObject:)
    @NSManaged public func removeFromAssignments(_ value: Tasks)

    @objc(addAssignments:)
    @NSManaged public func addToAssignments(_ values: NSSet)

    @objc(removeAssignments:)
    @NSManaged public func removeFromAssignments(_ values: NSSet)

}
