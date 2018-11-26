//
//  SignInViewController.swift
//  TasksApp_Final_Project
//
//  Created by Robert on 11/15/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class SignInViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textParagraph: UITextView!
    @IBOutlet var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden = false
        spinner.startAnimating()
        titleLabel.isHidden = true
        textParagraph.isHidden = true
        signInButton.isHidden = true
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loadFunction()
        }
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homePage = mainStoryboard.instantiateViewController(withIdentifier: "Tab") as! UITabBarController
        self.window?.rootViewController = homePage
        // Do any additional setup after loading the view.
    }
    
    func loadFunction(){
        DispatchQueue.global().async{
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                self.titleLabel.isHidden = false
                self.textParagraph.isHidden = false
                self.signInButton.isHidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
