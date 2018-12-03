//
//  AssignmentsViewController.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 11/26/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit
import CoreData



class AssignmentsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var itemName: [NSManagedObject] = []
    var theIndex:Int = 0
    
    
    
    var className: String!

    @IBOutlet var topTitle: UINavigationItem!
    @IBOutlet var assignmentTable: UITableView!
    @IBOutlet var addTask: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Assignments VC")
        topTitle.title = className
        
        
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
    
    //delete and edit swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete"){ (action, view, completion) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
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
            self.assignmentTable.reloadData()
            
            completion(true)
        }
        let edit = UIContextualAction(style: .destructive, title: "Edit"){ (action, view, completion) in

            completion(true)
        }
        delete.image = UIImage(named: "trash1")
        delete.backgroundColor = .red
        edit.image = UIImage(named: "edit")
        edit.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = itemName[indexPath.row]
        let cell = assignmentTable.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath)
        cell.textLabel?.text = title.value(forKey: "name") as? String
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tasks")
        
        do{
            itemName = try context.fetch(fetchRequest)
        }catch{
            print("ERROR")
        }
    }
}
