//
//  AssignmentsViewController.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 11/26/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit

class AssignmentsViewController: UIViewController {
    
    var className: String!

    @IBOutlet var topTitle: UINavigationItem!
    @IBOutlet var assignmentTable: UITableView!
    @IBOutlet var addTask: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTitle.title = className
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //these functions will create swipe capabilities in the cells
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = UIContextualAction(style: .destructive, title: "Check"){ (action, view, completion) in
            //todo
            completion(true)
        }
        
        complete.image = UIImage(named: "checkmark")
        complete.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [complete])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete"){ (action, view, completion) in
            //todo
            
            completion(true)
        }
        let edit = UIContextualAction(style: .destructive, title: "Edit"){ (action, view, completion) in
            //todo
            completion(true)
        }
        delete.image = UIImage(named: "trash1")
        delete.backgroundColor = .red
        edit.image = UIImage(named: "edit")
        edit.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [delete, edit])
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
