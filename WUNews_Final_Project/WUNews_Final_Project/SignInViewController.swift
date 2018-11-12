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
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBOutlet var extraButton: UIButton!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
        spinner.isHidden = false
        emailField.isHidden = true
        passwordField.isHidden = true
        titleLabel.isHidden = true
        signInButton.isHidden = true
        forgotPasswordButton.isHidden = true
        extraButton.isHidden = true
        loadFunction()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadFunction(){
        DispatchQueue.global().async{
            let user = Auth.auth().currentUser
            print("LOGGED IN USER'S EMAIL: \(String(describing: user?.email))")
            if(user?.email != nil && user?.email != ""){
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Tab") as! UITabBarController
                self.present(vc, animated: true, completion: nil)
            }else{
                DispatchQueue.main.async {
                    self.emailField.isHidden = false
                    self.passwordField.isHidden = false
                    self.titleLabel.isHidden = false
                    self.signInButton.isHidden = false
                    self.forgotPasswordButton.isHidden = false
                    self.extraButton.isHidden = false
                    self.spinner.isHidden = true
                }
            }
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
            }
        }
    }

    
    @IBAction func signIn(_ sender: Any) {
        let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(okAction)
        
        if(emailField.text != "" && passwordField.text != ""){
            Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                if error != nil{
                    print("ERROR CODE BELOW ---------------")
                    print(error!._code)
                    print(error!)
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
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Tab") as! UITabBarController
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }else{
            alert.message = "Email or Password field is blank"
            self.present(alert, animated: true, completion: nil)
            print("No data in fields")
        }
    }
    
    
    @IBAction func forgotPassword(_ sender: Any) {
        let alert = UIAlertController(title: "Error", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(okAction)
        if(emailField.text != ""){
            Auth.auth().sendPasswordReset(withEmail: emailField.text!) {error in
                print("BEFORE ERROR _________")
                if error != nil{
                    print("ERROR CODE BELOW ---------------")
                    print(error!)
                    alert.message = "Account not found"
                
                }else{
                    alert.title = "Password Reset Sent"
                    alert.message = "Please check your email"
                }
                self.present(alert, animated: true, completion: nil)
            }
            
        }else{
            alert.message = "Email address is not formatted correctly"
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    

}
