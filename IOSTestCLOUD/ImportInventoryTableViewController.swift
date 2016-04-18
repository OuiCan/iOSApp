//
//  ImportInventoryTableViewController.swift
//  IOSTestCLOUD
//
//  Created by Omar Skalli on 3/27/16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit
import Firebase

class ImportInventoryTableViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, reportScannedBarcodeDelegate, reportScannedRecieptDelegate {
    
    var json: Array<String>!
    var inventory = [InventoryItem]()
    var user: User!
    var activityIndicator:UIActivityIndicatorView!

    
    @IBOutlet weak var InventoryList: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Change color of navigation view controller
        //navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        
        // Set up swipe to delete
        InventoryList.allowsMultipleSelectionDuringEditing = false
        
        //Setup UITableView
        InventoryList.delegate = self
        InventoryList.dataSource = self
        
        //Pull Existing Inventory from FireBase Here
        retrieveInventory()
        
        InventoryList.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        userRef.observeEventType(.Value, withBlock: { snapshot in
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Activity Indicator methods
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    
    /*************** Firebase ******************/
     
    //User Specific --- OSKALLI
    var userRef = Firebase(url:"https://radiant-heat-681.firebaseio.com/OuiCan%20Users/oskalli")
    
    
    func retrieveInventory(){
        
        let inventoryRef = self.userRef.childByAppendingPath("inventory")
        inventoryRef.observeEventType(.Value, withBlock: { snapshot in

            var newInventoryItems = [InventoryItem]()
            
            for item in snapshot.children {
        
                let inventoryItem = InventoryItem(snapshot: item as! FDataSnapshot)
                newInventoryItems.append(inventoryItem)
            }
            self.inventory = newInventoryItems
            self.InventoryList.reloadData()
        })
       
    }
    
    func saveItemToInventory(title: String ,code: String){
        
        let inventoryItem = InventoryItem(title: title, UPC: code, expired: false, key: "")
                
        let inventoryRef = userRef.childByAppendingPath("inventory")

        let inventoryItemRef = inventoryRef.childByAppendingPath(code)
                
        inventoryItemRef.setValue(inventoryItem.toAnyObject())
    }

    
    
    /**************** Populate table ***********/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!

        let inventoryItem = inventory[indexPath.row]
        cell.textLabel?.text = inventoryItem.title
        cell.detailTextLabel?.text = inventoryItem.UPC
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inventory.count
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let inventoryItem = inventory[indexPath.row]
            inventoryItem.ref?.removeValue()
        }
    }
    
    
    
    /**************** Scan Barcode or Reciept ***********/
    
    @IBOutlet weak var scannedBarcodeLabel: UILabel!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "barcodeScannerSegue") {
            let scannerVC = segue.destinationViewController as! ScannerViewController
            scannerVC.barcodeDelegate = self
        }
        
        if (segue.identifier == "uploadRecieptSegue"){
            let scannerVC = segue.destinationViewController as! TesseractViewController
            scannerVC.recieptDelegate = self
        }
    }
    
    
    func foundBarcode(code: String) {
        /* Write to the label the code found */
        jsonParser(code)
    }
    
    func uploadReceipt(UPCArray: [String]) {
        addActivityIndicator()
        for code in UPCArray {
            jsonParser(code)
        }
        removeActivityIndicator()
    }
    
    
    /**************** Parse JSON ******************/
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func jsonParser(code: String) {
        let urlPath = "http://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=C81A66CF-E26F-4674-B350-9A1528661672&upc=" + code
        guard let endpoint = NSURL(string: urlPath) else {
            print("Error creating endpoint");
            return
        }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData }
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
                
                print(response)
                print(error)
                
                let productInfo = json.objectForKey("0")
                if (productInfo != nil) {
                    let title = productInfo!.objectForKey("productname")
                    print(title)
                    
                    if (title != nil && (title as! String) != " ") {
                            
                            print("Saving to inventory:" + code)
                            self.saveItemToInventory(title as! String, code: code)
                            
                            self.InventoryList.reloadData()
                            
                        } else {
                            // UPC has no title
                            print("No title found for given UPC: ", code)
                        }
                    
                } else {
                    // Nothing was found
                    print("Nothing was found")
                }
                
            }
            catch let error as JSONError {
                print(error.rawValue)
                }
            catch {
                print(error)
                }
            }.resume()
    }
    
    
    
    
    
}
