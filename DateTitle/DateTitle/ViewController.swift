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
        let day = calendar.component(.day, from: date)
        
        
        titleLabel.title = "\(date.weekDay()) \(date.monthAsString()) \(day)\(date.dayEnding())"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

