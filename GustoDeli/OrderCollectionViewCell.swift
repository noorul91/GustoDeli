//
//  OrderCollectionViewCell.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

protocol OrderCollectionViewCellDelegate: class {
    func selectTimeRange(_ order: Order!, selectedTimeRange: String!)
    func updatedOrderCount(_ order: Order!, orderCount: Int!, orderIncrease: Bool)
}

class OrderCollectionViewCell: UICollectionViewCell, DeliveryTimeViewDelegate {
    //MARK: IBOutlets
    @IBOutlet weak var mealPhoto: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var mealPrice: UILabel!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    @IBOutlet weak var addButton: CustomButton!
    @IBOutlet weak var minusButton: CustomButton!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var deliveryTimeButton: UIButton!
    @IBOutlet weak var orderCountLabel: UILabel!
    @IBOutlet weak var timeRangeLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var priceIconImage: UIImageView!
    @IBOutlet weak var closeButtonBackgroundView: UIVisualEffectView!
    
    //MARK:- Properties
    var source: UIViewController!
    weak var delegate: OrderCollectionViewCellDelegate!
    var array = [String]()
    var deliveryTimeView: DeliveryTimeView?
    
    var order: Order! {
        didSet {
            updateUI()
        }
    }
    
    //MARK:- Action
    @IBAction func didTappedAddButton() {
        handleOrderTextField(true)
    }
    
    @IBAction func didTappedMinusButton() {
        handleOrderTextField(false)
    }
    
    @IBAction func didTappedDeliveryTimeButton() {
        if deliveryTimeView == nil {
            addMenu()
        } else {
            deliveryTimeView?.alpha = 1.0
        }
    }
    
    //MARK:- DeliveryTimeViewDelegate
    func timeWasSelected(_ selectedTime: String) {
        deliveryTimeButton.setTitle(selectedTime, for: .normal)
        if delegate != nil {
            delegate.selectTimeRange(order, selectedTimeRange: selectedTime)
        }
        deliveryTimeView?.alpha = 0.0
    }
    
    func cancelButtonTapped() {
        deliveryTimeView?.alpha = 0.0
    }
    
    //MARK:- Private
    fileprivate func updateUI() {
        self.addShadowToCell()
        priceIconImage.addShadowToPriceTag()
        
        Helper().setMealPhoto(mealPhoto, mealId: order.mealId)
        mealPhoto.setBorder()
        
        Helper().loadOrderedMeal(order, completion: { meal in
            self.mealName.text = meal.mealName
            self.mealPrice.text = "RM \(meal.getFormattedMealPrice())"
            self.deliveryDateLabel.text = meal.deliveryDate
        })
        
        if (source as? ShoppingCartViewController) != nil {
            //createArrayForDeliveryTimeRange()
            Helper().createArrayForDeliveryTimeRange(order, completionForArray: { array in
                if array.count == 1 {
                    self.deliveryTimeButton.setTitle(array[0], for: UIControlState())
                    self.deliveryTimeButton.isUserInteractionEnabled = false
                    if self.delegate != nil {
                        self.delegate.selectTimeRange(self.order, selectedTimeRange: array[0])
                    }
                    self.closeButtonBackgroundView.setRoundedBorder()
                    self.deliveryTimeButton.setBorderWidthColor(2.0, borderColor: UIColor().themeColor(), cornerRadius: 10)
                    
                    if let numberOfOrder = self.order.numberOfOrder {
                        self.quantityTextField.text = "\(numberOfOrder)"
                    }
                    if self.order.deliveryTime != "" {
                        self.deliveryTimeButton.setTitle(self.order.deliveryTime, for: .normal)
                    }
                }
            })
            
            
            
        } else if (source as? CheckoutViewController) != nil {
            if let numberOfOrder = order.numberOfOrder {
                orderCountLabel.text = "\(numberOfOrder) x set"
            }
            timeRangeLabel.text = order.deliveryTime
        }
    }
    
    fileprivate func handleOrderTextField(_ increase: Bool) {
        let currentOrderArr = quantityTextField.text?.components(separatedBy: " ")
        if let currentOrder = Int(Array(currentOrderArr!)[0]) {
            if increase {
                quantityTextField.text = "\(currentOrder + 1)"
            } else if currentOrder != 1 {
                quantityTextField.text = "\(currentOrder - 1)"
            }
            if delegate != nil {
                if increase {
                    delegate.updatedOrderCount(order, orderCount: Int(quantityTextField.text!), orderIncrease: true)
                } else {
                    delegate.updatedOrderCount(order, orderCount: Int(quantityTextField.text!)! * -1, orderIncrease: false)
                }

            }
        }
    }
    
    fileprivate func addMenu() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let deliveryView = Bundle.main.loadNibNamed("DeliveryTimeView", owner: self, options: nil)?[0] as! DeliveryTimeView
        deliveryView.selectedDate = order.deliveryTime!
        deliveryView.pickerDataSource = array
        deliveryView.delegate = self
        appDelegate.window?.addSubview(deliveryView)
        deliveryTimeView = deliveryView
        deliveryView.showInView(source.view)
    }
    
//    
//    fileprivate func createArrayForDeliveryTimeRange() {
//        
//        //load delivery time range for the ordered meal
//        Helper().loadOrderedMeal(order, completion: { meal in
//            if let timeRange = meal.deliveryTimeRange {
//                //create NSDate for the start and end delivery time
//                let arr = timeRange.components(separatedBy: " - ")
//                
//                let convertedStartDeliveryTime = Helper().convertDateAsTime(arr[0])
//                let convertedEndDeliveryTime = Helper().convertDateAsTime(arr[1])
//                var previousTime = convertedStartDeliveryTime
//                
//                var timeRangeArray = [String]()
//                
//                while (convertedEndDeliveryTime > previousTime) {
//                    previousTime = Calendar.current.date(byAdding: .hour, value: 1, to: previousTime)!
//                    let formatted = Helper().getFormattedDateString(previousTime, format: "hh:mm a")
//                    timeRangeArray.append(formatted)
//                }
//                
//                var rangeItem = Helper().getFormattedDateString(convertedStartDeliveryTime, format: "hh:mm a") + " - " + timeRangeArray[0]
//                self.array.append(rangeItem)
//                if timeRangeArray.count > 1 {
//                    for index in 1..<timeRangeArray.count {
//                        rangeItem = timeRangeArray[index - 1] + " - " + timeRangeArray[index]
//                        self.array.append(rangeItem)
//                    }
//                }
//                if self.array.count == 1 {
//                    self.deliveryTimeButton.setTitle(self.array[0], for: UIControlState())
//                    self.deliveryTimeButton.isUserInteractionEnabled = false
//                    if self.delegate != nil {
//                        self.delegate.selectTimeRange(self.order, selectedTimeRange: self.array[0])
//                    }
//                }
//            }
//        })
//    }
}
