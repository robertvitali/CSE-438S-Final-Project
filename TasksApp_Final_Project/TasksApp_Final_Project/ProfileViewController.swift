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
    var setting:[String] = ["Temperature", "Night Mode"]
    var headerList:[String] = ["Account","Settings"]
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerList[section]
    }
    

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
        }
        else{
            Profile.displayInF = false
        }
        ref.child("\(userID)").setValue(["TempUnitF":Profile.displayInF])
    }
    
    @objc func setDarkMode(_ sender:UISwitch){
        if(sender.isOn == true){
            Profile.darkMode = true
        }
        else{
            Profile.darkMode = false
        }
        ref.child("\(userID)").setValue(["darkMode":Profile.darkMode])
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
            switchView.setOn(Profile.displayInF, animated: true)
            }
            else{
            switchView.setOn(Profile.darkMode, animated: true)
            }
            switchView.tag = indexPath.row
            if(indexPath.row == 0){
                switchView.addTarget(self, action: #selector(ProfileViewController.changeTempUnit(_:)), for: .valueChanged)
            }
            else{
                switchView.addTarget(self, action: #selector(ProfileViewController.setDarkMode(_:)), for: .valueChanged)
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
        ref.child("\(userID)?/darkMode").observe(.value, with: {(snapshot) in
            let store = snapshot.value as? Bool
            Profile.darkMode = store!
        })
        ref.child("\(userID)?/TempUnitF").observe(.value, with: {(snapshot) in
                let store = snapshot.value as? Bool
               Profile.displayInF = store!
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         ref.child("\(userID)").setValue(["darkMode":Profile.darkMode])
         ref.child("\(userID)").setValue(["TempUnitF":Profile.displayInF])
        fetchDataFromFirebase()
        setupTableView()
        // Do any additional setup after loading the view.
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
