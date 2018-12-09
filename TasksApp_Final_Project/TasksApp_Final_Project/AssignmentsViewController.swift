//
//  AssignmentsViewController.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 11/26/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit
import CoreData

var nameClass:String?
var taskName:String?
var taskDate:Date?
var taskNotes:String?
var uniqueIDT: Int64?

class AssignmentsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var itemName: [NSManagedObject] = []
    var sortedItems: [NSManagedObject] = []
    var theIndex:Int = 0
    var showingCompleted:Bool = false
    var currentPos = 0
    
    
    
    var className: String!

    @IBOutlet var topTitle: UINavigationItem!
    @IBOutlet var assignmentTable: UITableView!
    @IBOutlet var addTask: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameClass = className
        topTitle.title = className
        assignmentTable.backgroundColor = Colors.headerBackground
        
        print("Assignments VC")
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData(){
        sortedItems = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tasks")
        
        do{
            itemName = try context.fetch(fetchRequest)
            var s:String = ""
            var tf:Bool = false
            print("GETTING TASKS")
            for item in itemName {
                s = (item.value(forKey: "folderName") as? String)!
                tf = (item.value(forKey: "complete") as? Bool)!
                print("\(s)")
                if(s == className && tf == showingCompleted){
                    sortedItems.append(item)
                }
            }
            print(sortedItems.count)
        }catch{
            print("ERROR")
        }
        assignmentTable.reloadData()
    }
    
    //these functions will create swipe capabilities in the cells
    //completion swipe
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = UIContextualAction(style: .destructive, title: "Check"){ (action, view, completion) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let title = self.sortedItems[indexPath.row]
            let uniqueString:Int64 = (title.value(forKey: "uniqueID") as? Int64)!
            let position:Int = self.getPosition(uniqueString: uniqueString)
            let objectUpdate = self.sortedItems[indexPath.row]
            var tf:Bool = (objectUpdate.value(forKey: "complete") as? Bool)!
            tf = !tf
            objectUpdate.setValue(tf, forKey: "complete")
            
            do{
                try context.save()
            }catch{
                print("ERROR")
            }
            //DELETE ROWS ISNT WORKING
            //self.taskTable.deleteRows(at: [indexPath], with: .automatic)
            self.getData()
            
            completion(true)
        }
        
        complete.image = UIImage(named: "checkmark")
        complete.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [complete])
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
    
    //delete and edit swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete"){ (action, view, completion) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let title = self.sortedItems[indexPath.row]
            let uniqueString:Int64 = (title.value(forKey: "uniqueID") as? Int64)!
            let position:Int = self.getPosition(uniqueString: uniqueString)
            context.delete(self.itemName[position])
            self.itemName.remove(at: position)
            self.sortedItems.remove(at: indexPath.row)
            print("TRYING TO DELETE")
            do{
                try context.save()
            }catch{
                print("ERROR")
            }
            self.getData()
            
            completion(true)
        }
        let edit = UIContextualAction(style: .normal, title: "Edit"){ (action, view, completion) in
                
            completion(true)
        }
        delete.image = UIImage(named: "trash1")
        delete.backgroundColor = .red
        edit.image = UIImage(named: "edit")
        edit.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = sortedItems[indexPath.row]
        let cell = assignmentTable.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath)
        cell.textLabel?.text = title.value(forKey: "name") as? String
        if(showingCompleted == true){
            cell.textLabel?.textColor = Colors.headerBackground
        }else{
            cell.textLabel?.textColor = .black
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = self.sortedItems[indexPath.row]
        let titleLabel = title.value(forKey: "name") as? String
        let messageLabel = title.value(forKey: "date") as? Date
        currentPos = indexPath.row
        let date = Date().dateToStringFormatted(date: messageLabel!)
        let messageLabel2 = title.value(forKey: "notes") as? String
        let stringTemp1 = messageLabel2 ?? ""
        
        
        let entireMessage = date + "\n" + stringTemp1
        let alert = UIAlertController(title: titleLabel, message: entireMessage, preferredStyle: .alert)
        let update = UIAlertAction(title: "Update", style: .default, handler: self.update)
        let complete = UIAlertAction(title: "Complete", style: .default, handler: self.complete)
        let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(update)
        alert.addAction(complete)
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }
    
    func update(alert:UIAlertAction){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "Add Task VC") as! AddTaskViewController
        let title = sortedItems[currentPos]
        taskName = title.value(forKey:"name") as? String
        taskDate = title.value(forKey:"date") as? Date
        taskNotes = title.value(forKey:"notes") as? String
        uniqueIDT = title.value(forKey:"uniqueID") as? Int64
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func complete(alert:UIAlertAction){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let title = self.sortedItems[currentPos]
        let uniqueString:Int64 = (title.value(forKey: "uniqueID") as? Int64)!
        let position:Int = self.getPosition(uniqueString: uniqueString)
        let objectUpdate = self.sortedItems[currentPos]
        var tf:Bool = (objectUpdate.value(forKey: "complete") as? Bool)!
        tf = !tf
        objectUpdate.setValue(tf, forKey: "complete")
        
        do{
            try context.save()
        }catch{
            print("ERROR")
        }
        //DELETE ROWS ISNT WORKING
        //self.taskTable.deleteRows(at: [indexPath], with: .automatic)
        self.getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getData()
    }
    @IBAction func toggleCompleted(_ sender: Any) {
        let alert = UIAlertController(title: "Toggle", message: "Would you like to toggle the completed/not completed events?", preferredStyle: .alert)
        let Yes = UIAlertAction(title: "Yes", style: .default, handler: self.yes)
        let No = UIAlertAction(title: "No", style: .default, handler: nil)
        alert.addAction(Yes)
        alert.addAction(No)
        self.present(alert, animated: true, completion: nil)
    }
    
    func yes(alert:UIAlertAction){
        showingCompleted = !showingCompleted
        getData()
    }
    
    
}
