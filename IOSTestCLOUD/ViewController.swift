//
//  ViewController.swift
//  IOSTestCLOUD
//
//  Created by mac on 2/27/16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UIViewController {

    // Create a reference to a Firebase location
    var myRootRef = Firebase(url:"https://sizzling-heat-3471.firebaseIO.com")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var arrayViewer: UITextView!
    
    @IBAction func updateButton(sender: AnyObject) {
        // Do any additional setup after loading the view, typically from a nib.
        myRootRef.observeEventType(.Value, withBlock: {
            snapshot in
            print("\(snapshot.key) -> \(snapshot.value)")
            self.arrayViewer.text=("\(snapshot.key) -> \(snapshot.value)")
        })
        
    }


    @IBAction func editArea(sender: AnyObject) {
    }

}

