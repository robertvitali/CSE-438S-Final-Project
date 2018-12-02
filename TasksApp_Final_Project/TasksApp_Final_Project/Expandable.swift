//
//  Expandable.swift
//  TasksApp_Final_Project
//
//  Created by Spencer Blackwood on 12/1/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import Foundation
import EventKit

struct ExpandableEvent {
    var isExpanded: Bool
    let events: [EKEvent]
}

struct ExpandableReminder {
    var isExpanded: Bool
    let reminders: [EKReminder]
}
