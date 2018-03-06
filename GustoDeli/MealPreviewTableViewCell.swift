//
//  MealPreviewTableViewCell.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class MealPreviewTableViewCell: UITableViewCell {

    //MARK:- IBOutlets
    @IBOutlet weak var mealPhoto: UIImageView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var cookPhoto: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceTagIcon: UIImageView!
    @IBOutlet weak var cookNameLabel: UILabel!
    
    
    //MARK:- Properties
    var meal: Meal! {
        didSet {
            updateUI()
        }
    }
    let userRef = FIRDatabase.database().reference(withPath: "Users")
    
    fileprivate func updateUI() {
        priceTagIcon.addShadowToPriceTag()
        let view = UIView(frame: mealPhoto.frame)
        let layer = CAGradientLayer()
        layer.frame = view.frame
        layer.colors = [UIColor.lightGray, UIColor.white]
        layer.locations = [0.0, 1.0]
        view.layer.insertSublayer(layer, at: 0)
        mealPhoto.addSubview(view)
        mealPhoto.bringSubview(toFront: view)
        
        mealPhoto.loadImageWithCacheWithUrlString(meal.mealPhotoUrl)
        mealNameLabel.text = meal.mealName
    
        if meal.cook != nil {
            cookPhoto.loadImageWithCacheWithUrlString(meal.cook.userPhoto)
            if let name = meal.cook.userName {
                cookNameLabel.text = "By \(name)"
            }
        }
        cookPhoto.setRoundedBorder()
        cookPhoto.setBorderWidthColor(2.0, borderColor: .white)
        
        if let formattedPrice = meal?.getFormattedMealPrice() {
            priceLabel.text = "RM \(formattedPrice)"
        }
    }
}
