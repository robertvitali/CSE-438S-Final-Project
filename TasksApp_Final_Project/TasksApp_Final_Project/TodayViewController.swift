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
    var headerList:[String] = ["Events","Reminders"]
    var calendarArray:[EKCalendar] = []
    
    //***********WEATHER************//
    @IBOutlet weak var weatherHeader: UIView!
    
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
    var tempRangeText:String = ""
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempRangeLabel: UILabel!
    
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
                print("Forecast received!")
                self.spinner.isHidden = true
                self.iconView.refresh()
                self.spinner.isHidden = true
                self.summaryText = (currentForecast.currently?.summary)!
                self.tempText = "\(Int((currentForecast.currently?.temperature)!))º \(self.displayUnits)"
                self.tempRangeText = "\((currentForecast.daily?.data[0].temperatureHigh)!) / \((currentForecast.daily?.data[0].temperatureLow)!)"
                self.summaryLabel.font.withSize(20)
                self.tempLabel.font.withSize(12)
                self.summaryLabel.textColor = .gray
                self.summaryLabel.text = self.summaryText
                self.tempLabel.text = self.tempText
                self.tempRangeLabel.text = self.tempRangeText
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
                self.spinner.isHidden = true
            case .failure(let error):
                //  Uh-oh. We have an error!
                print("error getting forecast!")
            }
        }
    }
    
    
    func setUpWeather() {
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
    
    //*****************************Event/calendar*********************************//
    
    // fetch event from local calendar data
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
        print("eList contains\(eList)")
    }
    
    //fetch reminder from local reminder
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
                        self.reminderList = ExpandableReminders(isExpanded: true, reminders: rList)
                        print("rList contains\(rList)")
               })
    }
    
    //set up table view
    func setupTableView() {
        todayTableView.dataSource = self
        todayTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    // table view header function
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerList[section]
    }
    
    //table view header view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = Colors.headerBackground
        let label = UILabel()
        label.text = headerList[section]
        label.frame =  CGRect(x:20,y:5,width:100,height:35)
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        view.addSubview(label)
        
        let button = UIButton(type: .custom)
        button.tag = section
        let triangle = UIImage(named: "triangle")
        let rTriangle = UIImage(named: "reversed")
        
        if section == 0 {
            if eventList!.isExpanded == true {
                button.setImage(rTriangle, for: .normal)
            } else {
                button.setImage(triangle, for: .normal)
            }
        } else {
            if reminderList!.isExpanded == true {
                button.setImage(rTriangle, for: .normal)
            } else {
                button.setImage(triangle, for: .normal)
            }
        }
        
        button.addTarget(self, action: #selector(expandCollapse), for: .touchUpInside)
        button.frame = CGRect(x: 310, y: 15, width: 18, height: 15)
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
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = CGFloat.pi
        animation.duration = 0.25
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        button.layer.add(animation, forKey: nil)
        
        todayTableView.reloadSections(IndexSet(arrayLiteral: section), with: .automatic)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //determine the content for each section
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
    
    //table view cell format
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if indexPath.section == 0 {
        cell.textLabel!.text = eventList!.events[indexPath.row].title
            // eventList[indexPath.row].startDate.startHour
            
            cell.detailTextLabel?.text = "\(eventList!.events[indexPath.row].startDate.time(date: eventList!.events[indexPath.row].startDate)) to \(eventList!.events[indexPath.row].endDate.time(date: eventList!.events[indexPath.row].endDate))"
        }
       if indexPath.section == 1 {
            cell.textLabel!.text = reminderList!.reminders[indexPath.row].title
        }
        return cell
    }
    
    //allow editing for table view cells
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //swipe to delete table view cells
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return  UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completed = completedAction(at: indexPath)
        if(indexPath.section == 1){
        return UISwipeActionsConfiguration(actions: [completed])
        }
        else{
            return nil
        }
    }
    
    func completedAction(at indexPath:IndexPath) -> UIContextualAction{
         let action = UIContextualAction(style: .normal, title:"Complete"){(action,view,completion) in
            if(indexPath.section == 1){
                self.reminderList!.reminders[indexPath.row].isCompleted = true
                do{
                    try self.eventStore.save(self.reminderList!.reminders[indexPath.row], commit: true)
                } catch _ as NSError{return}
                self.reminderList!.reminders.remove(at: indexPath.row)
                self.todayTableView.reloadData()
            }
            completion(true)
            action.backgroundColor = .purple
        }
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: "Delete"){(action, view, completion) in
        if(indexPath.section == 0){
          //  let eventSelected = eventList?.events[indexPath.row]
                print("\(indexPath.row) \(String(describing: self.eventList!.events[indexPath.row].title))deleted")
                self.deleteEvent((self.eventList?.events[indexPath.row].eventIdentifier)!)
                self.eventList!.events.remove(at: indexPath.row)
                self.todayTableView.reloadData()
            }
        if(indexPath.section == 1){
            self.deleteReminder(self.reminderList!.reminders[indexPath.row])
            self.reminderList!.reminders.remove(at: indexPath.row)
            self.todayTableView.reloadData()
        }
        completion(true)
        action.backgroundColor = .red
    }
        return action
    }
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//            if(indexPath.section == 0){
//                if(editingStyle == .delete){
//                print("\(indexPath.row) \(String(describing: eventList!.events[indexPath.row].title))deleted")
//                deleteEvent((eventList?.events[indexPath.row].eventIdentifier)!)
//                eventList!.events.remove(at: indexPath.row)
//                self.todayTableView.reloadData()
//                }
//            }
//            else{
//                 if(editingStyle == .delete){
//                print("\(indexPath.row) \(String(describing: reminderList!.reminders[indexPath.row].title))deleted")
//                reminderList!.reminders.remove(at: indexPath.row)
//                self.todayTableView.reloadData()
//                }
//                if(editingStyle == .none){
//
//                }
//            }
//    }
    // delete event from calendar
    func deleteEvent(_ storedEventID: String)
    {
        //https://stackoverflow.com/questions/50425744/eventkit-remove-event-from-calendar
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil)
            {
                
                if let calendarEvent_toDelete = self.eventStore.event(withIdentifier: storedEventID){
                    
                    //recurring event
                    if calendarEvent_toDelete.recurrenceRules?.isEmpty == false
                    {
                        let alert = UIAlertController(title: "Repeating Event", message:
                            "This is a repeating event.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        //delete this event only
                        let thisEvent_Action = UIAlertAction(title: "Delete this event", style: UIAlertActionStyle.default)
                        {
                            (result : UIAlertAction) -> Void in
                            
                            //sometimes doesn't delete anything, sometimes deletes all reccurent events, not just current!!!
                            do{
                                try self.eventStore.remove(calendarEvent_toDelete, span: .thisEvent)
                            } catch _ as NSError{return}
                            
                        }
                        alert.addAction(thisEvent_Action)
                        
                    }
                        //not recurring event
                    else{
                        //works fine
                        do{
                            try self.eventStore.remove(calendarEvent_toDelete, span: EKSpan.thisEvent)
                        } catch _ as NSError{
                            return
                        }
                    }
                }
                
            }
        })
    }
    
    func deleteReminder(_ reminder_toDelete: EKReminder){
        eventStore.requestAccess(to: .reminder, completion: { (granted, error) in
            if (granted) && (error == nil)
            {
                do{
                     try self.eventStore.remove(reminder_toDelete,commit: true)
                } catch _ as NSError{
                    return
                }
            }
        })
    }
    
    // open calendar function call
    func gotoAppleCalendar(date: Date) {
    //https://stackoverflow.com/questions/48312759/swift-how-to-open-up-calendar-app-at-specific-date-and-time
        let interval = date.timeIntervalSinceReferenceDate
        if let url = URL(string: "calshow:\(interval)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    //
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let date = Date()
        print("cell selected")
        gotoAppleCalendar(date: date)
    }
    
    // request access for local event
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
    
    //request access for local reminder
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
        weatherHeader.backgroundColor = Colors.headerBackground
        newsHeader.backgroundColor = Colors.headerBackground
        
        requestEventAccess()
        requestReminderAccess()
        fetchEvents()
        fetchReminder()
        setupTableView()
        setUpWeather()
        
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        todayTableView.delegate = self
        
        titleBar.title = "\(date.weekDay()) \(date.monthAsString()) \(day)\(date.dayEnding())"
        
        setupNewsCollectionView()
        fetchDataForNewsCollectionView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.todayTableView.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.iconView.refresh()
            self.spinner.isHidden = true
        }
  
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
        self.iconView.refresh()
        self.spinner.isHidden = true
    }
    
   //****************News****************//
    var newsData: NewsAPIResults? = nil
    var currentIndex = 0
    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var newsHeader: UIView!
    
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
}
