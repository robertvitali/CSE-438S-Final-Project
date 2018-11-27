//
//  AddTaskViewController.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 11/26/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {
    @IBOutlet var taskNameField: UITextField!
    @IBOutlet var taskDateField: UITextField!
    
    private var datePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(AddTaskViewController.dateChanged(datePicker:)), for: .valueChanged)
        taskDateField.inputView = datePicker
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createTaskClicked(_ sender: Any) {
        if(taskNameField.text != "" && taskDateField.text != ""){
            
        }
    }
    
    
    @objc func dateChanged(datePicker: UIDatePicker){
        
    }
   

}
