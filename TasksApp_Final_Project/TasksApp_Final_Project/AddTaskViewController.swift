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
    @IBOutlet var notesBox: UITextView!
    
    private var datePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        notesBox!.layer.borderWidth = 0.5
        notesBox!.layer.cornerRadius = 10
        notesBox!.layer.borderColor = UIColor.lightGray.cgColor
        
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(AddTaskViewController.dateChanged(datePicker:)), for: .valueChanged)
        taskDateField.inputView = datePicker
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddTaskViewController.viewTapped(gestureRecognizer: )))
        
        
        view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true )
    }
    
    @IBAction func createTaskClicked(_ sender: Any) {
        if(taskNameField.text != "" && taskDateField.text != ""){
            taskNameField.text = ""
            taskDateField.text = ""
            notesBox.text = ""
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        taskDateField.text = dateFormatter.string(from: datePicker.date)
        //view.endEditing(true)
        
    }
   

}
