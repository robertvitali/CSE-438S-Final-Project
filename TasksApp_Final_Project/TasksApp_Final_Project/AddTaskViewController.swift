//
//  AddTaskViewController.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 11/26/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit
import CoreData


class AddTaskViewController: UIViewController {
    
    @IBOutlet var taskNameField: UITextField!
    @IBOutlet var taskDateField: UITextField!
    @IBOutlet var notesBox: UITextView!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var taskButton: UIButton!
    @IBOutlet var taskLabel: UILabel!
    
    private var datePicker = UIDatePicker()
    
    var itemName: [NSManagedObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(taskName != "" && taskName != nil){
            //set title to edit
            taskNameField.text = taskName
            taskDateField.text = Date().dateToStringFormatted(date: taskDate!)
            notesBox.text = taskNotes
            taskName = ""
            taskDate = nil
            taskNotes = ""
            taskButton.setTitle("Save Task", for: .normal)
            taskLabel.text = "Edit Task"
        }else{
            taskButton.setTitle("Create Task", for: .normal)
            taskLabel.text = "Create New Task"
            taskDateField.text = Date().dateToStringFormatted(date: Date())
        }
        
        
        
        notesBox!.layer.borderWidth = 0.5
        notesBox!.layer.cornerRadius = 10
        notesBox!.layer.borderColor = UIColor.lightGray.cgColor
        
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(AddTaskViewController.dateChanged(datePicker:)), for: .valueChanged)
        taskDateField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(AddTaskViewController.viewTapped(gestureRecognizer:)))
        toolbar.setItems([doneButton], animated: true)
        taskDateField.inputAccessoryView = toolbar
        
        
        
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
            let date = Date().stringToDateFormatted(str: taskDateField.text!)
            if(taskLabel.text == "Create New Task"){
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: context)!
                let theTitle = NSManagedObject(entity: entity, insertInto: context)
                theTitle.setValue(taskNameField.text, forKey: "name")
                theTitle.setValue(date, forKey: "date")
                theTitle.setValue(notesBox.text, forKey: "notes")
                theTitle.setValue(nameClass!, forKey: "folderName")
                theTitle.setValue(false, forKey: "complete")
                let number = Int.random(in: 0 ... 1000000000000)
                theTitle.setValue(number, forKey: "uniqueID")
                
                
                do{
                    try context.save()
                }catch{
                    print("CANNOT SAVE! ERROR!")
                }
                
            }else{
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tasks")
                
                do{
                    itemName = try context.fetch(fetchRequest)
                }catch{
                    print("error")
                }
                
                let position:Int = self.getPosition(uniqueString: uniqueIDT!)
                let objectUpdate = self.itemName[position]
                objectUpdate.setValue(taskNameField.text, forKey: "name")
                objectUpdate.setValue(date, forKey: "date")
                objectUpdate.setValue(notesBox.text, forKey: "notes")
                
                do{
                    try context.save()
                }catch{
                    print("ERROR")
                }
            }
            taskNameField.text = ""
            taskDateField.text = ""
            notesBox.text = ""
            navigationController?.popViewController(animated: true)
        }
    }
    
    func getPosition(uniqueString: Int64) -> Int{
        var count = 0
        for item in itemName{
            let uid = item.value(forKey: "uniqueID") as? Int64
            if(uid == uniqueString){
                return count
            }
            count = count + 1
        }
        return 0
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        taskDateField.text = Date().dateToStringFormatted(date: datePicker.date)
    }
   

}
