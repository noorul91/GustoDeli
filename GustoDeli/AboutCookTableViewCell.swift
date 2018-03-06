//
//  AboutCookTableViewCell.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/18/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class AboutCookTableViewCell: UITableViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet weak var cookPhoto: UIImageView!
    @IBOutlet weak var cookNameButton: UIButton!
    @IBOutlet weak var firstTimeSellerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var cookDescriptionLabel: UILabel!
    @IBOutlet weak var reportCookButton: UIButton!
    
    //MARK:- Properties
    var setAttributedTitle: Bool!
    
    var cook: User! {
        didSet {
            updateUI()
        }
    }
    
    fileprivate func updateUI() {
        cookPhoto.loadImageWithCacheWithUrlString(cook.userPhoto)
        cookPhoto.setRoundedBorder()
        cookPhoto.putShadowOnView()
        
        if setAttributedTitle {
            let attributes = [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 17)!,
                              NSForegroundColorAttributeName: UIColor().themeColor(),
                              NSUnderlineStyleAttributeName: 1] as [String : Any]
            let attributedString = NSMutableAttributedString(string: "")
            let buttonTitleStr = NSMutableAttributedString(string: cook.userName, attributes: attributes)
            attributedString.append(buttonTitleStr)
            cookNameButton.setAttributedTitle(attributedString, for: .normal)
        } else {
            cookNameButton.setTitle(cook.userName, for: UIControlState())
        }
        
        if locationLabel != nil {
            locationLabel.text = cook.userLocation! + " area"
        }
        if cookDescriptionLabel != nil {
            cookDescriptionLabel.text = cook.userDescription
        }
        
        if firstTimeSellerLabel != nil {
            if cook.listing.count > 1 {
                firstTimeSellerLabel.isHidden = true
            }
        }
        if reportCookButton != nil {
            reportCookButton.setBorderWidthColor(2.0, borderColor: .red, cornerRadius: 8)
        }
    }
}
