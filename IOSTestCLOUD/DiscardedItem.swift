//
//  DiscardedItem.swift
//  IOSTestCLOUD
//
//  Created by Omar Skalli on 4/28/16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation
import Firebase

struct DiscardedItem {
    
    let key: String!
    var UPC:String!
    let speech: String!
    var resolved: String!
    var timeStamp: String!
    let ref: Firebase?
    
    // Initialize from arbitrary data
    init(UPC: String, speech: String, resolved: String, timeStamp: String, key: String = "") {
        self.key = key
        self.UPC = UPC
        self.speech = speech
        self.resolved = resolved
        self.timeStamp = timeStamp
        self.ref = nil
    }
    
    init(snapshot: FDataSnapshot) {
        key = snapshot.key
        UPC = snapshot.value["UPC"] as? String
        speech = snapshot.value["speech"] as? String
        resolved = snapshot.value["resolved"] as? String
        timeStamp = snapshot.value["timeStamp"] as? String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "UPC": UPC,
            "speech": speech,
            "resolved": resolved,
            "timeStamp": timeStamp
        ]
    }
}