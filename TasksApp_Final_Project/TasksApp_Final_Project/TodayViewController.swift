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
import ForecastIO
import CoreLocation

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var titleBar: UINavigationItem!
    @IBOutlet weak var todayTableView: UITableView!
    var eventStore:EKEventStore = EKEventStore.init()
    var eventList: ExpandableEvents? = nil
    var reminderList: ExpandableReminders? = nil
    var headerList:[String] = ["Event","Reminder"]
    var calendarArray:[EKCalendar] = []
    
    //***********WEATHER************
    
    let client = DarkSkyClient(apiKey: "fba905c888a58959fec530185e206514")
    var myLat:Double = 42.3601
    var myLon:Double = -71.0589
    var iconView:SKYIconView = SKYIconView()
    let manager = CLLocationManager()
    let weatherTypes: [Skycons] =
        [
            .clearDay,
            .clearNight,
            .cloudy,
            .fog,
            .partlyCloudyDay,
            .partlyCloudyNight,
            .rain,
            .sleet,
            .snow,
            .wind
    ]
    var displayUnits: String = "F"
    
    var xPadding: CGFloat = 30
    var yPadding: CGFloat = 30
    var summaryText:String = ""
    var tempText:String = ""
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var weatherIconView: UIView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        myLat = location.coordinate.latitude
        myLon = location.coordinate.longitude
    }
    
    func getData() {
        spinner.isHidden = false
        spinner.startAnimating()
        self.client.getForecast(latitude: self.myLat, longitude: self.myLon) { result in
            switch result {
            case .success(let currentForecast, let requestMetadata):
                self.spinner.isHidden = true
                self.summaryText = (currentForecast.currently?.summary)!
                self.tempText = "\(String((currentForecast.currently?.temperature)!))º \(self.displayUnits)"
                self.summaryLabel.font.withSize(20)
                self.tempLabel.font.withSize(12)
                self.summaryLabel.textColor = .gray
                print((currentForecast.currently?.summary)!)
                self.summaryLabel.text = self.summaryText
                self.tempLabel.text = self.tempText
            //icons
                if ((currentForecast.currently?.icon)!.rawValue == "clear-day") {
                    self.iconView.setType = self.weatherTypes[0]
                }
                else if ((currentForecast.currently?.icon)!.rawValue == "clear-night") {
                    self.iconView.setType = self.weatherTypes[1]
                }
                else if ((currentForecast.currently?.icon)!.rawValue == "cloudy") {
                    self.iconView.setType = self.weatherTypes[2]
                }
                else if ((currentForecast.currently?.icon)!.rawValue == "fog") {
                    self.iconView.setType = self.weatherTypes[3]
                }
                else if ((currentForecast.currently?.icon)!.rawValue == "partly-cloudy-day") {
                    self.iconView.setType = self.weatherTypes[4]
                }
                else if ((currentForecast.currently?.icon)!.rawValue == "partly-cloudy-night") {
                    self.iconView.setType = self.weatherTypes[5]
                }
                else if ((currentForecast.currently?.icon)!.rawValue == "rain") {
                    self.iconView.setType = self.weatherTypes[6]
                }
                else if ((currentForecast.currently?.icon)!.rawValue == "sleet") {
                    self.iconView.setType = self.weatherTypes[7]
                }
                else if ((currentForecast.currently?.icon)!.rawValue == "snow") {
                    self.iconView.setType = self.weatherTypes[8]
                }
                else if ((currentForecast.currently?.icon)!.rawValue == "wind") {
                    self.iconView.setType = self.weatherTypes[9]
                }
                self.iconView.setColor = UIColor.black
            case .failure(let error):
                //  Uh-oh. We have an error!
                print("error getting forecast!")
            }
        }
    }
    
    //********************
    
    
    func fetchEvents() {
        var eList: [EKEvent] = []
        let now = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents.init()
        dateComponents.day = 60
        let futureDate = calendar.date(byAdding: dateComponents, to: now)
        let eventsPredicate = self.eventStore.predicateForEvents(withStart: now, end: futureDate!, calendars: nil)
        let events = self.eventStore.events(matching: eventsPredicate)
        for event in events {
        eList.append(event)
            print("\(String(describing: event.title))")
        }
        eventList = ExpandableEvents(isExpanded: true, events: eList)
    }
    
    func fetchReminder(){
        var rList: [EKReminder] = []
                var dateComponents = DateComponents.init()
                dateComponents.day = 60
                let reminderPredicate = self.eventStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: nil)
                    self.eventStore.fetchReminders(matching: reminderPredicate, completion: {
                        (reminders: [EKReminder]?) -> Void in
                            for reminder in reminders! {
                            rList.append(reminder)
                            print("\(String(describing: reminder.title))")
                            }
               })
        reminderList = ExpandableReminders(isExpanded: true, reminders: rList)
    }
    
    func setupTableView() {
        todayTableView.dataSource = self
        todayTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerList[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        let label = UILabel()
        label.text = headerList[section]
        label.frame =  CGRect(x:45,y:5,width:100,height:35)
        view.addSubview(label)
        
        let button = UIButton(type: .system)
        button.tag = section
        if section == 0 {
            if eventList!.isExpanded == true {
                button.setTitle("Close", for: .normal)
            } else {
                button.setTitle("Open", for: .normal)
            }
        } else {
            if reminderList!.isExpanded == true {
                button.setTitle("Close", for: .normal)
            } else {
                button.setTitle("Open", for: .normal)
            }
        }
        button.addTarget(self, action: #selector(expandCollapse), for: .touchUpInside)
        button.frame = CGRect(x: 250, y: 5, width: 50, height: 35)
        view.addSubview(button)
        return view
    }
    
    @objc func expandCollapse(button: UIButton) {
        let section = button.tag
        
        if section == 0 {
            eventList!.isExpanded = !eventList!.isExpanded
        }
        if section == 1 {
            reminderList!.isExpanded = !reminderList!.isExpanded
        }
        
        todayTableView.reloadSections(IndexSet(arrayLiteral: section), with: .automatic)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if eventList!.isExpanded == true {
                return eventList!.events.count
            } else {
                return 0
            }
        }
        if section == 1 {
            if reminderList!.isExpanded == true {
                return reminderList!.reminders.count
            } else {
                return 0
            }
        }
        else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if indexPath.section == 0{
        cell.textLabel!.text = eventList!.events[indexPath.row].title
            // eventList[indexPath.row].startDate.startHour
            
            cell.detailTextLabel?.text = "\(eventList!.events[indexPath.row].startDate.time(date: eventList!.events[indexPath.row].startDate)) -- \(eventList!.events[indexPath.row].endDate.time(date: eventList!.events[indexPath.row].endDate))"
        }
       else if indexPath.section == 1 {
            cell.textLabel!.text = reminderList!.reminders[indexPath.row].title
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            if(indexPath.section == 0){
                print("\(indexPath.row) \(String(describing: eventList!.events[indexPath.row].title))deleted")
                eventList!.events.remove(at: indexPath.row)
                self.todayTableView.reloadData()

            }
            else{
                print("\(indexPath.row) \(String(describing: reminderList!.reminders[indexPath.row].title))deleted")
                reminderList!.reminders.remove(at: indexPath.row)
                self.todayTableView.reloadData()

            }
        }
    }
    
    func gotoAppleCalendar(date: Date) {
    //https://stackoverflow.com/questions/48312759/swift-how-to-open-up-calendar-app-at-specific-date-and-time
        let interval = date.timeIntervalSinceReferenceDate
        if let url = URL(string: "calshow:\(interval)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let date = Date()
        print("cell selected")
        gotoAppleCalendar(date: date)
    }
    
    
    func requestEventAccess(){
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
        
    }
    
    func requestReminderAccess(){
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        requestEventAccess()
        requestReminderAccess()
        fetchEvents()
        fetchReminder()
        setupTableView()
        
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        todayTableView.delegate = self
        
        titleBar.title = "\(date.weekDay()) \(date.monthAsString()) \(day)\(date.dayEnding())"
        
        setupNewsCollectionView()
        fetchDataForNewsCollectionView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.todayTableView.reloadData()
        }
    //WEATHER
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        iconView = SKYIconView(frame: CGRect(x: 0, y: 0, width: weatherIconView.bounds.size.width, height: weatherIconView.bounds.size.height))
        
        if yPadding >= UIScreen.main.bounds.height - 200 {
            xPadding += 100
            yPadding = 30
        } else {
            yPadding += 140
        }
        
        iconView.setColor = UIColor.clear
        iconView.backgroundColor = UIColor.clear
        
        self.weatherIconView.addSubview(iconView)
        getData()

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

    
   //**********News**********//
    var newsData: NewsAPIResults? = nil
    var currentIndex = 0
    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = newsCollectionView.dequeueReusableCell(withReuseIdentifier: "ncell", for: indexPath) as! NewsCollectionViewCell
        guard let results = newsData else {return cell}
        let story = results.articles[indexPath.row]
        
        //Format the headline and outlet, then display
        let titleSplit = story.title?.components(separatedBy: "-")
        guard let titleSplitUnwrapped = titleSplit else {return cell}
        var headline = ""
        for index in 0 ..< titleSplitUnwrapped.count - 1 {
            headline += titleSplitUnwrapped[index]
        }
        let outlet = "-" + titleSplitUnwrapped.last!
        cell.displayArticle(title: headline, media: outlet)
        
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
        currentIndex = Int((self.newsCollectionView.contentOffset.x) / self.newsCollectionView.frame.size.width)
        self.pageControl.currentPage = currentIndex
    }
    
    @IBAction func goToArticle(_ sender: UITapGestureRecognizer) {
        guard let results = newsData else {return}
        if let url = results.articles[currentIndex].url {
            UIApplication.shared.open(url, options: [:])
        }
    }
    //*************************//
}
