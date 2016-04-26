//
//  InventoryItem.swift
//  IOSTestCLOUD
//
//  Created by Omar Skalli on 3/28/16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation
import Firebase

struct InventoryItem {
    
    let key: String!
    let title: String!
    var quantity: Int!
    let UPC: String!
    let ref: Firebase?
    var expired: Bool!
    var thrownOut: Int!
    
    // Initialize from arbitrary data
    init(title: String, UPC: String, quantity: Int, expired: Bool, thrownOut: Int, key: String = "") {
        self.key = key
        self.title = title
        self.UPC = UPC
        self.quantity = quantity
        self.expired = expired
        self.thrownOut = thrownOut
        
        self.ref = nil
    }
    
    init(snapshot: FDataSnapshot) {
        key = snapshot.key
        title = snapshot.value["title"] as! String
        UPC = snapshot.value["UPC"] as! String
        quantity = snapshot.value["quantity"] as! Int
        expired = snapshot.value["expired"] as! Bool
        thrownOut = snapshot.value["thrownOut"] as! Int
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "title": title,
            "UPC": UPC,
            "quantity": quantity,
            "expired": expired,
            "thrownOut": thrownOut
        ]
    }
    
}