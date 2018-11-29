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
    var reminderList:[EKReminder] = []
    var headerList:[String] = ["Event","Reminder","Task"]
    var calendarArray:[EKCalendar] = []
    
    
    func fetchEvents(){
            eventList = []
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
         //  todayTableView.reloadData()
    }
    
    func fetchReminder(){
                reminderList = []
                let now = Date()
                let calendar = Calendar.current
                var dateComponents = DateComponents.init()
                dateComponents.day = 60
                let futureDate = calendar.date(byAdding: dateComponents, to: now)
                let reminderPredicate = self.eventStore.predicateForIncompleteReminders(withDueDateStarting: now, ending: futureDate!, calendars: nil)
                    self.eventStore.fetchReminders(matching: reminderPredicate, completion: {
                        (reminders: [EKReminder]?) -> Void in
                            for reminder in reminders! {
                            self.reminderList.append(reminder)
                            print("\(String(describing: reminder.title))")
                            }
               })
            //   self.todayTableView.reloadData()
    }
    
    func setupTableView(){
        todayTableView.dataSource = self
        todayTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerList[section]
    }
//     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = UIColor.lightGray
//        let label = UILabel()
//        label.text = "Header"
//        label.frame =  CGRect(x:45,y:5,width:100,height:35)
//        view.addSubview(label)
//        return view
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 45
//    }
//
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return eventList.count
        }
        if section == 1{
            return reminderList.count
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if indexPath.section == 0{
        cell.textLabel!.text = eventList[indexPath.row].title
            // eventList[indexPath.row].startDate.startHour
            cell.detailTextLabel?.text = "\(eventList[indexPath.row].startDate.time(date: eventList[indexPath.row].startDate)) -- \(eventList[indexPath.row].endDate.time(date: eventList[indexPath.row].endDate))"
            print("event show")
        }
       if indexPath.section == 1{
            cell.textLabel!.text = reminderList[indexPath.row].title
            print("reminder show")
          //  let shour = reminderList[indexPath.row].startDateComponents!.hour
          //  let smin = (reminderList[indexPath.row].startDateComponents!.minute)
          //  let ssec = (reminderList[indexPath.row].startDateComponents!.second)
          //  let dhour = (reminderList[indexPath.row].dueDateComponents!.hour)
          //  let dmin = (reminderList[indexPath.row].dueDateComponents!.minute)
          //  let dsec = (reminderList[indexPath.row].dueDateComponents!.second)
          //  cell.detailTextLabel?.text = "\(shour):\(smin):\(ssec)"
            //-- \(dhour):\(dmin):\(dsec)"
        }
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
        
        eventStore.requestAccess(to: .reminder, completion:{(granted,error) in
            if granted{
                    self.fetchReminder()
                    print("granted \(granted)")
                    }
            else{
                print("fail to access reminder")
                print("error \(String(describing: error))")
            }
        })
        // Do any additional setup after loading the view.
        fetchEvents()
        fetchReminder()
        setupTableView()
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        
        
        titleBar.title = "\(date.weekDay()) \(date.monthAsString()) \(day)\(date.dayEnding())"
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("enter viewDidAppear")
        fetchEvents()
        fetchReminder()
       self.todayTableView.reloadData()
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
