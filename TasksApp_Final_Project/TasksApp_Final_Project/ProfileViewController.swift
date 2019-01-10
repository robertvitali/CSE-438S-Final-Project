//
//  ProfileViewController.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 11/15/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseDatabase
import CoreData

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
  
    let userID = Auth.auth().currentUser!.uid
    let ref = Database.database().reference()
    var account:[String] = ["Sign Out", "Permissions"]
    var setting:[String] = ["Temperature", "Show Archived Folders"]
    var headerList:[String] = ["Account","Preferences"]
    var savedSettings:[NSManagedObject] = []
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerList[section]
    }
    

    //  @IBOutlet weak var settingBar: UINavigationItem!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return account.count
        }
        else{
            return setting.count
        }
    }
    
    @IBOutlet weak var settingTableView: UITableView!
    
    @objc func changeTempUnit(_ sender:UISwitch){
        if(sender.isOn == true){
            Profile.displayInF = true
            setting[0] = "Temperature: °F"
        }
        else{
            Profile.displayInF = false
            setting[0] = "Temperature: °C"
        }
        ref.child("\(userID)/TempUnitF").setValue([Profile.displayInF])
        settingTableView.reloadData()
    }
    
    @objc func changeArchive(_ sender:UISwitch){
        setSettings(position: 0)
        getSettings()
        settingTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if indexPath.section == 0{
            cell.textLabel!.text = account[indexPath.row]
        }
        if indexPath.section == 1 {
            cell.textLabel!.text = setting[indexPath.row]
            let switchView = UISwitch(frame : .zero)
            if(indexPath.row == 0){
                switchView.setOn(Profile.displayInF ?? false, animated: true)
            }else if(indexPath.row == 1){
                //put in load data for archiving a folder
                let tf = savedSettings[0].value(forKey: "tf") as? Bool
                switchView.setOn(tf!, animated: true)
            }
            switchView.tag = indexPath.row
            if(indexPath.row == 0){
                switchView.addTarget(self, action: #selector(ProfileViewController.changeTempUnit(_:)), for: .valueChanged)
            }else if(indexPath.row == 1){
                switchView.addTarget(self, action: #selector(ProfileViewController.changeArchive(_:)), for: .valueChanged)
            }
            cell.accessoryView = switchView
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selcted")
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                GIDSignIn.sharedInstance().signOut()
                print("SIGN OUT")
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
                self.present(nextViewController, animated:true, completion:nil)
            }else if(indexPath.row == 1){
                let settingsURL = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(settingsURL!)
            }
        }
    }
    
    func setupTableView(){
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
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
            // Profile.displayInF = store
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchDataFromFirebase()
        self.getSettings()
        if(Profile.displayInF == false){
            setting[0] = "Temperature: °C"
        }else{
            setting[0] = "Temperature: °F"
        }
        navigationController?.navigationBar.barTintColor = Colors.headerBackground
        self.setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchDataFromFirebase()
        self.getSettings()
        if(Profile.displayInF == false){
            setting[0] = "Temperature: °C"
        }else{
            setting[0] = "Temperature: °F"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.settingTableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSettings(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Settings")
        do{
            savedSettings = try context.fetch(fetchRequest)
        }catch{
            print("ERROR")
        }
        if(savedSettings == []){
            createNewSetting()
        }
    }
    
    func setSettings(position:Int){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let objectUpdate = savedSettings[position]
        var tfVal = objectUpdate.value(forKey: "tf") as? Bool
        if(tfVal != true && tfVal != false){
            tfVal = true
        }
        objectUpdate.setValue(!tfVal!, forKey: "tf")
        do{
            try context.save()
        }catch{
            print("ERROR")
        }
    }
    
    func createNewSetting(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Settings", in: context)!
        let theTitle = NSManagedObject(entity: entity, insertInto: context)
        theTitle.setValue(false, forKey: "tf")
        do{
            try context.save()
        }catch{
            print("CANNOT SAVE! ERROR!")
        }
        getSettings()
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
