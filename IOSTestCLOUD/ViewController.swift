//
//  ViewController.swift
//  IOSTestCLOUD
//
//  Created by mac on 2/27/16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,
    reportScannedBarcodeDelegate {
    
    var json: Array<String>!


    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*************** DROP THE (FIRE) BASE **********
    
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

*/
    
    
    @IBOutlet weak var scannedBarcodeLabel: UILabel!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == "barcodeScannerSegue") {
            let scannerVC = segue.destinationViewController as! ScannerViewController
            scannerVC.barcodeDelegate = self
        }
    }
    
    func foundBarcode(code: String) {
        /* Write to the label the code found */
        scannedBarcodeLabel.text = code
        jsonParser(code)
    }
    
    /*
    func lookupBarcode(code: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.upcitemdb.com/prod/trial/lookup?upc=" + code)!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "GET"
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, err -> Void in
            
        })
        task.resume()
    }*/
    
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func jsonParser(code: String) {
        let urlPath = "https://api.upcitemdb.com/prod/trial/lookup?upc=" + code
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData }
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
                let items = json.objectForKey("items")!
                let title = items[0].objectForKey("title")
                print(title!)
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            }.resume()
    }

    
    
    
}

