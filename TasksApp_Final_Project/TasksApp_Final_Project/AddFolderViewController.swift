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
        textField!.layer.borderColor = UIColor.gray.cgColor
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddFolderViewController.viewTapped(gestureRecognizer: )))
        
        
        view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true )
    }
    
    @IBAction func addToList(_ sender: Any) {
        if(textField.text != ""){
            list.append(textField.text!)
            textField.text = ""
            navigationController?.popViewController(animated: true)
        }
    }
    
    
}
