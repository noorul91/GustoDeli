//
//  TabSegmentedControl.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class TabSegmentedControl: UISegmentedControl {

    func initUI() {
        setupBackground()
        setupFonts()
    }
    
    //MARK:- Private
    fileprivate func setupBackground() {
        let unselectedBackgroundImage = UIImage(named: "segment_unselected")
        let dividerImage = UIImage(named: "segment_separator")
        let selectedBackgroundImage = UIImage(named: "segment_selected")
        
        self.setBackgroundImage(unselectedBackgroundImage, for: UIControlState(), barMetrics: .default)
        self.setBackgroundImage(selectedBackgroundImage, for: .highlighted, barMetrics: .default)
        self.setBackgroundImage(selectedBackgroundImage, for: .selected, barMetrics: .default)
        
        self.setDividerImage(dividerImage, forLeftSegmentState: UIControlState(), rightSegmentState: .selected, barMetrics: .default)
        self.setDividerImage(dividerImage, forLeftSegmentState: .selected, rightSegmentState: UIControlState(), barMetrics: .default)
        self.setDividerImage(dividerImage, forLeftSegmentState: UIControlState(), rightSegmentState: UIControlState(), barMetrics: .default)
    }
    
    fileprivate func setupFonts() {
        let font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        let normalTextAttributes = [
            NSForegroundColorAttributeName: UIColor().hexStringToUIColor(hexString: "#A1AFBD", alpha: 1.0),
            NSFontAttributeName: font
        ]
        
        let highlightedTextAttributes = [
            NSForegroundColorAttributeName: UIColor().themeColor(),
            NSFontAttributeName: font
        ]
        self.setTitleTextAttributes(normalTextAttributes, for: UIControlState())
        self.setTitleTextAttributes(normalTextAttributes, for: .highlighted)
        self.setTitleTextAttributes(highlightedTextAttributes, for: .selected)

    }
}
