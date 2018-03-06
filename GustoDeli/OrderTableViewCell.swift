
//
//  OrderTableViewCell.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/18/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    //MARK:- IBOutlets
    @IBOutlet weak var mealPhoto: UIImageView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var numberOfOrderLabel: UILabel!
    @IBOutlet weak var priceTagIcon: UIImageView!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK:- Properties
    var numberOfOrder: Int!
    
    var order: Order? {
        didSet {
            updateUI()
        }
    }

    var meal: Meal? {
        didSet {
            updateUI()
        }
    }
    
    //MARK:- Private
    fileprivate func updateUI() {
        
        if let meal = meal {
            setInfo(meal)
        }
        
        if let order = order {
            if let orderId = order.orderId {
                orderIdLabel.text = "Order #\(orderId)"
            }
            
            //Fetch meal information from Firebase
            Helper().loadOrderedMeal(order, completion: { meal in
                self.setInfo(meal)
            })
        }
        self.addShadowToCell()
    }
    
    fileprivate func setInfo(_ meal: Meal) {
        mealPhoto.loadImageWithCacheWithUrlString(meal.mealPhotoUrl)
        mealPhoto.setBorder()
        mealNameLabel.text = meal.mealName
        priceLabel.text = "RM \(meal.getFormattedMealPrice())"
        if let status = order?.orderStatus.rawValue {
            statusLabel.text = "Status: \(status)"
        }
    }
}
