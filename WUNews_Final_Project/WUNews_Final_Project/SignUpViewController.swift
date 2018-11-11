//
//  SignUpViewController.swift
//  WUNews_Final_Project
//
//  Created by Robert on 11/10/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var passwordField2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUp(_ sender: Any) {
        let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(okAction)
        
        if(emailField.text != "" && passwordField.text != "" && passwordField2.text != "" && passwordField.text == passwordField2.text){
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                print(error!)
                if (error == nil){
                    alert.title = "Sign Up Successful!"
                    alert.message = "Enjoy the app!"
                }else if(error!._code == 17007){
                    alert.message = "This email already is associated to an account. Please use another email or sign in."
                }
            }
        }else if(passwordField2.text != passwordField.text){
            alert.message = "Password fields do not match"
            passwordField.text = ""
            passwordField2.text = ""
        }else{
            alert.title = "Something went wrong"
            alert.message = "Try again"
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    

}
