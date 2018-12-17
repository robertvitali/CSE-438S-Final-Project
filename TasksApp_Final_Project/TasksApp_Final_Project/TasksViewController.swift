//
//  TasksViewController.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 11/15/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//
import Foundation
import UIKit
import EventKit
import Firebase
import CoreData


class TasksViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    
    //    let database = Database.database().reference()
    //    let userID = Auth.auth().currentUser?.uid
    
    var itemName: [NSManagedObject] = []
    var taskData: [NSManagedObject] = []
    var theIndex:Int = 0
    
    @IBOutlet var taskTable: UITableView!
    @IBOutlet var navigationBar: UINavigationItem!
    @IBOutlet var addButton: UIBarButtonItem!
    
    
    
    //properties of core data
    //var resultsController: NSFetch
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationBar.title = "Tasks"
        navigationController?.navigationBar.barTintColor = Colors.headerBackground
        navigationBar.largeTitleDisplayMode = .always
        addButton.tintColor = UIColor.black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = itemName[indexPath.row]
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "folderCell")
        let titleLabel = title.value(forKey: "name") as? String
        let count: Int = getNumberOfTasks(Name: titleLabel!)
        cell.textLabel?.text = titleLabel
        cell.detailTextLabel?.text = "\(count)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "Assignments VC") as! AssignmentsViewController
        let title = itemName[indexPath.row]
        destination.className = title.value(forKey:"name") as? String
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func getNumberOfTasks(Name: String) -> Int{
        taskData = []
        let appDelegate2 = UIApplication.shared.delegate as! AppDelegate
        let context2 = appDelegate2.persistentContainer.viewContext
        let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Tasks")
        var count = 0
        do{
            taskData = try context2.fetch(fetchRequest2)
            var s:String = ""
            var tf:Bool = false
            if taskData.count != 0{
                for item in taskData {
                    s = (item.value(forKey: "folderName") as? String)!
                    tf = (item.value(forKey: "complete") as? Bool)!
                    if(s == Name && tf == false){
                        count = count + 1
                    }
                }
                
            }
        }catch{
            print("ERROR")
        }
        return count
    }
    
    
    //this function reloads the data when the scene is reloaded
    override func viewDidAppear(_ animated: Bool) {
        taskTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Folders")
        
        do{
            itemName = try context.fetch(fetchRequest)
        }catch{
            print("ERROR")
        }
    }
    
    func deleteTasks(){
        taskData = []
        let appDelegate2 = UIApplication.shared.delegate as! AppDelegate
        let context2 = appDelegate2.persistentContainer.viewContext
        let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Tasks")
        
        do{
            taskData = try context2.fetch(fetchRequest2)
            var s:String = ""
            print("GETTING TASKS")
            if taskData.count != 0{
                print("COUNT IS NOT ZERO")
                for (index, item) in taskData.enumerated() {
                    s = (item.value(forKey: "folderName") as? String)!
                    print("\(s)")
                    if(s == nameClass){
                        context2.delete(item)
                    }
                }
                try context2.save()
            }
        }catch{
            print("ERROR")
        }
    }
    
    //archive
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = UIContextualAction(style: .destructive, title: "Check"){ (action, view, completion) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let objectUpdate = self.itemName[indexPath.row]
            var tf:Bool = (objectUpdate.value(forKey: "archive") as? Bool)!
            tf = !tf
            objectUpdate.setValue(tf, forKey: "archive")
            
            do{
                try context.save()
            }catch{
                print("ERROR")
            }
            completion(true)
        }
        
        
        
        complete.image = UIImage(named: "archive")
        if(true){
            complete.backgroundColor = .lightGray
        }else{
            complete.backgroundColor = .green
        }
        return UISwipeActionsConfiguration(actions: [complete])
    }
    
    
    
    //delete and edit swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete"){ (action, view, completion) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            nameClass = self.itemName[indexPath.row].value(forKey:"name") as? String
            self.deleteTasks()
            context.delete(self.itemName[indexPath.row])
            self.itemName.remove(at: indexPath.row)
            
            print("TRYING TO DELETE")
            do{
                try context.save()
            }catch{
                print("ERROR")
            }
            //DELETE ROWS ISNT WORKING
            //self.taskTable.deleteRows(at: [indexPath], with: .automatic)
            self.taskTable.reloadData()
            completion(true)
        }
        let edit = UIContextualAction(style: .normal, title: "Edit"){ (action, view, completion) in
            let alert = UIAlertController(title: "Update Name", message: "Update Name of Folder", preferredStyle: .alert)
            let update = UIAlertAction(title: "Update", style: .default, handler: self.update)
            alert.addAction(update)
            alert.addTextField(configurationHandler: self.titleTextField)
            self.present(alert, animated: true, completion: nil)
            let title = self.itemName[indexPath.row]
            self.titleTextField.text = title.value(forKey:"name") as? String
            self.theIndex = indexPath.row
            completion(true)
        }
        delete.image = UIImage(named: "trash1")
        delete.backgroundColor = .red
        edit.image = UIImage(named: "edit")
        edit.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    var titleTextField: UITextField!
    
    func titleTextField(textField: UITextField!){
        titleTextField = textField
        titleTextField.placeholder = "Name"
    }
    
    @IBAction func addButton(_ sender: Any) {
        let alert = UIAlertController(title: "Add Folder", message: "Name Your Folder", preferredStyle: .alert)
        let save = UIAlertAction(title: "Save", style: .default, handler: self.save)
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil )
        alert.addAction(cancel)
        alert.addAction(save)
        alert.addTextField(configurationHandler: titleTextField)
        self.present(alert, animated: true, completion: nil)
    }
    
    func save(alert: UIAlertAction!){
        if(titleTextField.text != ""){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Folders", in: context)!
            let theTitle = NSManagedObject(entity: entity, insertInto: context)
            theTitle.setValue(titleTextField.text, forKey: "name")
            theTitle.setValue(false, forKey: "archive")
            do{
                try context.save()
                itemName.append(theTitle)
                
            }catch{
                print("ERROR")
            }
            self.taskTable.reloadData()
        }
        
    }
    
    
    func update(alert:UIAlertAction){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Folders")
        do{
            let test = try context.fetch(fetchRequest)
            let objectUpdate = test[theIndex] 
            objectUpdate.setValue(titleTextField.text, forKey: "name")
            try context.save()
        }catch{
            print("ERROR")
        }
        self.taskTable.reloadData()
    }
    
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */

