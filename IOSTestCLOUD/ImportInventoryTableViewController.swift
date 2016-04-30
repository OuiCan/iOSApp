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
    var discardList = [DiscardedItem]()
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
        
        //Discard items from discard list
        throwItemsFromDiscardList()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
    var userRef = Firebase(url:"https://ouican.firebaseio.com/Ouican%20Users/oskalli")
    
    
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
        
        let inventoryRef = userRef.childByAppendingPath("inventory")
        let inventoryItemRef = inventoryRef.childByAppendingPath(code)
        
        inventoryItemRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            
            if !snapshot.exists(){
                let inventoryItem = InventoryItem(title: title, UPC: code, quantity: 1, expired: false, thrownOut:0, key: "")
                //print("Saving", 1, " item with upc: ", code)
                inventoryItemRef.setValue(inventoryItem.toAnyObject())
            }
            
            else {
                var quantity = snapshot.value["quantity"] as? Int
                quantity = quantity! + 1
                let thrownOut = (snapshot.value["thrownOut"]) as? Int
                let inventoryItem = InventoryItem(title: title, UPC: code, quantity: quantity!, expired: false, thrownOut: thrownOut!, key: "")
                //print("Saving", String(quantity), " item with upc: ", code)
                inventoryItemRef.setValue(inventoryItem.toAnyObject())
                
            }
        })

    }
    
    /*
        Pull discard list from server. 
        Only add to local discarded list if not status is not resolved ("no")
    */
    
    func retrieveDiscardList(){
        
        let discardedRef = self.userRef.childByAppendingPath("Discard Pending")
         discardedRef.observeEventType(.Value, withBlock: { snapshot in
            
            var newDiscardedItems = [DiscardedItem]()
            
            for item in snapshot.children {
                
                let discardedItem = DiscardedItem(snapshot: item as! FDataSnapshot)
                
                let resolvedStatus = discardedItem.resolved
                
                if resolvedStatus == "no" {
                    newDiscardedItems.append(discardedItem)
                }
            }
            self.discardList = newDiscardedItems
        })
    }
    
    /*
        Decrease quantity and increase thrownOut properties on the server
    */
    
    func decrementQuantity(inventoryItemRef: Firebase!) {
        
        
        inventoryItemRef.observeEventType(.Value, withBlock: { snapshot in
            
            //  DOUBLE CHECK THIS
            let inventoryItem = InventoryItem(snapshot: snapshot.value as! FDataSnapshot)
            
            //Update quantity - 1 and thrownOut++
            
            let quantity = inventoryItem.quantity
            let thrownOut = inventoryItem.thrownOut
            
            var newQuantity = quantity
            var newThrownOut = thrownOut
        
            if quantity <= 0 {
                newQuantity = 0
            }
        
            else {
                newQuantity = quantity - 1
                newThrownOut = thrownOut + 1
            }
        
            //let newInventoryItem = InventoryItem(title: title, UPC: code, quantity: newQuantity, expired: false, thrownOut: newThrownOut, key: "")
            let inventoryItemQuantityRef = inventoryItemRef.childByAppendingPath("quantity")
            inventoryItemQuantityRef.setValue(newQuantity)
            
            let inventoryItemThrownOutRef = inventoryItemRef.childByAppendingPath("thrownOut")
            inventoryItemThrownOutRef.setValue(newThrownOut)
            
        })
    }
    
    
    
    /*
        Find the items that the discarded item matches with in the inventory List
    
        //Should this loop through a server query?
    */
    
    func findConflicts(discardedItem: DiscardedItem) -> [String]{
        
        let discardedItemUPC = discardedItem.UPC
        let speech = discardedItem.speech
        var matches = [String]()
        
        for inventoryItem in inventory {
                
            let inventoryItemUPC = inventoryItem.UPC
            let title = inventoryItem.title
                
            if  (discardedItemUPC == inventoryItemUPC) || ((title.lowercaseString.rangeOfString(speech)) != nil) {
                matches.append(inventoryItemUPC)
            }
        }
        
        return matches
    }
    
    /*
        1-
        2- Count how many matches of a single discarded item exist with an inventory item, either with UPC or speech
        3- Set resolved status in discarded item based on result
    */
    
    func throwItemsFromDiscardList(){
        
        let discardedListRef = userRef.childByAppendingPath("Discard Pending")
        discardedListRef.observeEventType(.Value, withBlock: { snapshot in

            for item in snapshot.children {

                //item could be nil?
                let discardedItem = DiscardedItem(snapshot: item as! FDataSnapshot)
                
                let timeStamp = discardedItem.timeStamp
                
                let discardedItemRef = discardedListRef.childByAppendingPath(timeStamp)
                
                let resolvedStatus = discardedItemRef.valueForKey("Resolved") as? String
                let resolvedStatusRef = discardedItemRef.childByAppendingPath("Resolved")

                if (resolvedStatus == "no") {
                    
                    let foundMatches = self.findConflicts(discardedItem)
                    let countMatches = foundMatches.count
                    
                    if countMatches == 0 {
                        resolvedStatusRef.setValue("not found")
                        
                        let speech = discardedItem.speech
                        let discardedItemUPC = discardedItem.UPC
                        let message = "Speech = " + speech + "\nUPC = " + discardedItemUPC
                        
                        let alertController = UIAlertController(title: "Thrown trash not found in inventory. Please manually remove item.", message:
                            message, preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                    else if countMatches == 1 {
                        resolvedStatusRef.setValue("resolved")
                    
                        let matchedItemUPC = foundMatches[0]
                        let inventoryItemRef = self.userRef.childByAppendingPath("inventory/" + matchedItemUPC)
                        self.decrementQuantity(inventoryItemRef)
                    }
            
                    else {
                        resolvedStatusRef.setValue("conflict")
                        let speech = discardedItem.speech
                        let discardedItemUPC = discardedItem.UPC
                        let message = "Speech = " + speech + "   \nUPC = " + discardedItemUPC
                        
                        ///CONFLICT
                        let alertController = UIAlertController(title: String(countMatches) + " inventory items match.", message:
                            message, preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    /**************** Populate table ***********/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!

        let inventoryItem = inventory[indexPath.row]
        cell.textLabel?.text = inventoryItem.title
        cell.detailTextLabel?.text = inventoryItem.UPC + "    Quantity: " + String(inventoryItem.quantity) + "    Thrown Out: " + String(inventoryItem.thrownOut)
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
                
                let productInfo = json.objectForKey("0")
                if (productInfo != nil) {
                    let title = productInfo!.objectForKey("productname")
                    
                    if (title != nil && (title as! String) != " ") {
                            
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
