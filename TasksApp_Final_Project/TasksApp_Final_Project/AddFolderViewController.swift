//
//  AddFolderViewController.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 11/26/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit

class AddFolderViewController: UIViewController {

    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addToList(_ sender: Any) {
        if(textField.text != ""){
            list.append(textField.text!)
            textField.text = ""
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    
}
