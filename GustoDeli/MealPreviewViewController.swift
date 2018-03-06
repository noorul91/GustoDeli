//
//  MealPreviewViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class MealPreviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CalendarViewControllerDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentedControl: TabSegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK:- Properties
    var meals = [Meal]()
    var sellView: SellView?
    var calVC: CalendarViewController?
    var selectedDate: String = ""
    var navigationItemButton = UIButton()
    var transitionOperator = TransitionOperator()
    var orderedMeal = [Order]()
    var user: User?
    var selectedDeliveryDate: String?
    var mealsRef = FIRDatabase.database().reference(withPath: "Meals")
    var mealNotAvailableLabel: UILabel?
    
    lazy var calendarVC: CalendarViewController? = {
       var calendarVC = self.storyboard?.instantiateViewController(withIdentifier: "calendarVC") as! CalendarViewController
        calendarVC.navBarHeight = (self.navigationController?.navigationBar.frame.height)!
        calendarVC.delegate = self
        return calendarVC
    }()
    
    lazy var loginVC: LoginViewController? = {
        var loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        loginVC.sourceController = self
        return loginVC
    }()
    
    enum TabIndex: Int {
        case everythingChildTab = 0
        case malayChildTab = 1
        case chineseChildTab = 2
        case indianChildTab = 3
        case thaiChildTab = 4
        case westernChildTab = 5
        case italianChildTab = 6
        case koreanChildTab = 7
        case japaneseChildTab = 8
        case arabianChildTab = 9
        case internationalChildTab = 10
        case healthyChildTab = 11
        case dessertsChildTab = 12
        case vegetarianChildTab = 13
        case othersChildTab = 14
    }
    
    //MARK:- Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        //loadSampleMeals()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addSellView()
        Helper().updateShoppingCartButton(self.navigationItem, selector: #selector(self.shoppingCartButtonTapped(_:)), source: self, user: user, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeSellView()
    }
    
    //MARK:- Table View data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 667 - CGFloat(233 * meals.count)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.groupTableViewBackground
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealPreviewCell", for: indexPath) as! MealPreviewTableViewCell
        cell.meal = meals[indexPath.row]
        return cell
    }
    
    //MARK:- Action
    
    @IBAction func didTappedSellButton() {
        
        //verify whether user is logged in 
        if user == nil {
            //Helper().displayAlertMessage(self, messageToDisplay: "Log in to start selling.", completionHandler: nil)
            //prompt alert to ask user to login
            let alert = UIAlertController(title: "Gusto Deli", message: "You have to log in to start selling.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Log In", style: .default, handler: { action in
                //prompt login view
                if let controller = self.loginVC {
                    self.present(controller, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            //verify whether necessary information is complete
            
            /**
             if user.userPhoto == nil || user.userLocation == nil || user.userDescription == nil {
             removeSellView()
             let alertController = UIAlertController(title: "Gusto Deli", message: "Please complete your profile information before start selling.", preferredStyle: .alert)
             alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
             self.performSegue(withIdentifier: "showSetting", sender: self)
             }))
             self.present(alertController, animated: true, completion: nil)
             **/
            //} else {
            //            user.userDescription = "A famous chef currently working in famous 5 star hotel at your service."
            //            user.userLocation = "Bukit Jalil"
            performSegue(withIdentifier: "addMeal", sender: self)
            //}
        }
        
 
    }
    
    @IBAction func unwindToMealListFromAddMealVC(_ sender: UIStoryboardSegue) {
        
        
    }
    
    @IBAction func navigationItemTitleTapped(_ sender: UIButton) {
        if calVC == nil {
            navigationItemButton.imageView?.transform = (navigationItemButton.imageView?.transform.rotated(by: CGFloat.pi))!
            sellView?.alpha = 0
            addCalendarMenu()
        } else {
            calVC?.view.removeAnimation()
            navigationItemButton.imageView?.transform = .identity
            sellView?.alpha = 1
            calVC = nil
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "presentMenu", sender: self)
    }
    
    @IBAction func shoppingCartButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "shoppingCart", sender: self)
    }
    
    @IBAction func swipedRight(_ gesture: UIGestureRecognizer) {
        performSegue(withIdentifier: "presentMenu", sender: self)
    }
    
    //MARK:- Action
    @IBAction func switchTabs(_ sender: TabSegmentedControl) {
        fetchMeals(sender.selectedSegmentIndex)
    }
    
    //MARK:- Private
    fileprivate func fetchMeals(_ selectedSegmentIndex: Int?) {
        //load meals from Firebase
        mealsRef.observeSingleEvent(of: .value, with: { snapshot in
            var newItems: [Meal] = []
            var userIdItems: [String] = []
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                let mealItem = Meal(snapshot: item)
                
                //filter meal by Delivery date
                if let deliveryDate = self.selectedDeliveryDate {
                    if deliveryDate == mealItem.deliveryDate {
                        if let categoryString = self.categoryForSelectedSegmentIndex(selectedSegmentIndex!) {
                            if (categoryString == "Everything") || (mealItem.category == categoryString) {
                                let snapshotValue = item.value as! [String: AnyObject]
                                newItems.append(mealItem)
                                if let cookId = snapshotValue["cook"] as? String {
                                    userIdItems.append(cookId)
                                }
                            }
                        }
                    }
                }
            }
            
            //Clear out mealNotAvailableLabel from tableView
            if self.mealNotAvailableLabel != nil {
                self.mealNotAvailableLabel?.removeFromSuperview()
                self.mealNotAvailableLabel = nil
            }
            
            if newItems.count != 0 {
                Helper().fetchUser(newItems, userIdItems: userIdItems, completion: { newItems in
                    self.meals = newItems
                    if self.meals.count != 0 {
                        self.tableView.reloadData()
                        self.mealsRef.removeAllObservers()
                    }
                })
            } else {
                self.meals = newItems
                self.tableView.reloadData()
                self.setupEmptyScreen()
                self.mealsRef.removeAllObservers()
            }
        })
    }
    
    fileprivate func categoryForSelectedSegmentIndex(_ index: Int) -> String? {
        switch index {
        case TabIndex.everythingChildTab.rawValue:
            return "Everything"
        case TabIndex.malayChildTab.rawValue:
            return "Malay"
        case TabIndex.chineseChildTab.rawValue:
            return "Chinese"
        case TabIndex.indianChildTab.rawValue:
            return "Indian"
        case TabIndex.thaiChildTab.rawValue:
            return "Thai"
        case TabIndex.westernChildTab.rawValue:
            return "Western"
        case TabIndex.italianChildTab.rawValue:
            return "Italian"
        case TabIndex.koreanChildTab.rawValue:
            return "Korean"
        case TabIndex.japaneseChildTab.rawValue:
            return "Japanese"
        case TabIndex.arabianChildTab.rawValue:
            return "Arabian"
        case TabIndex.healthyChildTab.rawValue:
            return "Healthy"
        case TabIndex.dessertsChildTab.rawValue:
            return "Desserts"
        case TabIndex.vegetarianChildTab.rawValue:
            return "Vegetarian"
        default:
            return "Others"
        }
    }
    
    fileprivate func setupUI() {
//        let screenHeight: CGFloat = UIScreen.main.bounds.height
//        let barHeight = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.size.height - 1
//        if tableView.frame.size.height <= (screenHeight - barHeight) {
//            tableView.isScrollEnabled = false
//        }
        self.navigationController?.navigationBar.setupThemeColorNavBar()
        
        
        //setup clickable navigation item title
        setupClickableDateNavigationBar()
        segmentedControl.initUI()
        segmentedControl.selectedSegmentIndex = TabIndex.everythingChildTab.rawValue
        fetchMeals(segmentedControl.selectedSegmentIndex)
        Helper().updateShoppingCartButton(self.navigationItem, selector: #selector(self.shoppingCartButtonTapped(_:)), source: self, user: user, animated: false)
    }
    
    fileprivate func setupClickableDateNavigationBar() {
        navigationItemButton = UIButton(type: .system)
        navigationItemButton.frame = CGRect(x: 0, y: 0, width: 180, height: 70)
        navigationItemButton.setTitle(Helper().getFormattedDateString(Date(), format: "EEEE, MMM d"), for: .normal)
        selectedDeliveryDate = Helper().getFormattedDateString(Date(), format: "EEEE, MMM d, yyyy")
        navigationItemButton.setTitleColor(.white, for: .normal)
        navigationItemButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17)
        navigationItemButton.setImage(UIImage(named: "Down icon"), for: .normal)
        navigationItemButton.semanticContentAttribute = .forceRightToLeft
        navigationItemButton.centerTextAndImage(spacing: 10)
        
        navigationItemButton.addTarget(self, action: #selector(navigationItemTitleTapped(_:)), for: .touchUpInside)
        self.navigationItem.titleView = navigationItemButton
    }
    
    fileprivate func setupEmptyScreen() {
        
        //let barHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height)! + scrollView.frame.size.height
        //        let imageView = Helper().createImageViewForEmptyScreen("Food Background 1", x: 0, y: barHeight, width: screenWidth, height: screenHeight - barHeight)
        //        view.addSubview(imageView)
        
        //        let layerView = Helper().createFilterViewForEmptyScreen(x: 0, y: barHeight, width: screenWidth, height: screenHeight - barHeight)
        //        view.addSubview(layerView)
        
        //        let layerView = UIView(frame: CGRect(x: 0, y: barHeight, width: screenWidth, height: screenHeight - barHeight))
        //        layerView.backgroundColor = .white
        //        view.addSubview(layerView)
        
        //        let label = Helper().createLabel(x: screenWidth/2 - 150, y: screenHeight/2 - 40, width: 250, height: 60, textAlignment: .center, labelText: "No delivery available for this date.", textColor: .white)
        //        label.numberOfLines = 0
        //        view.addSubview(label)
        
        mealNotAvailableLabel = Helper().createLabel(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.frame.size.height, textAlignment: .center, labelText: "Please try another date or category.", textColor: .lightGray)
        mealNotAvailableLabel?.numberOfLines = 0
        tableView.addSubview(mealNotAvailableLabel!)
        
        /**
         let arrowView1 = UIImageView(image: UIImage(named: "Arrow icon"))
         arrowView1.frame = CGRect (x: screenWidth/2 + 20, y: screenHeight/2 + 10 , width: 100, height: 100)
         arrowView1.contentMode = .scaleAspectFill
         view.addSubview(arrowView1)
         
         let arrowView2 = UIImageView(image: UIImage(named: "Arrow icon"))
         arrowView2.frame = CGRect (x: 100, y: 50 , width: 100, height: 100)
         arrowView2.contentMode = .scaleAspectFill
         view.addSubview(arrowView2)
         
         
         let arrowLabel = Helper().createLabel(x: screenWidth/2 - 80, y: screenHeight/2 + 70, width: 250, height: 60, textAlignment: .center, labelText: "Sell your own meal with the + button.", textColor: .white)
         arrowLabel.numberOfLines = 0
         view.addSubview(arrowLabel)
         
         let dateLabel = Helper().createLabel(x: 40, y: 115, width: 250, height: 60, textAlignment: .center, labelText: "Try another date by clicking on this date.", textColor: .white)
         dateLabel.numberOfLines = 0
         view.addSubview(dateLabel)**/
        
    }
    
    fileprivate func addSellView() {
        if sellView == nil {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let sellV = Bundle.main.loadNibNamed("SellView", owner: self, options: nil)?[0] as! SellView
            sellV.sellButton.addTarget(self, action: #selector(didTappedSellButton), for: .touchUpInside)
            appDelegate.window?.addSubview(sellV)
            sellView = sellV
        }
    }
    
    fileprivate func removeSellView() {
        sellView?.removeFromSuperview()
        self.sellView = nil
    }
    
    /**
     fileprivate func loadSampleMeals() {
     let photo1 = UIImage(named: "Onion")
     let photo2 = UIImage(named: "Garlic")
     let photo3 = UIImage(named: "Potato")
     let photo4 = UIImage(named: "Salt")
     
     guard let ing1 = Ingredient(name: "Onion", image: photo1) else {
     fatalError("Unable to instantiate ingredient 1")
     }
     guard let ing2 = Ingredient(name: "Garlic", image: photo2) else {
     fatalError("Unable to instantiate ingredient 2")
     }
     guard let ing3 = Ingredient(name: "Potato", image: photo3) else {
     fatalError("Unable to instantiate ingredient 3")
     }
     guard let ing4 = Ingredient(name: "Salt", image: photo4) else {
     fatalError("Unable to instantiate ingredient 4")
     }
     
     let mealPhoto1 = UIImage(named: "BBQ Chicken Leg")
     let mealPhoto2 = UIImage(named: "Salmon pasta")
     let mealPhoto3 = UIImage(named: "Moroccan Chicken Tagine")
     let mealPhoto4 = UIImage(named: "Pan Seared Chicken Breast")
     let mealPhoto5 = UIImage(named: "Pumpkin Soup")
     
     let cook1 = User(userId: 1, userName: "Chef Wan", emailAddress: "chef.wan@gmail.com", password: "sdfw")
     cook1?.userPhoto = UIImage(named: "Chef Wan")
     cook1?.userLocation = "Seri Kembangan"
     cook1?.userDescription = "Former chef of 5 star hotel such as DoubleTree and Hilton. His secret ingredients include 3tbs of care, 4 oz of tast and a whole bucket of love!"
     
     
     let cook2 = User(userId: 2, userName: "Chef Samuel Linder", emailAddress: "samuel@gmail.com", password: "sdfw")
     cook2?.userPhoto = UIImage(named: "Chef Samuel")
     cook2?.userLocation = "Kuala Lumpur"
     cook2?.userDescription = "A famous chef currently working in famous 5 star hotel at your service."
     
     let cook3 = User(userId: 3, userName: "Chef Boscareto", emailAddress: "boscareto@gmail.com", password: "sdfw")
     cook3?.userPhoto = UIImage(named: "Chef Boscareto")
     cook3?.userLocation = "Kuala Lumpur"
     cook3?.userDescription = "A famous chef currently working in famous 5 star hotel at your service."
     
     let cook4 = User(userId: 4, userName: "Chef Noraliza", emailAddress: "noraliza@gmail.com", password: "sdfw")
     cook4?.userPhoto = UIImage(named: "Chef Noraliza")
     cook4?.userLocation = "Kuala Lumpur"
     cook4?.userDescription = "A famous chef currently working in famous 5 star hotel at your service."
     
     let meal1 = Meal(mealId: 0, mealName: "Weekly Special Honey BBQ Chicken Leg",
     mealPhoto: mealPhoto1,
     mealDescription: "Taste the goodness of the sun with this light dish. Sun-ripened sweet green peas are paired with succulent oven-dried tomatoes, and a tangy lemon cream sauce.",
     mealSideDish: "With oven-dried tomatoes and Garlic Pea Puree",
     mealPrice: 25.00,
     deliveryDate: "Tuesday, 18 Jul 2017",
     deliveryTimeRange: "12:00 PM - 6:00 PM",
     ingredients: [ing1, ing2, ing3, ing4],
     cook: cook1)!
     
     let meal2 = Meal(mealId: 1, mealName: "Salmon Spring Pasta",
     mealPhoto: mealPhoto2,
     mealDescription: "Taste the goodness of the sun with this light dish. Sun-ripened sweet green peas are paired with succulent oven-dried tomatoes, and a tangy lemon cream sauce.",
     mealSideDish: "With oven-dried tomatoes and Garlic Pea Puree",
     mealPrice: 24.00,
     deliveryDate: "Friday, 18 Jul 2017",
     deliveryTimeRange: "1:00 PM - 9:00 PM",
     ingredients: [ing2, ing3, ing4],
     cook: cook2)!
     
     let meal3 = Meal(mealId: 3, mealName: "Weekly Special Morrocan Chicken Tagine",
     mealPhoto: mealPhoto3,
     mealDescription: "Taste the goodness of the sun with this light dish. Sun-ripened sweet green peas are paired with succulent oven-dried tomatoes, and a tangy lemon cream sauce.",
     mealSideDish: "With oven-dried tomatoes and Garlic Pea Puree",
     mealPrice: 23.00,
     deliveryDate: "Sunday, 18 Jul 2017",
     deliveryTimeRange: "8:00 PM - 10:00 PM",
     ingredients: [ing1, ing2, ing3, ing4],
     cook: cook4)!
     
     let meal4 = Meal(mealId: 4, mealName: "Pan Seared Chicken Breast",
     mealPhoto: mealPhoto4,
     mealDescription: "Taste the goodness of the sun with this light dish. Sun-ripened sweet green peas are paired with succulent oven-dried tomatoes, and a tangy lemon cream sauce.",
     mealSideDish: "With oven-dried tomatoes and Garlic Pea Puree",
     mealPrice: 25.00,
     deliveryDate: "Tuesday, 18 Jul 2017",
     deliveryTimeRange: "12:00 PM - 6:00 PM",
     ingredients: [ing1, ing2, ing3, ing4],
     cook: cook3)!
     meals.append(meal1)
     meals.append(meal2)
     meals.append(meal3)
     meals.append(meal4)
     }
     **/
    
    fileprivate func addCalendarMenu() {
        if calVC == nil {
            if let vc = calendarVC {
                calVC = vc
                self.view.addSubview(vc.view)
                vc.showInView(self.view)
            }
        }
    }
    
    //MARK:- CalendarViewControllerDelegate
    func dateWasSelected(_ date: String) {
        let formattedDate = Helper().convertDateFormater(date, fromFormat: "EEEE, MMM d, yyyy", toFormat: "EEEE, MMM d")
        navigationItemButton.setTitle(formattedDate, for: .normal)
        navigationItemButton.imageView?.transform = .identity
        sellView?.alpha = 1
        calVC = nil
        selectedDeliveryDate = date
        fetchMeals(segmentedControl.selectedSegmentIndex)
    }
    
    //MARK:- ViewControllerDelegate
    func updateOrderedmeal(_ orderedMeal: [Order]) {
        self.orderedMeal = orderedMeal
        Helper().updateShoppingCartButton(self.navigationItem, selector: #selector(self.shoppingCartButtonTapped(_:)), source: self, user: user, animated: false)
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelectedMeal" {
            guard let controller = segue.destination as? GustoViewController else {
                fatalError("Unknown destination for segue showSelectedMeal: \(segue.destination)")
            }
            guard let selectedCell = sender as? UITableViewCell else {
                fatalError("Unknown segue showSelectedMeal sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            controller.meal = meals[indexPath.row]
            if user != nil {
                controller.user = user
            }
        } else if segue.identifier == "presentMenu" {
            guard let controller = segue.destination as? MenuViewController else {
                    fatalError("Unknown destination for segue presentMenu: \(segue.destination)")
            }
            if user != nil {
                controller.user = user
            }
            self.modalPresentationStyle = .custom
            controller.transitioningDelegate = transitionOperator
        } else if segue.identifier == "shoppingCart" {
            guard let controller = segue.destination as? ShoppingCartViewController else {
                fatalError("Unknown destination for segue shoppingCart: \(segue.destination)")
            }
            if user != nil {
                controller.user = user
            }
            if self.orderedMeal.count != 0 {
                controller.orderedMeal = orderedMeal
            }
        } else if segue.identifier == "showSetting" {
            guard let controller = segue.destination as? ProfileViewController else {
                fatalError("Unknown destination for segue showSetting: \(segue.destination)")
            }
            if user != nil {
                controller.user = user
            }
        } else if segue.identifier == "addMeal" {
            guard let controller = segue.destination as? AddMealViewController else {
                fatalError("Unknown destination for segue addMeal: \(segue.destination)")
            }
            if user != nil {
                controller.cook = user
            }
        }
    }
    

}
