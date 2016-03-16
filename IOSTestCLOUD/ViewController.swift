//
//  ViewController.swift
//  IOSTestCLOUD
//
//  Created by mac on 2/27/16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    override func viewDidLoad() {
        
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*************** DROP THE (FIRE) BASE ***********/
    
    // Create a reference to a Firebase location
    var myRootRef = Firebase(url:"https://radiant-heat-681.firebaseio.com/")
    
    
    @IBOutlet weak var arrayViewer: UITextView!
    
    @IBAction func updateButton(sender: AnyObject) {
        // Do any additional setup after loading the view, typically from a nib.
        myRootRef.observeEventType(.Value, withBlock: {
            snapshot in
            print("\(snapshot.key) -> \(snapshot.value)")
            self.arrayViewer.text=("\(snapshot.key) -> \(snapshot.value)")
        })
        
    }
    
    /*************** TAKE PHOTO TEST HERE **********/
    
    @IBOutlet var imageView: UIImageView!
    var imagePicker: UIImagePickerController!
    
    @IBAction func takePhoto(sender: AnyObject) {
        imagePicker =  UIImagePickerController()
        
        /*Because class inherits from UINavigationControllerDelegate, UIImagePickerControllerDelegate,
          we can say imagePicker.delegate = self 
        */
        
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    
}

