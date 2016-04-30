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

    static var inventory = [InventoryItem]()
    static var discardList = [DiscardedItem]()
    static var lastThrownOut = InventoryItem(title: "", UPC: "", quantity: 0, expired: false, thrownOut: 0)
    
    // Create a reference to a Firebase location
    var myRootRef = Firebase(url:"https://radiant-heat-681.firebaseio.com/")
    
    //User Specific --- OSKALLI
    static var userRef = Firebase(url:"https://ouican.firebaseio.com/Ouican%20Users/oskalli")
    
    
    static func retrieveInventory(){
        
        let inventoryRef = self.userRef.childByAppendingPath("inventory")
        inventoryRef.observeEventType(.Value, withBlock: { snapshot in
            
            var newInventoryItems = [InventoryItem]()
            
            for item in snapshot.children {
                
                let inventoryItem = InventoryItem(snapshot: item as! FDataSnapshot)
                newInventoryItems.append(inventoryItem)
            }
            FirebaseInterface.inventory = newInventoryItems
        })
    }
    
    
    static func saveItemToInventory(title: String ,code: String){
        
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
    
    static func retrieveDiscardList(){
        
        let discardedRef = userRef.childByAppendingPath("Discard Pending")
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
        Update lastThrownOut item
    */
    
    static func decrementQuantity(matchedItemUPC: String) {
        
        let inventoryItemRef = userRef.childByAppendingPath("inventory/" + matchedItemUPC)
        
        inventoryItemRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            let inventoryItem = InventoryItem(snapshot: snapshot)
            
            //Update last item thrown out
            
            self.lastThrownOut = inventoryItem
            
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
            
            let inventoryItemQuantityRef = inventoryItemRef.childByAppendingPath("quantity")
            inventoryItemQuantityRef.setValue(newQuantity)
            
            let inventoryItemThrownOutRef = inventoryItemRef.childByAppendingPath("thrownOut")
            inventoryItemThrownOutRef.setValue(newThrownOut)
            
        })
    }
    
    /*
        Compensate for missing checkbit of a 12 digit UPC
    */
    static func addCheckbit(upc: String) -> String{
        
        let upcIntArray = upc.characters.flatMap{Int(String($0))}
        var checkSum = 0
        
        let inventoryItemUPCDigits = upcIntArray.count
        
        if (inventoryItemUPCDigits == 12) {
            
            for index in 0...(upcIntArray.count-1) {
                let digit = upcIntArray[index]
                
                if index%2 == 0 {
                    checkSum = checkSum + digit
                }
                else{
                    checkSum = checkSum + (3*digit)
                }
            }
            
            let checkDigit = String((10 - (checkSum%10))%10)
            
            return upc + checkDigit
        }
            
        else {
            return upc
        }
    }
    
    /*
    Find the items that the discarded item matches with in the inventory List
    Note UPCs must have a check bit so they match with the inventory.
    If UPC is 12 bit in length, the check bit needes to be added.
    */
    
    static func findConflicts(discardedItem: DiscardedItem) -> [String]{
        
        let discardedItemUPC = discardedItem.UPC
        let speech = discardedItem.speech
        var matches = [String]()
        
        for inventoryItem in inventory {
            
            let inventoryItemUPC = inventoryItem.UPC
            let title = inventoryItem.title
            
            //Add checkbit to stay consistent
            let correctedDiscardedUPC = addCheckbit(discardedItemUPC)
            let correctedInventoryUPC = addCheckbit(inventoryItemUPC)
            
            if  (correctedDiscardedUPC == correctedInventoryUPC) || ((title.lowercaseString.rangeOfString(speech)) != nil) {
                matches.append(inventoryItemUPC)
            }
        }
        
        return matches
    }
    
    
    /*
        Use to pop up alert for "not found" and "conflict" cases
    */
    static func displayTheAlert(targetVC: UIViewController, title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: {(action) -> Void in
        })))
        targetVC.presentViewController(alert, animated: true, completion: nil)
    }
    

    /*
        1-
        2- Count how many matches of a single discarded item exist with an inventory item, either with UPC or speech
        3- Set resolved status in discarded item based on result
    */
    
    static func throwItemsFromDiscardList(targetVC: UIViewController){
        
        let discardedListRef = userRef.childByAppendingPath("Discard Pending")
        discardedListRef.observeEventType(.Value, withBlock: { snapshot in
            
            for item in snapshot.children {
                
                //item could be nil?
                let discardedItem = DiscardedItem(snapshot: item as! FDataSnapshot)
                
                let timeStamp = discardedItem.timeStamp
                
                let discardedItemRef = discardedListRef.childByAppendingPath(timeStamp)
                let resolvedStatusRef = discardedItemRef.childByAppendingPath("resolved")
                let resolvedStatus = discardedItem.resolved
                
                if (resolvedStatus == "no") {
                    
                    let foundMatches = self.findConflicts(discardedItem)
                    let countMatches = foundMatches.count
                    
                    if countMatches == 0 {
                        resolvedStatusRef.setValue("not found")
                        
                        let speech = discardedItem.speech
                        let discardedItemUPC = discardedItem.UPC
                        
                        let title =  "Thrown trash not found in inventory. Please manually remove item."
                        let message = "Speech = " + speech + "\nUPC = " + discardedItemUPC
                        
                        self.displayTheAlert(targetVC, title: title, message: message)
                        
                    }
                        
                    else if countMatches == 1 {
                        resolvedStatusRef.setValue("resolved")
                        
                        let speech = discardedItem.speech
                        let matchedItemUPC = foundMatches[0]
                        self.decrementQuantity(matchedItemUPC)
                        let quantityRemaining = self.lastThrownOut.quantity
                        
                        let title = "Thrown trash found and removed successfully."
                    
                        let message = "Quantity Remaining = " + String(quantityRemaining) + "\nSpeech = " + speech + "\nUPC = " + matchedItemUPC
                        
                        self.displayTheAlert(targetVC, title: title, message: message)
                    }
                        
                    else {
                        resolvedStatusRef.setValue("conflict")
                        let speech = discardedItem.speech
                        let discardedItemUPC = discardedItem.UPC
                        
                        let title = String(countMatches) + " inventory items match.\n Please resolve conflict manually."
                        let message = "Speech = " + speech + "   \nUPC = " + discardedItemUPC
                        
                        self.displayTheAlert(targetVC, title: title, message: message)
                    }
                }
            }
        })
    }
    
    
    
    
    
}