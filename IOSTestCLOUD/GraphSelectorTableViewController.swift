//
//  GraphSelectorTableViewController.swift
//  IOSTestCLOUD
//
//  Created by Omar Skalli on 4/27/16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit


enum GraphType {
    case HelloWorld, Bars, StackedBars, BarsPlusMinus, GroupedBars, BarsStackedGrouped, Scatter, Areas, Bubble, Coords, Target, Multival, Notifications, Combination, Scroll, EqualSpacing, Tracker, MultiAxis, MultiAxisInteractive, CandleStick, Cubiclines, NotNumeric, CandleStickInteractive, CustomUnits, Trendline
}

class GraphSelectorTableViewController: UITableViewController {
    
    var detailViewController: GraphDetailViewController? = nil
    
    var analytics: [(GraphType, String)] = [
        (.HelloWorld, "Hello World"),
        (.Bars, "Bars"),
        (.StackedBars, "Stacked bars"),
        (.BarsPlusMinus, "+/- bars with dynamic gradient"),
        (.GroupedBars, "Grouped bars"),
        (.BarsStackedGrouped, "Stacked, grouped bars"),
        (.Combination, "+/- bars and line"),
        (.Scatter, "Scatter"),
        (.Notifications, "Notifications (interactive)"),
        (.Target, "Target point animation"),
        (.Areas, "Areas, lines, circles (interactive)"),
        (.Bubble, "Bubble, gradient bar mapping"),
        (.NotNumeric, "Not numeric values"),
        (.Scroll, "Multiline, Scroll"),
        (.Coords, "Show touch coords (interactive)"),
        (.Tracker, "Track touch (interactive)"),
        (.EqualSpacing, "Fixed axis spacing"),
        (.CustomUnits, "Custom units, rotated labels"),
        (.Multival, "Multiple axis labels"),
        (.MultiAxis, "Multiple axes"),
        (.MultiAxisInteractive, "Multiple axes (interactive)"),
        (.CandleStick, "Candlestick"),
        (.CandleStickInteractive, "Candlestick (interactive)"),
        (.Cubiclines, "Cubic lines"),
        (.Trendline, "Trendline")
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
            func showAnalytic(index: Int) {
                let analytic = self.analytics[index]
                let controller = segue.destinationViewController as! GraphDetailViewController
                controller.detailItem = analytic.0
                controller.title = analytic.1
                
            }
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                showAnalytic(indexPath.row)
            } else {
                showAnalytic(0)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let analytic = self.analytics[indexPath.row]
        self.detailViewController?.detailItem = analytic.0
        self.detailViewController?.title = analytic.1
        
        
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return analytics.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = analytics[indexPath.row].1
        return cell
    }
}

