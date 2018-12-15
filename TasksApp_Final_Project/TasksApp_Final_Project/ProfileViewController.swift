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

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
  
    let userID = Auth.auth().currentUser!.uid
    let ref = Database.database().reference()
    var account:[String] = ["Sign Out"]
    var setting:[String] = ["Temperature"]
    var headerList:[String] = ["Account","Preferences"]
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if indexPath.section == 0{
            cell.textLabel!.text = account[indexPath.row]
        }
        if indexPath.section == 1 {
            cell.textLabel!.text = setting[indexPath.row]
            //https://stackoverflow.com/questions/47038673/add-switch-in-uitableview-cell-in-swift for adding switch to table view cell
            let switchView = UISwitch(frame : .zero)
            if(indexPath.row == 0){
                switchView.setOn(Profile.displayInF ?? false, animated: true)
            }
            switchView.tag = indexPath.row
            if(indexPath.row == 0){
                switchView.addTarget(self, action: #selector(ProfileViewController.changeTempUnit(_:)), for: .valueChanged)
            }
            cell.accessoryView = switchView
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selcted")
        if(indexPath.section == 0){
            GIDSignIn.sharedInstance().signOut()
            print("SIGN OUT")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
            self.present(nextViewController, animated:true, completion:nil)
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
        //settingBar.prefersLargeTitles = true
        super.viewDidLoad()
        self.fetchDataFromFirebase()
        //settingb.title = "Settings"
        //settingb.largeTitleDisplayMode = .automatic
        //  ref.child("\(userID)/TempUnitF").setValue([Profile.displayInF])
        self.setupTableView()
        if(Profile.displayInF == false){
            setting[0] = "Temperature: °C"
        }else{
            setting[0] = "Temperature: °F"
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchDataFromFirebase()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.settingTableView.reloadData()
        }
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
