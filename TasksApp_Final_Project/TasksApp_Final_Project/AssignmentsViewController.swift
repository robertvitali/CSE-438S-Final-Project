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

class AssignmentsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var itemName: [NSManagedObject] = []
    var sortedItems: [NSManagedObject] = []
    var theIndex:Int = 0
    
    
    
    var className: String!

    @IBOutlet var topTitle: UINavigationItem!
    @IBOutlet var assignmentTable: UITableView!
    @IBOutlet var addTask: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameClass = className
        topTitle.title = className
        
        print("Assignments VC")
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //these functions will create swipe capabilities in the cells
    //completion swipe
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = UIContextualAction(style: .destructive, title: "Check"){ (action, view, completion) in
            //todo
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
            //DELETE ROWS ISNT WORKING
            //self.taskTable.deleteRows(at: [indexPath], with: .automatic)
            self.assignmentTable.reloadData()
            
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = self.sortedItems[indexPath.row]
        let titleLabel = title.value(forKey: "name") as? String
        let messageLabel = title.value(forKey: "date") as? Date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let date = dateFormatter.string(from: messageLabel!)
        
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
        
    }
    
    func complete(alert:UIAlertAction){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sortedItems = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tasks")

        do{
            itemName = try context.fetch(fetchRequest)
            var s:String = ""
            print("GETTING TASKS")
            for item in itemName {
                s = (item.value(forKey: "folderName") as? String)!
                print("\(s)")
                if(s == className){
                    sortedItems.append(item)
                }
            }
            print(sortedItems.count)
        }catch{
            print("ERROR")
        }
        assignmentTable.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sortedItems = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tasks")
        
        do{
            itemName = try context.fetch(fetchRequest)
            var s:String = ""
            print("GETTING TASKS")
            for item in itemName {
                s = (item.value(forKey: "folderName") as? String)!
                print("\(s)")
                if(s == className){
                    sortedItems.append(item)
                }
            }
            print(sortedItems.count)
        }catch{
            print("ERROR")
        }
        assignmentTable.reloadData()
    }
}
