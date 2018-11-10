//
//  SignInViewController.swift
//  
//
//  Created by Robert on 11/10/18.
//

import UIKit
import Firebase
import FirebaseAuth


class SignInViewController: UIViewController {
    

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signIn(_ sender: Any) {
        let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(okAction)
        
        if(emailField.text != "" && passwordField.text != ""){
            Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                print("ERROR CODE BELOW ---------------")
                print(error!._code)
                print(error!)
                if error != nil{
                    let code = error!._code
                    if(code == 17009){
                        self.passwordField.text = ""
                        alert.message = "Incorrect Password"
                    }else if(code == 17011){
                        alert.message = "Account with email: '\(self.emailField.text!)' does not exist"
                    }else if(code == 17008){
                        alert.message = "Email address is not formatted correctly"
                    }
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            alert.message = "Email or Password field is blank"
            self.present(alert, animated: true, completion: nil)
            print("No data in fields")
        }
    }
    
    
    

}
