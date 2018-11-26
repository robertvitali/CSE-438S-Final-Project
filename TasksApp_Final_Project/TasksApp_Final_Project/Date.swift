//
//  Date.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 11/25/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import Foundation

extension Date {
    func monthAsString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMMM")
        return df.string(from: self)
    }
    
    func dayEnding() -> String{
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        var returnString = "th"
        
        if(day == 1 || day == 21 || day == 31){
            returnString = "st"
        }else if(day == 2 || day == 22){
            returnString = "nd"
        }else if(day == 3 || day == 23){
            returnString = "rd"
        }
        return returnString
    }
    
    func weekDay() -> String{
        let calendar = Calendar.current
        
        let weekday = calendar.component(.weekday, from: Date())
        
        if(weekday == 1){
            return "Sunday"
        }else if(weekday == 2){
            return "Monday"
        }else if(weekday == 3){
            return "Tuesday"
        }else if(weekday == 4){
            return "Wednesday"
        }else if(weekday == 5){
            return "Thursday"
        }else if(weekday == 6){
            return "Friday"
        }else{
            return "Saturday"
        }
        
    }
}
