//
//  ShoppingCartTableViewCell.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class ShoppingCartTableViewCell: UITableViewCell {

    //MARK:- IBOutlet
    @IBOutlet weak var mealPhoto: UIImageView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var numberOfOrderLabel: UILabel!
    @IBOutlet weak var cookNameLabel: UILabel!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    @IBOutlet weak var subTotalPriceLabel: UILabel!
    @IBOutlet weak var checkboxButton: UIButton!

    var orderedMeal: Order! {
        didSet {
            setupUI()
        }
    }

    //MARK:- Private
    fileprivate func setupUI() {
        //mealPhoto.image = orderedMeal.meal.mealPhoto
        mealPhoto.setBorder()
        //mealNameLabel.text = orderedMeal.meal.mealName
        if let numberOfOrder = orderedMeal.numberOfOrder {
            numberOfOrderLabel.text = "\(numberOfOrder) x set"
        }
        //if let username = orderedMeal.meal.cook.userName {
          //  cookNameLabel.text = "Cook: \(username)"
        //}
        
        let origImage = UIImage(named: "Checkbox unselected")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        checkboxButton.setImage(tintedImage, for: .normal)
        checkboxButton.tintColor = .lightGray
        /**
        if let deliveryDate = orderedMeal.meal.deliveryDate {
            deliveryDateLabel.text = "\(deliveryDate)"
        }**/
    }
}
