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
    
    func time(date: Date) -> String{
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
       // let second = calendar.component(.second, from: date)
        if(hour < 12){
            if(hour<10){
                if(minute<10){
                    return "0\(hour):0\(minute) AM"
                }
                else{
                    return "0\(hour):\(minute) AM"
                }
            }
            else{
            if(minute<10){
                return "\(hour):0\(minute) AM"
            }
        return "\(hour):\(minute) AM"
        }
    }
        else{
            if(hour-12<10){
                    if(minute<10){
                        return "0\(hour-12):0\(minute) PM"
                    }
                    else{
                        return "0\(hour-12):\(minute) PM"
                    }
            }
            else{
                if(minute<10){
                    return "\(hour-12):0\(minute) PM"
                }
                else{
                    return "\(hour-12):\(minute) PM"
                }
            }
}
    }
}

