//
//  ViewController.swift
//  DateTitle
//
//  Created by Robert on 11/25/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var titleLabel: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let weekday = calendar.component(.weekday, from: Date())
        
        print(year)
        print(month)
        print(day)
        print(weekday)
        
        var weekdayString = ""
        
        if(weekday == 1){
            weekdayString = "Sunday"
        }else if(weekday == 2){
            weekdayString = "Monday"
        }else if(weekday == 3){
            weekdayString = "Tuesday"
        }else if(weekday == 4){
            weekdayString = "Wednesday"
        }else if(weekday == 5){
            weekdayString = "Thursday"
        }else if(weekday == 6){
            weekdayString = "Friday"
        }else if(weekday == 7){
            weekdayString = "Saturday"
        }
        
        titleLabel.title = "\(weekdayString), \(date.monthAsString()) \(day)/"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

