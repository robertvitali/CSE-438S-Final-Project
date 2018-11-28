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
import CoreData

var list = ["Test 1", "Test 2", "Test 3", "Test 4" ]

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var taskTable: UITableView!
    @IBOutlet var navigationBar: UINavigationItem!
    
    //properties of core data
    //var resultsController: NSFetch
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationBar.title = "Lists"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = list[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete){
            list.remove(at: indexPath.row)
            taskTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "Assignments VC") as! AssignmentsViewController
        destination.className = list[indexPath.row]
        navigationController?.pushViewController(destination, animated: true)
    }
    
    //this function reloads the data when the scene is reloaded
    override func viewDidAppear(_ animated: Bool) {
        taskTable.reloadData()
    }
    
    //these functions will create swipe capabilities in the cells
    
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
    
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

