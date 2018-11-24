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

class TasksViewController: UIViewController, UITableViewDataSource {
   
    var eventStore:EKEventStore!
    @IBOutlet weak var taskTable: UITableView!
    
    var events:[EKEvent] = []

    func fetchEvents(){
        let now = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents.init()
        dateComponents.day = 60
        let futureDate = calendar.date(byAdding: dateComponents, to: now)
        let eventsPredicate = self.eventStore.predicateForEvents(withStart: now, end: futureDate!, calendars: nil)
        let events = self.eventStore.events(matching: eventsPredicate)
        
        for event in events{
            print("\(event.title)")
        }
    }
   
    func setupTableView(){
        taskTable.dataSource = self
        taskTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel!.text = events[indexPath.row].title
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        eventStore.requestAccess(to: .event, completion: {(granted,error) in
            if granted{
                print("granted \(granted)")
            }
            else{
                print("error \(String(describing: error))")
            }
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        setupTableView()
        fetchEvents()
        
        
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
