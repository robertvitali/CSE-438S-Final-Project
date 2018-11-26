//
//  TodayViewController.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 11/15/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit
import EventKit
import FirebaseAuth

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var titleBar: UINavigationItem!
    @IBOutlet weak var todayTableView: UITableView!
    var eventStore:EKEventStore = EKEventStore.init()
    var eventList:[EKEvent] = []
    
    func fetchEvents(){
        let now = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents.init()
        dateComponents.day = 60
        let futureDate = calendar.date(byAdding: dateComponents, to: now)
        let eventsPredicate = self.eventStore.predicateForEvents(withStart: now, end: futureDate!, calendars: nil)
        let events = self.eventStore.events(matching: eventsPredicate)
        for event in events{
        eventList.append(event)
            print("\(String(describing: event.title))")
        }
            todayTableView.reloadData()
    }
    
    func setupTableView(){
        todayTableView.dataSource = self
        todayTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel!.text = eventList[indexPath.row].title
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventStore.requestAccess(to: .event, completion: {(granted,error) in
        if granted{
        print("granted \(granted)")
        self.fetchEvents()
        }
        else{
        print("fail to access calendar")
        print("error \(String(describing: error))")
        }
        })
        // Do any additional setup after loading the view.
        setupTableView()
        
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let weekday = calendar.component(.weekday, from: Date())
        
        print(year)
        print(month)
        print(day)
        
        
        
        //titleBar.title = "\(month)/\(day)/\(year)"
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
