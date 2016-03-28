//
//  FirebaseInterface.swift
//  IOSTestCLOUD
//
//  Created by Omar Skalli on 3/27/16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation
import Firebase

class FirebaseInterface {

    // Create a reference to a Firebase location
    var myRootRef = Firebase(url:"https://radiant-heat-681.firebaseio.com/")

    //@IBOutlet weak var arrayViewer: UITextView!

    @IBAction func updateButton(sender: AnyObject) {
        // Do any additional setup after loading the view, typically from a nib.
        myRootRef.observeEventType(.Value, withBlock: {
            snapshot in
            print("\(snapshot.key) -> \(snapshot.value)")
            //self.arrayViewer.text=("\(snapshot.key) -> \(snapshot.value)")
        })
    }
}