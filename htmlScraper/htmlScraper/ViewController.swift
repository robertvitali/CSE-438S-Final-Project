//
//  ViewController.swift
//  htmlScraper
//
//  Created by Robert on 11/11/18.
//  Copyright © 2018 Robert Vitali. All rights reserved.
//

import UIKit
import SwiftSoup

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Set the page URL we want to download

        //WUPR: https://www.wupr.org/
        //WU Underground: https://www.wunderground.wustl.edu/
        //StudLife: https://studlife.com/, check info.plist for specific exceptions that need to be allowed in order to run website
        //Outlook magazine: https://outlook.wustl.edu/
        
        let URL = NSURL(string: "https://studlife.com/")
        
        // Try downloading it
        do {
            let htmlSource = try String(contentsOf: URL! as URL)
            //print(htmlSource)
            
            //try to parse it
            do{
                let doc = try SwiftSoup.parse(htmlSource)
                //try to get a specific item from the htmlSource
                do{
                    let element = try doc.select("title").first()
                    //get the text from the item
                    do{
                        let text = try element?.text()
                        print(text!)
                    }catch{
                        print("Could not get text")
                    }
                }catch{
                    print("Could not get first title")
                }
            }catch{
                print("Could not parse htmlSource")
            }
            
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

