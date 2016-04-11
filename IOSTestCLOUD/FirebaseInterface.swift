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
    
    //var userRef = Firebase(url:"https://radiant-heat-681.firebaseio.com/OuiCan%20Users/oskalli")


    static func retrieveFillLevel(userRefUrl: String) -> String{
        
        var fillLevel = "0"
        let userRef = Firebase(url: userRefUrl)
        userRef.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value.objectForKey("fillLevel"))
            fillLevel = snapshot.value.objectForKey("fillLevel") as! String
            }, withCancelBlock: { error in
                print(error.description)
        })
        print(fillLevel)
        return fillLevel
    }

}