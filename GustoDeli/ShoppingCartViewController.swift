//
//  ShoppingCartViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class ShoppingCartViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, OrderCollectionViewCellDelegate {

    //MARK:- IBOutlets
    @IBOutlet weak var mCollectionView: UICollectionView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    //MARK:- Properties
    var orderedMeal = [Order]()
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    var user: User?
    
    lazy var loginVC: LoginViewController? = {
        var loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        loginVC.sourceController = self
        return loginVC
    }()
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setupThemeColorNavBar()
        
        if user != nil {
            setupUI()
        } else {
            setupNotLoggedInScreen()
        }
        
    }
    
    //MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderedMeal.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "orderCell", for: indexPath) as! OrderCollectionViewCell
        cell.source = self
        cell.delegate = self
        cell.closeButton.tag = indexPath.item + 1
        cell.order = orderedMeal[indexPath.item]
        return cell
    }
    
    //MARK:- Private
    fileprivate func setupUI() {
        if let userId = user?.userId {
            
            Helper().loadAllOrderForCurrentUser(userId, completion: { orderedMeal in
                
                var filteredArray : [Order] = []
                //Exclude orderedMeal other than status "Ongoing"
                for orderItem in orderedMeal {
                    if orderItem.orderStatus == OrderStatus.ongoing {
                        filteredArray.append(orderItem)
                    }
                }
                if filteredArray.count == 0 {
                    self.setupEmptyCartScreen()
                } else {
                    self.orderedMeal = filteredArray
                    self.mCollectionView.reloadData()
                    self.payButton.customizeStandardButton()
                    Helper().getTotalPriceForAllOrders(userId, completion: {formattedPrice in
                        self.totalPriceLabel.text = "RM \(formattedPrice)"
                    })
                }
            })
        }
    }
    
    @objc fileprivate func startShoppingButtonTapped() {
        performSegue(withIdentifier: "showMainScreen", sender: self)
    }
    
    @objc fileprivate func login() {
        if let controller = loginVC {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    fileprivate func setupNotLoggedInScreen() {
        setupBackgroundView("Log in to add meals to your shopping bag.")
        //add log in button
        createButton("Log in", selector: #selector(login))
    }
    
    fileprivate func setupEmptyCartScreen() {
        setupBackgroundView("Your shopping bag is empty.")
        //add button start shopping
        createButton("Start Shopping!", selector: #selector(startShoppingButtonTapped))
    }
    
    fileprivate func createButton(_ title: String, selector: Selector) {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: screenWidth/2 - 155.5, y: screenHeight/2, width: 311, height: 49)
        button.backgroundColor = UIColor().themeColor()
        button.setTitleColor(.black, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel!.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.customizeStandardButton()
        view.addSubview(button)
    }
    
    fileprivate func setupBackgroundView(_ displayText: String) {
        totalPriceLabel.isHidden = true
        payButton.isHidden = true
        
        let barHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height)!
        let imageView = Helper().createImageViewForEmptyScreen("Food Background 2", x: 0, y: barHeight, width: screenWidth, height: screenHeight - barHeight)
        view.addSubview(imageView)
        
        let layerView = Helper().createFilterViewForEmptyScreen(x: 0, y: barHeight, width: screenWidth, height: screenHeight - barHeight)
        view.addSubview(layerView)
        
        let label = Helper().createLabel(x: screenWidth/2 - 125, y: screenHeight/2 - 80, width: 250, height: 60, textAlignment: .center, labelText: displayText, textColor: .white)
        label.numberOfLines = 0
        view.addSubview(label)
    }
    
    //MARK:- Action
    @IBAction func didTappedCloseButton(_ sender: UIButton) {
        let point: CGPoint = sender.convert(.zero, to: mCollectionView)
        
        if let indexPath = mCollectionView!.indexPathForItem(at: point) {
            if let userId = user?.userId {
                Helper().deleteOrder(userId, currentOrder: orderedMeal[indexPath.row], completion: { numberOfOrder, currentOrder in
                    Helper().getTotalPriceForAllOrders(userId, completion: { formattedPrice in
                        self.totalPriceLabel.text = "RM \(formattedPrice)"
                    })
                    self.orderedMeal.remove(at: indexPath.row)
                    self.mCollectionView.deleteItems(at: [indexPath])
                    self.mCollectionView.reloadData()
                    if self.orderedMeal.count == 0 {
                        self.setupEmptyCartScreen()
                    }
                })
            }
        }
    }
    
    @IBAction func payButtonTapped(_ sender: UIButton) {
        if sender == payButton {
            for element in orderedMeal {
                if element.deliveryTime == nil {
                    Helper().displayAlertMessage(self, messageToDisplay: "Please complete delivery time for all order(s) before checkout.", completionHandler: nil)
                }
            }
            performSegue(withIdentifier: "toOrderSummary", sender: self)
        }
    }
    
    @IBAction func swipedRight(_ sender: UISwipeGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- OrderCollectionViewCellDelegate
    func selectTimeRange(_ order: Order!, selectedTimeRange: String!) {
        //update delivery time for the order in Firebase
        Helper().updateOrderInformation(order.orderId, childName: "deliveryTime", value: selectedTimeRange as AnyObject)
    }
    
    func updatedOrderCount(_ order: Order!, orderCount: Int!, orderIncrease: Bool) {
        //update quantity for current order in Firebase for Orders object
        Helper().updateOrderInformation(order.orderId, childName: "numberOfOrder", value: abs(orderCount) as AnyObject)
        
        /** 
         *  For Meals object, get current number of order for the meal from Firebase
         *  Add the orderCount to the current number of order for the meal from Firebase to get the updated number of order
         *  Load cook name from Firebase
        **/
        if let userId = user?.userId {
            Helper().updateNumberOfOrderForMealObject(userId, order: order, orderIncrease: orderIncrease,
                                                      value: 1, completion: { formattedPrice in
                                                        self.totalPriceLabel.text = "RM \(formattedPrice)"
            })
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toOrderSummary" {
            guard let controller = segue.destination as? CheckoutViewController else {
                fatalError("Unknown destination for segue toOrderSummary: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "showMainScreen" {
            guard let controller = segue.destination as? MealPreviewViewController else {
                fatalError("Unknown destination for segue showMainScreen: \(segue.destination)")
            }
            controller.user = user
        } 
    }
}

