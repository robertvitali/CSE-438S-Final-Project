//
//  Expandable.swift
//  TasksApp_Final_Project
//
//  Created by Spencer Blackwood on 12/1/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import Foundation
import EventKit
import CoreData

struct ExpandableEvents {
    var isExpanded: Bool
    var events: [EKEvent]
}

struct ExpandableReminders {
    var isExpanded: Bool
    var reminders: [EKReminder]
}

struct ExpandableTasks{
    var isExpanded: Bool
    var tasks: [NSManagedObject]
}
