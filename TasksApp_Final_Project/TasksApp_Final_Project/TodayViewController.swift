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

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
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
           // todayTableView.reloadData()
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
                              
                            }
               })
              //  self.todayTableView.reloadData()
            }
            else{
            print("fail to access reminder")
            print("error \(String(describing: error))")
            }
    })
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
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if indexPath.section == 0{
        cell.textLabel!.text = eventList[indexPath.row].title
        }
        if indexPath.section == 1{
            cell.textLabel!.text = reminderList[indexPath.row].title
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
        
        setupNewsCollectionView()
        fetchDataForNewsCollectionView()
        
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
        todayTableView.reloadData()
    }

   //**********News**********//
    var newsData: NewsAPIResults? = nil
    var currentIndex = 0
    @IBOutlet weak var newsCollectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = newsCollectionView.dequeueReusableCell(withReuseIdentifier: "ncell", for: indexPath) as! NewsCollectionViewCell
        
        guard let results = newsData else {return cell}
        let story = results.articles[indexPath.row]
        cell.displayArticle(title: story.title, description: story.description)
        return cell
    }
    
    func setupNewsCollectionView() {
        newsCollectionView.dataSource = self
        newsCollectionView.delegate = self
        newsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    func fetchDataForNewsCollectionView() {
        guard let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=1bb0874ef4e84c82a8a341a27670b113") else {
            print("URL is nil")
            return
        }
        var tempData: NewsAPIResults? = nil
        guard let data = try? Data(contentsOf: url) else {return}
        tempData = try! JSONDecoder().decode(NewsAPIResults.self, from: data)
        newsData = tempData
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentIndex = Int((self.newsCollectionView.contentOffset.x) / self.newsCollectionView.frame.size.width)
    }
    
    @IBAction func goToArticle(_ sender: UITapGestureRecognizer) {
        guard let results = newsData else {return}
        if let url = results.articles[currentIndex].url {
            UIApplication.shared.open(url, options: [:])
        }
    }
    //*************************//
}
