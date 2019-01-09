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
import FirebaseDatabase
import ForecastIO
import CoreLocation
import MapKit
import CoreData
import SafariServices

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate {
    let userID = Auth.auth().currentUser!.uid
    let ref = Database.database().reference()
    
    
    
    
    @IBOutlet var titleBar: UINavigationItem!
    @IBOutlet weak var weatherHeader: UIView!
    @IBOutlet weak var todayTableView: UITableView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempRangeLabel: UILabel!
    @IBOutlet weak var weatherIconView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var weatherViewfull: CustomView!
    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var newsHeader: UIView!
    
    
    var eventStore:EKEventStore = EKEventStore.init()
    var eventList: ExpandableEvents? = nil
    var reminderList: ExpandableReminders? = nil
    var taskList: ExpandableTasks? = nil
    var headerList:[String] = ["Events","Reminders","Tasks"]
    var calendarArray:[EKCalendar] = []
    var taskArray:[NSManagedObject] = []
    var sortedtaskArray: [NSManagedObject] = []
    var stateArray: [NSManagedObject] = []
    var currentPos = 0
    
    //***********WEATHER************//
    
    
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
    
    func fetchDataFromFirebase() {
        print ("firebase time")
        ref.child("\(userID)/TempUnitF/0").observe(.value, with: {(snapshot) in
            let store = snapshot.value as? Bool
            if(store == nil){
                print("nill")
                Profile.displayInF = true
                self.ref.child("\(self.userID)/TempUnitF").setValue([Profile.displayInF])
            }
            else{
                print("entered here")
                Profile.displayInF = store
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        myLat = location.coordinate.latitude
        myLon = location.coordinate.longitude
        print("LAT AND LON UPDATED: \(myLat),\(myLon)")
    }
    
    func getTasksData(){
        DispatchQueue.main.async{
            self.sortedtaskArray = []
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Tasks")
        do{
            self.taskArray = try context.fetch(fetchRequest)
            var s:Date
            var tf:Bool = false
            let date = Date()
            print("GETTING TASKS")
            for item in self.taskArray {
                s = (item.value(forKey: "date") as? Date)!
                tf = (item.value(forKey: "complete") as? Bool)!
                if(s <= date && tf == false){
                    self.sortedtaskArray.append(item)
                }
            }
            print("TASK COUNT: \(self.sortedtaskArray.count)")
        }catch{
            print("ERROR")
        }
        
        self.taskList = ExpandableTasks(isExpanded: (stateArray[2].value(forKey: "isOpen") as? Bool)!, tasks: self.sortedtaskArray)
    }
    
    func getForecastData() {
        manager.startUpdatingLocation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("AFTER 1 SECOND DELAY GETTING FORECAST")
            self.client.getForecast(latitude: self.myLat, longitude: self.myLon) { result in
                switch result {
                case .success(let currentForecast, _):
                    print("Forecast received!")
                    self.iconView.refresh()
                    self.summaryText = (currentForecast.currently?.summary)!
                    if(Profile.displayInF == true){
                        self.tempText = "\(Int((currentForecast.currently?.temperature)!))º \(self.displayUnits)"
                    }
                    else{
                        let num = Int((currentForecast.currently?.temperature)!)
                        let dnum = ((num-32)*5)/9
                        self.tempText = "\(dnum)º C"
                    }
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
                    
                    self.tempLabel.isHidden = false
                    self.summaryLabel.isHidden = false
                    self.tempRangeLabel.isHidden = false
                    self.iconView.isHidden = false
                    self.weatherIconView.isHidden = false
                    
                    
                    self.spinner.isHidden = true
                    print("SPINNER JUST BECAME HIDDEN")
                    self.iconView.refresh()
                    print("FIRST ICON REFRESH")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                        self.spinner.stopAnimating()
                        print("DELAYED STOP SPINNER")
                        self.iconView.refresh()
                        print("SECOND ICON REFRESH")
                    }
                    
                case .failure(_):
                    //  Uh-oh. We have an error!
                    print("error getting forecast!")
                }
            }
            self.manager.stopUpdatingLocation()
        }
    }
    
    
    func setUpWeather() {
        spinner.isHidden = false
        tempLabel.isHidden = true
        summaryLabel.isHidden = true
        tempRangeLabel.isHidden = true
        iconView.isHidden = true
        weatherIconView.isHidden = true
        spinner.startAnimating()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
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
        getForecastData()
    }
    
    //*****************************Event/calendar*********************************//
    
    // fetch event from local calendar data
    func fetchEvents() {
        var eList: [EKEvent] = []
        let now = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents.init()
        dateComponents.day = 1
        let futureDate = calendar.date(byAdding: dateComponents, to: now)
        let eventsPredicate = self.eventStore.predicateForEvents(withStart: now, end: futureDate!, calendars: nil)
        let events = self.eventStore.events(matching: eventsPredicate)
        for event in events {
            eList.append(event)
            print("\(String(describing: event.title))")
        }
        
        DispatchQueue.global(qos: .background).async {
            self.eventList = ExpandableEvents(isExpanded: (self.stateArray[0].value(forKey: "isOpen") as? Bool)!, events: eList)
        }
    }
    
    //fetch reminder from local reminder
    func fetchReminder(){
        var rList: [EKReminder] = []
        var dateComponents = DateComponents.init()
        dateComponents.day = 1
        let reminderPredicate = self.eventStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: nil)
        self.eventStore.fetchReminders(matching: reminderPredicate, completion: {
            (reminders: [EKReminder]?) -> Void in
            for reminder in reminders! {
                rList.append(reminder)
                print("\(String(describing: reminder.title))")
            }
            self.reminderList = ExpandableReminders(isExpanded: (self.stateArray[1].value(forKey: "isOpen") as? Bool)!, reminders: rList)
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
            if(eventList!.events == []){
                button.isHidden = true
            }
        } else if section == 1 {
            if reminderList!.isExpanded == true {
                button.setImage(rTriangle, for: .normal)
            } else {
                button.setImage(triangle, for: .normal)
            }
            if(reminderList!.reminders == []){
                button.isHidden = true
            }
        } else{
            if taskList!.isExpanded == true {
                button.setImage(rTriangle, for: .normal)
            } else {
                button.setImage(triangle, for: .normal)
            }
            if(taskList!.tasks == []){
                button.isHidden = true
            }
        }
        button.addTarget(self, action: #selector(expandCollapse), for: .touchUpInside)
        button.frame = CGRect(x: 310, y: 15, width: 18, height: 15)
        view.addSubview(button)
        return view
    }
    
    
    @objc func expandCollapse(button: UIButton) {
        let section = button.tag
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if section == 0 {
            eventList!.isExpanded = !eventList!.isExpanded
            stateArray[0].setValue(eventList!.isExpanded, forKey: "isOpen")
        }
        if section == 1 {
            reminderList!.isExpanded = !reminderList!.isExpanded
            stateArray[1].setValue(reminderList!.isExpanded, forKey: "isOpen")
        }
        if section == 2 {
            taskList!.isExpanded = !taskList!.isExpanded
            stateArray[2].setValue(taskList!.isExpanded, forKey: "isOpen")
        }
        
        do{
            try context.save()
        }catch{
            print("ERROR saving open closed prefrences")
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
        return 3
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
        else if section == 1 {
            if reminderList!.isExpanded == true {
                return reminderList!.reminders.count
            } else {
                return 0
            }
        }else if section == 2{
            if taskList!.isExpanded == true{
                return taskList!.tasks.count
            }else{
                return 0
            }
        }
        else {
            return 3
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
        if indexPath.section == 2{
            let taskItem = taskList!.tasks[indexPath.row]
            cell.textLabel!.text = taskItem.value(forKey: "name") as? String
            let taskDate = taskItem.value(forKey: "date") as? Date
            cell.detailTextLabel!.text = "Due Date: \(Date().dateToStringFormatted(date: taskDate!))"
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
        let edit = editAction(at: indexPath)
        edit.image = UIImage(named: "edit")
        delete.image = UIImage(named: "trash1")
        if(indexPath.section == 2){
            return  UISwipeActionsConfiguration(actions: [delete, edit])
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completed = completedAction(at: indexPath)
        completed.image = UIImage(named: "checkmark")
        completed.backgroundColor = .green
        if(indexPath.section != 0){
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
            }else if(indexPath.section == 2){
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let objectUpdate = self.sortedtaskArray[indexPath.row]
                var tf:Bool = (objectUpdate.value(forKey: "complete") as? Bool)!
                tf = !tf
                objectUpdate.setValue(tf, forKey: "complete")
                do{
                    try context.save()
                }catch{
                    print("ERROR")
                }
                self.getTasksData()
                self.todayTableView.reloadData()
            }
            completion(true)
            action.backgroundColor = .purple
        }
        return action
    }
    
    func getPosition(uniqueString: Int64) -> Int{
        var count = 0
        for item in taskArray{
            let uid = item.value(forKey: "uniqueID") as? Int64
            if(uid == uniqueString){
                return count
            }
            count = count + 1
        }
        return 0
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: "Delete"){(action, view, completion) in
            if(indexPath.section == 0){
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
            if(indexPath.section == 2){
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let title = self.sortedtaskArray[indexPath.row]
                let uniqueString:Int64 = (title.value(forKey: "uniqueID") as? Int64)!
                let position:Int = self.getPosition(uniqueString: uniqueString)
                context.delete(self.taskArray[position])
                self.taskArray.remove(at: position)
                self.sortedtaskArray.remove(at: indexPath.row)
                print("TRYING TO DELETE")
                do{
                    try context.save()
                }catch{
                    print("ERROR")
                }
                self.getTasksData()
                self.todayTableView.reloadData()
            }
            
            completion(true)
            action.backgroundColor = .red
        }
        return action
    }
    
    func editAction(at indexPath: IndexPath) -> UIContextualAction{
        let edit = UIContextualAction(style: .normal, title: "Edit"){ (action, view, completion) in
            if(indexPath.section == 2){
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let destination = storyboard.instantiateViewController(withIdentifier: "Add Task VC") as! AddTaskViewController
                let title = self.sortedtaskArray[indexPath.row]
                taskName = title.value(forKey:"name") as? String
                taskDate = title.value(forKey:"date") as? Date
                taskNotes = title.value(forKey:"notes") as? String
                uniqueIDT = title.value(forKey:"uniqueID") as? Int64
                self.navigationController?.pushViewController(destination, animated: true)
            }
            completion(true)
        }
        
        edit.backgroundColor = .orange
        return edit
    }
    
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
    
    func gotoReminder(){
        if let url = URL(string: "x-apple-reminder://"){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let date = Date()
        print("cell selected")
        if(indexPath.section == 0){
            gotoAppleCalendar(date: date)
        }
        else if(indexPath.section == 1){
            gotoReminder()
        }else if(indexPath.section == 2){
            let title = self.sortedtaskArray[indexPath.row]
            currentPos = indexPath.row
            let titleLabel = title.value(forKey: "name") as? String
            let dateValue = title.value(forKey: "date") as? Date
            let date = Date().dateToStringFormatted(date: dateValue!)
            let notesValue = title.value(forKey: "notes") as? String
            let notesString = notesValue ?? ""
            let messageString = date + "\n" + notesString
            let alert = UIAlertController(title: titleLabel, message: messageString, preferredStyle: .alert)
            let update = UIAlertAction(title: "Edit", style: .default, handler: self.update)
            let complete = UIAlertAction(title: "Complete", style: .default, handler: self.complete)
            let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(complete)
            alert.addAction(update)
            alert.addAction(dismiss)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func update(alert:UIAlertAction){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "Add Task VC") as! AddTaskViewController
        let title = sortedtaskArray[currentPos]
        taskName = title.value(forKey:"name") as? String
        taskDate = title.value(forKey:"date") as? Date
        taskNotes = title.value(forKey:"notes") as? String
        uniqueIDT = title.value(forKey:"uniqueID") as? Int64
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func complete(alert:UIAlertAction){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let objectUpdate = sortedtaskArray[currentPos]
        var tf:Bool = (objectUpdate.value(forKey: "complete") as? Bool)!
        tf = !tf
        objectUpdate.setValue(tf, forKey: "complete")
        do{
            try context.save()
        }catch{
            print("ERROR")
        }
        getTasksData()
        reloadingTodayTableView()
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
    
    func saveInitState(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ExpandedState", in: context)!
        
        let calEntity = NSManagedObject(entity: entity, insertInto: context)
        calEntity.setValue(true, forKey: "isOpen")
        
        let remEntity = NSManagedObject(entity: entity, insertInto: context)
        remEntity.setValue(true, forKey: "isOpen")
        
        
        let taskEntity = NSManagedObject(entity: entity, insertInto: context)
        taskEntity.setValue(true, forKey: "isOpen")
        
        do{
            try context.save()
        }catch{
            print("CANNOT SAVE! ERROR!")
        }
    }
    
    func getSavedState(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let stateRequest = NSFetchRequest<NSManagedObject>(entityName: "ExpandedState")
        do{
            stateArray = try context.fetch(stateRequest)
        }catch{
            print("Cannot get task state")
        }
        
        if(stateArray == []){
            saveInitState()
            getSavedState()
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VIEW DID LOAD")
        // Do any additional setup after loading the view.
        weatherHeader.backgroundColor = Colors.headerBackground
        newsHeader.backgroundColor = Colors.headerBackground
        // navigationController?.navigationBar.prefersLargeTitles = true
        
        getSavedState()
        
        requestEventAccess()
        requestReminderAccess()
        fetchDataFromFirebase()
        fetchEvents()
        fetchReminder()
        getTasksData()
        setupTableView()
        setUpWeather()
        
        todayTableView.delegate = self
        
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        
        titleBar.largeTitleDisplayMode = .always
        
        //titleBar.title = "\(date.weekDay()) \(date.monthAsString()) \(day)\(date.dayEnding())"
        titleBar.title = "\(date.monthAsString()) \(day)\(date.dayEnding())"
        navigationController?.navigationBar.barTintColor = Colors.headerBackground
        
        
        
        setupNewsCollectionView()
        fetchDataForNewsCollectionView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadingTodayTableView(){
        DispatchQueue.main.async {
            self.todayTableView.reloadData()
            print("RELOADED EVENTS")
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        fetchEvents()
        fetchReminder()
        reloadingTodayTableView()
        getTasksData()
        reloadingTodayTableView()
        getForecastData()
    }
    
    //****************News****************//
    var newsData: NewsAPIResults? = nil
    var currentIndex = 0
    
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
            //UIApplication.shared.open(url, options: [:])
            openWebsite(url: url)
        }
    }
    
    
    @IBAction func goToWeather(_ sender: UITapGestureRecognizer){
        let url = URL(string: "https://darksky.net/forecast/\(myLat),\(myLon)")
        //UIApplication.shared.open(url!, options: [:])
        openWebsite(url: url!)
    }
    
    func openWebsite(url: URL){
        let webVC = SFSafariViewController(url: url)
        present(webVC, animated: true)
    }
    
    
}
