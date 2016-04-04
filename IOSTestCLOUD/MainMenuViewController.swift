//
//  MainMenuViewController.swift
//  IOSTestCLOUD
//
//  Created by Omar Skalli on 3/19/16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit
import Firebase

class MainMenuViewController: UIViewController {

    let ref = Firebase(url: "https://radiant-heat-681.firebaseio.com/OuiCan%20Users")
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ref.observeAuthEventWithBlock { authData in
            if authData != nil {
                self.user = User(authData: authData)
                print(self.user.uid)
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
