//
//  ViewController.swift
//  IOSTestCLOUD
//
//  Created by mac on 2/27/16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,
    reportScannedBarcodeDelegate {
    
    var json: Array<String>!
    var inventoryArray: [String] = []


    override func viewDidLoad() {
        
        super.viewDidLoad()
        //Pull Inventory from FireBase Here
        
        tableView.reloadData()
        self.refreshControl?.addTarget(self, action: "refreshChannels:", forControlEvents: UIControlEvents.ValueChanged)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**************** Populate table ***********/
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        cell.textLabel?.text = inventoryArray[indexPath.row]
        return cell
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inventoryArray.count
    }
    
    func refreshInventory(refreshControl: UIRefreshControl) {
        //Pull new channel list from parse
        print("Pulling new channel list")
        //ParseInterface.pullParseChannel(self)
        
        print(inventoryArray)
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
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
    
    /**************** Parse JSON ******************/
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func jsonParser(code: String) {
        let urlPath = "https://api.upcitemdb.com/prod/trial/lookup?upc=" + code
        guard let endpoint = NSURL(string: urlPath) else {
            print("Error creating endpoint");
            return
        }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData }
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
                
                let total = json.objectForKey("total")
                if (total != nil && (total as! Int) > 0) {
                    print("found total")
                    let items = json.objectForKey("items")
                    print(items)
                    if (items != nil) {
                        print("found items")
                        let title = items![0].objectForKey("title")
                        if (title != nil) {
                            print(title!)
                        } else {
                            // UPC has no title
                            print("No title found for given UPC %s", code)
                        }
                    }
                } else {
                    // Nothing was found
                    print("Nothing was found")
                }
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            }.resume()
    }

    
    
    
    
}

