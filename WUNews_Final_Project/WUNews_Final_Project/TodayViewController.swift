//
//  TodayViewController.swift
//  WUNews_Final_Project
//
//  Created by Robert on 11/25/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let weekday = Calendar.current.component(.weekday, from: Date())
        print(weekday)
        print("WEEKDAY")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
