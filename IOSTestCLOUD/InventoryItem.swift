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
    let UPC: String!
    let ref: Firebase?
    var expired: Bool!
    
    // Initialize from arbitrary data
    init(title: String, UPC: String, expired: Bool, key: String = "") {
        self.key = key
        self.title = title
        self.UPC = UPC
        self.expired = expired
        self.ref = nil
    }
    
    init(snapshot: FDataSnapshot) {
        key = snapshot.key
        title = snapshot.value["title"] as! String
        UPC = snapshot.value["UPC"] as! String
        expired = snapshot.value["expired"] as! Bool
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "title": title,
            "UPC": UPC,
            "expired": expired
        ]
    }
    
}