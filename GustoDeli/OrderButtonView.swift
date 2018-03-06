//
//  OrderButtonView.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

protocol OrderButtonViewDelegate: class {
    func updateOrder(_ numberOfOrder: Int!, order: Order?)
}


class OrderButtonView: UIView {

    //MARK:- IBOutlets
    @IBOutlet weak var plusButton: CustomButton!
    @IBOutlet weak var minusButton: CustomButton!
    @IBOutlet weak var numberInCartLabel: UILabel!
    @IBOutlet weak var quantityBackView: UIView!
    @IBOutlet weak var addToCartButton: UIButton!
    
    //MARK:- Properties
    var orderButtonView: OrderButtonView?
    var orderButtonViewHidden = false
    
    weak var delegate: OrderButtonViewDelegate!
    var order: Order? {
        didSet {
            setupUI()
        }
    }
    
    var meal: Meal! {
        didSet {
            setupUI()
        }
    }
    
    override func awakeFromNib() {
        frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 70, width: UIScreen.main.bounds.width, height: 70)
    }
    
    //MARK:- Private
    fileprivate func setupUI() {
        print("setupUI OrderButtonView")
        quantityBackView.layer.cornerRadius = 10.0
        addToCartButton.layer.cornerRadius = 10.0
        
        if let numOfOrder = order?.numberOfOrder {
            print("numOfOrder: \(numOfOrder)")
            numberInCartLabel.text = "\(numOfOrder)"
        }
    }
    
    func handleOrderButtonView(_ hide: Bool?, currentController: UIViewController!) {
        if let controller = currentController as? GustoViewController {
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
                if hide! {
                    self.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: 70)
                } else {
                    self.frame = CGRect(x: 0, y: screenHeight - 70, width: screenWidth, height: 70)
                }
            }, completion: { finished in
                if hide! {
                    controller.orderButtonViewHidden = true
                } else {
                    controller.orderButtonViewHidden = false
                }
            })
        }
    }
    
    fileprivate func handleOrderTextField(_ orderIncrease: Bool) {
        if let currentOrder = Int(numberInCartLabel.text!) {
            if orderIncrease {
                numberInCartLabel.text = "\(currentOrder + 1)"
            } else if currentOrder != 0 {
                numberInCartLabel.text = "\(currentOrder - 1)"
            }
        }
    }
    
    //MARK:- Action
    @IBAction func didTappedAddToCartButton(_ sender: UIButton) {
        if let currentOrder = Int(numberInCartLabel.text!) {
            if delegate != nil {
                delegate.updateOrder(currentOrder, order: order)
            }
        }
    }
    
    @IBAction func didTappedAddButton(_ sender: UIButton) {
        handleOrderTextField(true)
    }
    
    @IBAction func didTappedMinusButton(_ sender: UIButton) {
        handleOrderTextField(false)
    }

}
