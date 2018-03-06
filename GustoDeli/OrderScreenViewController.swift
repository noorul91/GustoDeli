//
//  OrderScreenViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 9/29/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class OrderScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mealPhoto: UIImageView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    
    //MARK:- Properties
    var meal: Meal!
    var user: User?
    var orders = [Order]()
    var expandedSection = [Int]()
    var confirmedMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealPhoto.loadImageWithCacheWithUrlString(meal.mealPhotoUrl)
        mealPhoto.setBorder()
        mealNameLabel.text = meal.mealName
        deliveryDateLabel.text = meal.deliveryDate
        
        if confirmedMode {
            self.title = "Confirmed Order"
        }
        
        if user == nil {
            
        } else {
            
            let ordersRef = FIRDatabase.database().reference().child("Orders")
            var ordersArray: [Order] = []
            
            ordersRef.observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    for orderItem in snapshot.children {
                        let order = Order(snapshot: orderItem as! FIRDataSnapshot)
                        
                        //Fetch orders with status "unconfirmed" if confirmedMode is false
                        if !self.confirmedMode {
                            if order.orderStatus == OrderStatus.unconfirmed &&
                                self.meal.mealId == order.mealId {
                                ordersArray.append(order)
                            }
                        } else {
                            //Else, fetch orders with status "confirmed"
                            if order.orderStatus == OrderStatus.confirmed &&
                                self.meal.mealId == order.mealId {
                                ordersArray.append(order)
                            }
                        }
                    }
                    self.orders = ordersArray
                    if self.orders.count != 0 {
                        self.tableView.reloadData()
                    } else {
                        self.setupEmptyScreen()
                    }
                }
            })
        }
    }
    
    fileprivate func setupEmptyScreen() {
        let label = Helper().createLabel(x: screenWidth/2 - 125, y: screenHeight/2 , width: 250, height: 100, textAlignment: .center, labelText: "No orders yet.", textColor: .lightGray)
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20)
        label.numberOfLines = 0
        view.addSubview(label)
    }
    
    //MARK:- Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if expandedSection.count != 0 {
            if expandedSection.contains(section) {
                return 2
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandedSection.count != 0 {
            if expandedSection.contains(indexPath.section) && indexPath.row != 0 {
                if confirmedMode {
                    return 110
                }
                return 152
            }
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Tap to view order details."
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if expandedSection.contains(indexPath.section) {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderHeaderTableViewCell
                if let orderId = orders[indexPath.section].orderId {
                    cell.mLabel.text = "Order #\(orderId)"
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! OrderDetailsTableViewCell
                if let numberOfOrder = orders[indexPath.section].numberOfOrder {
                    cell.quantityLabel.text = "\(numberOfOrder)"
                }
                if let time = orders[indexPath.section].deliveryTime {
                    cell.finishedByLabel.text = "\(time)"
                }
                if confirmedMode {
                    cell.mButton.isHidden = true
                } else {
                    cell.mButton.layer.cornerRadius = 8.0
                    cell.mButton.tag = indexPath.section
                }
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderHeaderTableViewCell
            if let orderId = orders[indexPath.section].orderId {
                cell.mLabel.text = "Order #\(orderId)"
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let selectedCell = tableView.cellForRow(at: indexPath) as! OrderHeaderTableViewCell

            if !expandedSection.contains(indexPath.section) {
                expandedSection.append(indexPath.section)
            } else {
                if let index = expandedSection.index(of: indexPath.section) {
                    expandedSection.remove(at: index)
                }
            }
            selectedCell.mImageView?.transform = (selectedCell.mImageView?.transform.rotated(by: CGFloat.pi))!
            tableView.reloadData()
        }
    }
    
    //MARK:- Action
    @IBAction func tappedAcceptButton(_ sender: UIButton) {
        let currentOrder = orders[sender.tag]
        
        //Update the selected order status to "confirmed"
        Helper().updateOrderInformation(currentOrder.orderId, childName: "orderStatus", value: OrderStatus.confirmed.rawValue as AnyObject)
        
//        Helper().loadMealInformation(order.mealId, childrenName: "numberOfUnconfirmedOrder", completion: { value in
//            if let unconfirmedOrder = value as? Int {
//                let updatedNumberOfOrder = unconfirmedOrder + 1
//                Helper().updateMealInformation(order.mealId, childName: "numberOfUnconfirmedOrder", value: updatedNumberOfOrder as AnyObject, completion: nil)
//            }
//        })
        
        Helper().loadMealInformation(currentOrder.mealId, childrenName: "numberOfUnconfirmedOrder", completion: { value in
            if let unconfirmedOrder = value as? Int {
                //Update number of unconfirmed order
                print("currentOrder.numberOfOrder: \(currentOrder.numberOfOrder)")
                print("unconfirmedOrder: \(unconfirmedOrder)")
                let updatedNumberOfUnconfirmedOrder = unconfirmedOrder - 1
                print("updatedNumberOfUnconfirmedOrder: \(updatedNumberOfUnconfirmedOrder)")
                Helper().updateMealInformation(currentOrder.mealId, childName: "numberOfUnconfirmedOrder", value: updatedNumberOfUnconfirmedOrder as AnyObject, completion: { _ in
                    
                    Helper().loadMealInformation(currentOrder.mealId, childrenName: "numberOfOrder", completion: { value in
                        
                        if let numberOfOrder = value as? Int {
                            //Update number of order
                            let updatedNumberOfOrder = numberOfOrder + 1//currentOrder.numberOfOrder
                            Helper().updateMealInformation(currentOrder.mealId, childName: "numberOfOrder", value: updatedNumberOfOrder as AnyObject, completion: { _ in
                            
                                //remove accepted order from array
                                self.orders.remove(at: sender.tag)
                                self.tableView.reloadData()
                                if self.orders.count == 0 {
                                    self.setupEmptyScreen()
                                }
                            })
                        }
                    })
                })
            }
        })
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}

class OrderDetailsTableViewCell: UITableViewCell {
    //MARK:- IBOutlets
    @IBOutlet weak var mButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var finishedByLabel: UILabel!
}

class OrderHeaderTableViewCell: UITableViewCell {
    //MARK:- IBOutlets
    @IBOutlet weak var mLabel: UILabel!
    @IBOutlet weak var mImageView: UIImageView!
}




