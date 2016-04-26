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
    var userRef = Firebase(url:"https://radiant-heat-681.firebaseio.com/OuiCan%20Users/oskalli")
    var user: User!
    var progressWeight: KDCircularProgress!
    var progressFill: KDCircularProgress!
    
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var fillLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //navigationController!.navigationBar.barTintColor = UIColor(red: 12.0/255.0, green: 50.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        setupFillProgressBar()
        setupWeightProgressBar()
        retrieveFillLevel()
        retrieveWeight()
        
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
    
    
    func setupFillProgressBar(){
        progressFill = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        progressFill.startAngle = -90
        progressFill.progressThickness = 0.2
        progressFill.trackThickness = 0.0
        progressFill.clockwise = true
        progressFill.gradientRotateSpeed = 2
        progressFill.roundedCorners = true
        progressFill.glowMode = .Forward
        progressFill.glowAmount = 0.2
        progressFill.setColors(UIColor.yellowColor())
        progressFill.center = CGPoint(x: view.center.x, y: view.center.y - 15)
        view.addSubview(progressFill)

    }

    func setupWeightProgressBar(){
        progressWeight = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 270, height: 270))
        progressWeight.startAngle = -90
        progressWeight.progressThickness = 0.1
        progressWeight.trackThickness = 0.0
        progressWeight.clockwise = true
        progressWeight.gradientRotateSpeed = 2
        progressWeight.roundedCorners = true
        progressWeight.glowMode = .Forward
        progressWeight.glowAmount = 0.3
        progressWeight.setColors(UIColor.greenColor())
        progressWeight.center = CGPoint(x: view.center.x, y: view.center.y - 15)
        view.addSubview(progressWeight)
    }
    
    
    
    func retrieveFillLevel() {
        userRef.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot.value.objectForKey("fillLevel"))
            let fillLabelText = snapshot.value.objectForKey("fillLevel") as? String
            //print(fillLabelText)
            if (fillLabelText != nil) {
                self.fillLabel.text = fillLabelText! + "% Full"
                let angle = (Double(fillLabelText!)!)*3.60
                self.progressFill.angle = angle
                }
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func retrieveWeight() {
        userRef.observeEventType(.Value, withBlock: { snapshot in
            let weightLabelText = snapshot.value.objectForKey("Weight") as? String
            if (weightLabelText != nil){
                self.weightLabel.text = weightLabelText! + " Kg"
                let angle = ((Double(weightLabelText!)!/20))*360
                self.progressWeight.angle = angle
                }
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func retrieveInventoryCount() {
        userRef.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot.value.objectForKey("Weight"))
            let inventoryCountText = snapshot.value.objectForKey("Weight") as? String
            //print(inventoryCountText)
            if (inventoryCountText != nil){
                self.weightLabel.text = inventoryCountText! + " Kg"
                let angle = ((Double(inventoryCountText!)!/20))*360
                self.progressWeight.angle = angle
            }
            }, withCancelBlock: { error in
                print(error.description)
        })
    }

    
    
}
