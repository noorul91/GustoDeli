//
//  ActiveOrderViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class ActiveOrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!

    //MARK:- Properties
    var user: User!
    var activeOrderArray = [Order]()
    var meal: Meal!
    var sellerName: String!
    var deliveryAddress: String!
    
    //MARK:- Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        if user.myOrder.count != 0 {
            
            //Retrieve all active orders from Firebase
            let ordersRef = FIRDatabase.database().reference().child("Orders")
            var ordersArray: [Order] = []
            
            ordersRef.observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    for orderItem in snapshot.children {
                        let order = Order(snapshot: orderItem as! FIRDataSnapshot)
                        
                        //Exclude order(s) with status "Ongoing" since the order is not placed yet
                        if self.user.userId == order.orderedBy &&
                            order.orderStatus != OrderStatus.ongoing {
                            ordersArray.append(order)
                        }
                    }
                    self.activeOrderArray = ordersArray
                    if self.activeOrderArray.count != 0 {
                        self.tableView.reloadData()
                    } else {
                        self.setupEmptyScreen()
                    }
                }
            })
        }
    }

    //MARK: - Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return activeOrderArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderTableViewCell
        cell.order = activeOrderArray[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        //Fetch meal information from Firebase
        Helper().loadOrderedMeal(activeOrderArray[indexPath.section], completion: { meal in
            self.meal = meal
            
            //Get the seller name for ordered meal.
            Helper().loadMealInformation((meal.mealId), childrenName: "cook", completion: { value in
                if let sellerId = value as? String {
                    Helper().loadUserInformation(sellerId, childrenName: "userName", completion: { value in
                        if let sellerName = value as? String {
                            self.sellerName = sellerName
    
                            Helper().loadAddress(self.activeOrderArray[indexPath.section].deliveryAddressId!, completion: { address in
                                let deliveryAddress = address.buildingName + ", " + address.streetName + ", " + String(address.zipCode) + ", " + address.city
                                self.deliveryAddress = deliveryAddress
                                self.performSegue(withIdentifier: "showOrderSummary", sender: cell)
                            })
                        }
                    })
                }
            })
        })
    }
    

    //MARK:- Private
    fileprivate func setupEmptyScreen() {
    
    }

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOrderSummary" {
            guard let controller = segue.destination as? OrderSummaryViewController else {
                fatalError("Unknown destinatoin for segue showOrderSummary: \(segue.destination)")
            }
            guard let selectedCell = sender as? UITableViewCell else {
                fatalError("Unknown segue showOrderSummary sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            controller.order = activeOrderArray[indexPath.section]
            controller.meal = self.meal
            controller.deliveryAddress = self.deliveryAddress
            controller.sellerName = self.sellerName
            controller.user = user
        }
    }

}
