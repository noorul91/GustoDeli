//
//  GustoViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/16/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class GustoViewController: UIViewController, OrderButtonViewDelegate,
UITableViewDataSource, UITableViewDelegate {
    
    //MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    //MARK:- Properties
    enum Mode: String {
        case Sell
        case Preview
        case Listing
    }

    var meal: Meal!
    var lastContentOffset: CGFloat = 0.0
    var orderButtonView: OrderButtonView?
    var orderButtonViewHidden = false
    var mode = Mode.Sell
    var user: User?
    var count = 0
    
    let usersRef = FIRDatabase.database().reference().child("Users")
    let ordersRef = FIRDatabase.database().reference().child("Orders")
    let mealsRef = FIRDatabase.database().reference().child("Meals")
    
    lazy var loginVC: LoginViewController? = {
        var loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        loginVC.sourceController = self
        loginVC.meal = self.meal
        return loginVC
    }()
    
    //MARK:- Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 156
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mode == Mode.Sell {
            addMenu()
            Helper().updateShoppingCartButton(self.navigationItem, selector: #selector(self.shoppingCartButtonTapped(_:)), source: self, user: user, animated: false)
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if mode == Mode.Sell {
            removeMenu()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableViewTopConstraint.constant = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.size.height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let view = orderButtonView {
            if lastContentOffset < 0.0 {
                //do nothing
            } else if lastContentOffset > scrollView.contentOffset.y {
                view.handleOrderButtonView(false, currentController: self)
            } else if lastContentOffset < scrollView.contentOffset.y {
                view.handleOrderButtonView(true, currentController: self)
            }
            lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    //MARK:- Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! LabelTableViewCell
            cell.mLabel.text = meal.mealName
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoTableViewCell
            if meal.mealPhoto != nil {
                cell.photo.image = meal.mealPhoto
            } else {
                cell.photo.loadImageWithCacheWithUrlString(meal.mealPhotoUrl)
            }
            cell.photo.setBorder()
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mealDetailCell", for: indexPath) as! AddressTableViewCell
            cell.mLabel1.text = "MEAL DETAILS"
            cell.mLabel2.text = meal.mealDescription
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mealDetailCell", for: indexPath) as! AddressTableViewCell
            cell.mLabel1.text = "WHAT ELSE DO I GET?"
            cell.mLabel2.text = meal.mealSideDish
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mealDetailCell", for: indexPath) as! AddressTableViewCell
            cell.mLabel1.text = "PRICE & DELIVERY TIME"
            if let deliveryTime = meal.deliveryTimeRange, let deliveryDate = meal.deliveryDate {
                cell.mLabel2.text = "\nRM \(meal.getFormattedMealPrice()) - Delivery cost on us! \n\n Delivery on\n\n\(deliveryDate)\n\n\(deliveryTime)"
            }
            return cell
        } else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell", for: indexPath) as! IngredientTableViewCell
            cell.ingredients = meal.ingredients
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cookCell", for: indexPath) as! AboutCookTableViewCell
            cell.setAttributedTitle = false
            cell.cook = meal.cook
            return cell
        }
    }
    
    //MARK:- Action
    @IBAction func cookNameButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "userDetails", sender: self)
    }
    
    @IBAction func shoppingCartButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "shoppingCart", sender: self)
    }
    
    @IBAction func tappedReportButton(_ sender: Any) {
        if mode == Mode.Sell {
            performSegue(withIdentifier: "report", sender: self)
        }
    }
    
    @IBAction func unwindToDetailsFromAddMealVC(_ sender: UIStoryboardSegue) {
        if let source = sender.source as? AddMealViewController {
            self.meal = source.meal
            self.meal.cook = source.cook
        }
    }
    
    @IBAction func unwindFromInqVC(_ sender: UIStoryboardSegue) {
        guard sender.source is GeneralInqViewController else {
            fatalError("Unknown sender.source in unwindFromInqVCToAboutVC function: \(sender.source)")
        }
    }
    
    @IBAction func swipedRight(_ sender: UISwipeGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc fileprivate func submitButtonTapped() {
        //save meal info to Firebase
        let mealRef = mealsRef.childByAutoId()
        mealRef.setValue(meal.toAnyObject())
        
        for ingredientName in meal.ingredients! {
            mealRef.child("ingredients").child(ingredientName).setValue(true)
        }
        

        //upload meal photo to storage
        if let photo = meal.mealPhoto {
            let filePath = "\("MealPhotos")/\(mealRef.key)"
            PostService.create(for: photo, childPath: filePath, completion: {urlString in
                
                //save mealId to user
                self.usersRef.child((self.user?.userId)!).child("listing").child(mealRef.key).setValue(true)
                self.user?.listing.append(mealRef.key)
                
                Helper().updateMealInformation(mealRef.key, childName: "mealPhotoUrl", value: urlString as AnyObject, completion: {_ in
                    self.performSegue(withIdentifier: "addMeal", sender: self)
                })
            })
        }
    }
    
    @objc fileprivate func editButtonTapped() {
        performSegue(withIdentifier: "edit", sender: self)
    }
    
    @objc fileprivate func moreButtonTapped() {
        //prompt alert to confirm sold out
        let alert = UIAlertController(title: "Delete this listing", message: "Deleting cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
            self.performSegue(withIdentifier: "delete", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:- Private
    fileprivate func setupUI() {
        self.navigationController?.navigationBar.setupThemeColorNavBar()
        if mode == Mode.Preview {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitButtonTapped))
        } else if mode == Mode.Listing {
            listingModeButtonSetup()
        } else {
            Helper().updateShoppingCartButton(self.navigationItem, selector: #selector(shoppingCartButtonTapped(_:)), source: self, user: user, animated: false)
        }
    }
    
    fileprivate func listingModeButtonSetup() {
        let button = UIButton.init(type: .custom)
        if !meal.soldOut {
            button.setupButton(imageName: "Edit", source: self, selector: #selector(editButtonTapped))
        } else {
            button.setupButton(imageName: "More icon", source: self, selector: #selector(moreButtonTapped))
        }
        button.tintColor = .white
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    fileprivate func addMenu() {
        if orderButtonView == nil {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let orderButtonV = Bundle.main.loadNibNamed("OrderButtonView", owner: self, options: nil)?[0] as! OrderButtonView
            orderButtonV.orderButtonView = orderButtonV
            orderButtonV.delegate = self
            
            if let user = user {
                // Check if the meal is already ordered before.
                // If there is, check whether there is existing order of the same menu from the current user
                usersRef.child(user.userId).child("order").observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.exists() {
                        let orderArray = (snapshot.value as! NSDictionary).allKeys as! [String]
                        
                        for orderId in orderArray {
                            Helper().loadOrderInformation(orderId, childrenName: "mealId", completion: {value in
                                if let mealId = value as? String {
                                    //The meal is already ordered before
                                    if mealId == self.meal.mealId {
                                        //load the order & pass the order to OrderButtonView
                                        Helper().loadOrder(orderId, completion: {order in
                                            if order.orderStatus == OrderStatus.ongoing {
                                                orderButtonV.order = order
                                            }
                                        })
                                    }
                                }
                            })
                        }
                    }
                })
            }
            
        
            orderButtonV.meal = self.meal
            appDelegate.window?.addSubview(orderButtonV)
            orderButtonV.slideInFromBottom()
            orderButtonView = orderButtonV
        }
    }
    
    fileprivate func removeMenu() {
        if let view = orderButtonView {
            view.removeFromSuperview()
            self.orderButtonView = nil
        }
    }
    
    fileprivate func insertNewOrderToFirebase(_ numberOfOrder: Int!) {
        //create Order object and append to orderedMeal array
        let order = Order(mealId: meal.mealId, numberOfOrder: numberOfOrder, orderedBy: user?.userId, deliveryDate: meal.deliveryDate)
        
        //insert order to Firebase
        let orderRef = ordersRef.childByAutoId()
        orderRef.setValue(order?.toAnyObject())
        //save orderId to user
        usersRef.child((user?.userId)!).child("order").child(orderRef.key).setValue(true)
        user?.myOrder.append((order?.orderId)!)
        
        //pass newly created Order object to OrderButtonView
        order?.orderId = orderRef.key
        orderButtonView?.order = order
        
        Helper().updateShoppingCartButton(self.navigationItem, selector: #selector(shoppingCartButtonTapped(_:)), source: self, user: user, animated: true)
    }
    
    fileprivate func updateOrderFirebase(_ numberOfOrder: Int!, order: Order!) {
        if let id = order?.orderId {
            Helper().updateOrderInformation(id, childName: "numberOfOrder", value: numberOfOrder as AnyObject)
            
        }
        Helper().updateShoppingCartButton(self.navigationItem, selector: #selector(self.shoppingCartButtonTapped(_:)), source: self, user: self.user, animated: true)
    }
    
    //MARK:- OrderButtonViewDelegate
    func updateOrder(_ numberOfOrder: Int!, order: Order?) {
        
        //Verify if user is logged in
        
        //User is logged in
        if user != nil {
            if meal.cook.userId == user?.userId {
                Helper().displayAlertMessage(self, messageToDisplay: "You are not allowed to buy your own meal.", completionHandler: nil)
            } else if numberOfOrder == 0 {
                Helper().displayAlertMessage(self, messageToDisplay: "Please go to shopping cart to completely delete your order.", completionHandler: nil)
            } else {
                verifyOrder(numberOfOrder, order: order, completion: { success in
                    guard success == true else { return }
                    if order != nil {
                        self.updateOrderFirebase(numberOfOrder, order: order)
                    } else {
                        self.insertNewOrderToFirebase(numberOfOrder)
                    }
                })
            }
        } else {
            //User is not logged in yet, so we prompt log in screen
            if let controller = loginVC {
                self.present(controller, animated: true, completion: nil)
            }
        }
        
    }
    
    /**
     * Verify if there's any item in the cart.
     * If there is, check if the seller of the item matches with the seller of the item to be add into the cart.
     * Only allow user to add meals from the same seller at one time.
     **/
    fileprivate func verifyOrder(_ numberOfOrder: Int!, order: Order?, completion: @escaping (Bool)-> Void) {
        
        Helper().loadAllOrder(completion: { orderedMeal in
            if orderedMeal.count != 0 {
                self.verifyCookListing(numberOfOrder, order: order, orderedMeal: orderedMeal, completion: completion)
            } else {
                self.insertNewOrderToFirebase(numberOfOrder)
            }
        })
    }
    
    fileprivate func verifyCookListing(_ numberOfOrder: Int!, order: Order?, orderedMeal: [Order], completion: @escaping (Bool)-> Void) {
        Helper().loadUserInformation(meal.cook.userId, childrenName: "listing", completion: {value in
            let mealIdArray = (value as! NSDictionary).allKeys as! [String]
            
            //Verify if the cook in ordered meal and current cook matches
            for orderedItem in orderedMeal {
                if !mealIdArray.contains(orderedItem.mealId) {
                    self.displayAlertConfirmRemoval(numberOfOrder, order: order, orderedMeal: orderedMeal)
                    return
                }
            }
            completion(true)
        })
        
    }
    
    fileprivate func displayAlertConfirmRemoval(_ numberOfOrder: Int!, order: Order?, orderedMeal: [Order]) {
        //prompt alert to confirm removal of items in cart
        let alert = UIAlertController(title: "Gusto Deli", message: "You have already selected meal from another seller. Your selection in the cart will be cleared if you wish to continue.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let userId = self.user?.userId {
                //clear existing order and insert new order
                for item in orderedMeal {
                    Helper().deleteOrder(userId, currentOrder: item, completion: { numOrder, currentOrder in
                        Helper().updateNumberOfOrderForMealObject(userId, order: currentOrder, orderIncrease: false, value: numOrder, completion: { _ in
                            //self.totalPriceLabel.text = "RM \(formattedPrice)"
                        })
                        self.insertNewOrderToFirebase(numberOfOrder)
                    })
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addMeal" {
            guard let nav = segue.destination as? UINavigationController,
                let controller = nav.viewControllers.first as? MealPreviewViewController else {
                    fatalError("Unknown destination for segue addMeal: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "shoppingCart" {
            guard let controller = segue.destination as? ShoppingCartViewController else {
                fatalError("Unknown destination for segue shoppingCart: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "edit" {
            guard let controller = segue.destination as? AddMealViewController else {
                fatalError("Unknown destination for segue edit: \(segue.destination)")
            }
            controller.editMode = true
            controller.meal = meal
            controller.cook = user
            
            if let ingredientArray = meal.ingredients {
                var selectedIngredients = ingredientArray[0]
                if ingredientArray.count > 1 {
                    for index in 1..<ingredientArray.count {
                        selectedIngredients = selectedIngredients + ", " + ingredientArray[index]
                    }
                }
                controller.mealDict["selectedIngredients"] = selectedIngredients
            }
        } else if segue.identifier == "delete" {
            guard let controller = segue.destination as? ListingViewController else {
                fatalError("Unknown destination for segue delete: \(segue.destination)")
            }
            /***
             let keyArrays = Array(user.meals.keys)
             for i in keyArrays {
             if i.mealId == meal?.mealId {
             user.meals.removeValue(forKey: i)
             }
             }**/
            controller.user = user
        } else if segue.identifier == "userDetails" {
            guard let controller = segue.destination as? UserDashboardViewController else {
                fatalError("Unknown destination for segue userDetails: \(segue.destination)")
            }
            controller.currentUser = user
            //controller.viewedUser = meal.cook
        } else if segue.identifier == "report" {
            guard let controller = segue.destination as? GeneralInqViewController else {
                fatalError("Unknown destination for segue report: \(segue.destination)")
            }
            controller.user = user
            controller.mode = GeneralInqViewController.Mode.reportUserMode
            //controller.reportedCook = meal.cook
        }
    }
}

