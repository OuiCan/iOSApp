//
//  GraphDetailViewController.swift
//  IOSTestCLOUD
//
//  Created by Omar Skalli on 4/27/16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class GraphDetailViewController: UIViewController, UISplitViewControllerDelegate {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    lazy var chartFrame: CGRect! = {
        CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 80)
    }()
    
    var detailItem: GraphType? {
        didSet {
            self.configureView()
        }
    }
    var currentExampleController: UIViewController?
    
    func configureView() {
        
        if let graphType: GraphType = self.detailItem  {
            switch graphType {
            case .Bars:
                self.showExampleController(BarsExample())
            case .StackedBars:
                self.showExampleController(StackedBarsExample())
            case .BarsPlusMinus:
                self.showExampleController(BarsPlusMinusWithGradientExample())
            case .GroupedBars:
                self.showExampleController(GroupedBarsExample())
            case .BarsStackedGrouped:
                self.showExampleController(GroupedAndStackedBarsExample())
            case .Scatter:
                self.showExampleController(ScatterExample())
            case .Notifications:
                self.showExampleController(NotificationsExample())
            case .Target:
                self.showExampleController(TargetExample())
            case .Areas:
                self.showExampleController(AreasExample())
            case .Bubble:
                self.showExampleController(BubbleExample())
            case .Combination:
                self.showExampleController(BarsPlusMinusAndLinesExample())
            case .Scroll:
                self.automaticallyAdjustsScrollViewInsets = false
                self.showExampleController(ScrollExample())
            case .Coords:
                self.showExampleController(CoordsExample())
            case .Tracker:
                self.showExampleController(TrackerExample())
            case .EqualSpacing:
                self.showExampleController(EqualSpacingExample())
            case .CustomUnits:
                self.showExampleController(CustomUnitsExample())
            case .Multival:
                self.showExampleController(MultipleLabelsExample())
            case .MultiAxis:
                self.showExampleController(MultipleAxesExample())
            case .MultiAxisInteractive:
                self.showExampleController(MultipleAxesInteractiveExample())
            case .CandleStick:
                self.showExampleController(CandleStickExample())
            case .Cubiclines:
                self.showExampleController(CubicLinesExample())
            case .itemsConsumed:
                self.showExampleController(NotNumericExample())
            case .CandleStickInteractive:
                self.showExampleController(CandleStickInteractiveExample())
            case .Trendline:
                self.showExampleController(TrendlineExample())
            }
        }
    }
    
    private func showExampleController(controller: UIViewController) {
        if let currentExampleController = self.currentExampleController {
            currentExampleController.removeFromParentViewController()
            currentExampleController.view.removeFromSuperview()
        }
        self.addChildViewController(controller)
        self.view.addSubview(controller.view)
        self.currentExampleController = controller
    }
    
}

