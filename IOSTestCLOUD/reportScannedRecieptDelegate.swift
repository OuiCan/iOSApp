//
//  reportScannedRecieptDelegate.swift
//  IOSTestCLOUD
//
//  Created by Omar Skalli on 4/13/16.
//  Copyright © 2016 mac. All rights reserved.
//

import Foundation

protocol reportScannedRecieptDelegate {
    func uploadReceipt(UPCArray: [String])
}