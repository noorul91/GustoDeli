//
//  Helper.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/16/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

let screenWidth: CGFloat = UIScreen.main.bounds.width
let screenHeight: CGFloat = UIScreen.main.bounds.height
let mealsRef = FIRDatabase.database().reference(withPath: "Meals")
let ordersRef = FIRDatabase.database().reference().child("Orders")
let usersRef = FIRDatabase.database().reference().child("Users")
let addressRef = FIRDatabase.database().reference().child("addresses")

class Helper {
    
    func createArrayForDeliveryTimeRange(_ order: Order, completionForArray: ((_ array: [String])-> Void)?) {
        
        //load delivery time range for the ordered meal
        Helper().loadOrderedMeal(order, completion: { meal in
            if let timeRange = meal.deliveryTimeRange {
                //create NSDate for the start and end delivery time
                let arr = timeRange.components(separatedBy: " - ")
                
                let convertedStartDeliveryTime = Helper().convertDateAsTime(arr[0])
                let convertedEndDeliveryTime = Helper().convertDateAsTime(arr[1])
                var previousTime = convertedStartDeliveryTime
                
                var timeRangeArray = [String]()
                var array = [String]()
                
                while (convertedEndDeliveryTime > previousTime) {
                    previousTime = Calendar.current.date(byAdding: .hour, value: 1, to: previousTime)!
                    let formatted = Helper().getFormattedDateString(previousTime, format: "hh:mm a")
                    timeRangeArray.append(formatted)
                }
                
                var rangeItem = Helper().getFormattedDateString(convertedStartDeliveryTime, format: "hh:mm a") + " - " + timeRangeArray[0]
                
                array.append(rangeItem)
                if timeRangeArray.count > 1 {
                    for index in 1..<timeRangeArray.count {
                        rangeItem = timeRangeArray[index - 1] + " - " + timeRangeArray[index]
                        array.append(rangeItem)
                    }
                }
                if completionForArray != nil {
                    completionForArray!(array)
                }
            }
        })
    }
    
    func updateNumberOfOrderForMealObject(_ userId: String, order: Order, orderIncrease: Bool, value: Int, completion:  ((_ formattedPrice: NSString)-> Void)?) {
        let mealRef = FIRDatabase.database().reference().child("Meals").child(order.mealId).child("numberOfOrder")
        mealRef.observeSingleEvent(of: .value, with: { snapshot in
            if let numberOfOrder = snapshot.value as? Int {
                var updatedOrder = 0
                if orderIncrease {
                    updatedOrder = numberOfOrder + value
                } else {
                    updatedOrder = numberOfOrder - value
                }
                mealRef.setValue(updatedOrder)
                Helper().getTotalPriceForAllOrders(userId, completion: completion!)
            }
        })
    }
    
    func deleteOrder(_ userId: String, currentOrder: Order, completion: @escaping (Int, Order)-> Void) {
        FIRDatabase.database().reference().child("Users").child(userId).child("order").child(currentOrder.orderId).removeValue { (error, ref) in
            if error != nil {
                print("error \(String(describing: error))")
            } else {
                //delete Order object from Firebase
                self.deleteOrderObject(currentOrder , completion: completion)
            }
        }
    }
        
    func deleteOrderObject(_ orderItem: Order, completion: @escaping (Int, Order)-> Void) {
        //delete Order object from Firebase
        FIRDatabase.database().reference().child("Orders").child(orderItem.orderId).removeValue { (error, ref) in
            if error != nil {
                print("error \(String(describing: error))")
            } else {
                //update numberOfOrder for ordered Meal object
                FIRDatabase.database().reference().child("Meals").child(orderItem.mealId).child("numberOfOrder").observeSingleEvent(of: .value, with: { snapshot in
                    if let numberOfOrder = snapshot.value as? Int {
                        completion(numberOfOrder, orderItem)
                    }
                })
            }
        }
    }
    
    func convertDateFormater(_ date: String, fromFormat: String, toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        let date1 = dateFormatter.date(from: date)
        dateFormatter.dateFormat = toFormat
        return  dateFormatter.string(from: date1!)
        
    }
    /**
    func dateFormattedStringWithFormat(_ format: String, fromDate date: Foundation.Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }**/
    
    func convertDateAsTime(_ date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter.date(from: date)!
    }
    
    func getFormattedDateString(_ date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func getUIImageFromURLString(_ photoURLString: String) -> UIImage? {
        let url = NSURL(string: photoURLString)  //postPhoto URL
        let data =  NSData(contentsOf: url! as URL) // this URL convert into Data
        
        if data != nil {
            return UIImage(data: data! as Data)
        }
        return nil
    }
    
    func loadAllAddressForCurrentUser(_ userId: String, completion: @escaping (_ snapshotExist: Bool, _ addresses: [Address]?)-> Void) {
        
        usersRef.child(userId).child("addresses").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let addressArray = (snapshot.value as! NSDictionary).allKeys as! [String]
                var addresses: [Address] = []
                //get all the address information that matches the ID returned from above query
                addressRef.observeSingleEvent(of: .value, with: { snapshot in
                    for address in snapshot.children {
                        let address = address as! FIRDataSnapshot
                        if addressArray.contains(address.key) {
                            let newItem = Address(snapshot: address)
                            addresses.append(newItem)
                        }
                    }
                    completion(true, addresses)
                })
            } else {
                completion(true, nil)
            }
        })
    }
    
    func getTotalPriceForAllOrders(_ userId: String, completion: @escaping (_ formattedPrice: NSString)-> Void) {
        var totalPrice: CGFloat = 0.0
        loadAllOrderForCurrentUser(userId, completion: { orderedMeal in
            for (index, element) in orderedMeal.enumerated() {
                Helper().loadOrderedMeal(element, completion: { meal in
                    totalPrice += CGFloat(element.numberOfOrder) * meal.mealPrice
                    if index == orderedMeal.count - 1 {
                        let formattedPrice = NSString(format: "%.2f", totalPrice)
                        completion(formattedPrice)
                    }
                })
            }
        })
        /**
        loadAllOrder(completion: { orderedMeal in
            for (index, element) in orderedMeal.enumerated() {
                Helper().loadOrderedMeal(element, completion: { meal in
                    totalPrice += CGFloat(element.numberOfOrder) * meal.mealPrice
                    if index == orderedMeal.count - 1 {
                        let formattedPrice = NSString(format: "%.2f", totalPrice)
                        completion(formattedPrice)
                    }
                })
            }
        })**/
    }
    
    func updateOrderInformation(_ orderKey: String, childName: String, value: AnyObject) {
        let orderRef = ordersRef.child(orderKey).child(childName)
        
        //Update order's information
        if childName == "numberOfOrder" {
            orderRef.setValue(value as! Int)
        } else {
            orderRef.setValue(value as! String)
        }
    }
    
    func updateMealInformation(_ mealId: String, childName: String, value: AnyObject, completion: (()-> Void)?) {
        let mealRef = mealsRef.child(mealId).child(childName)
        
        //Update meal's information
        if childName == "numberOfOrder" || childName == "numberOfUnconfirmedOrder" || childName == "quantity" {
            mealRef.setValue(value as! Int)
        } else if childName == "mealPrice" {
            mealRef.setValue(value as! CGFloat)
        } else {
            mealRef.setValue(value as! String)
        }
        if completion != nil {
            completion!()
        }
    }
    
    func updateUserInformation(_ userId: String, childName: String, value: AnyObject, completion: (()-> Void)?) {
        usersRef.child(userId).child(childName).setValue(value as! String)
        completion!()
    }
    
    func updateShoppingCartButton(_ navigationItem: UINavigationItem, selector: Selector, source: UIViewController!, user: User?, animated: Bool) {
        //verify whether the order contains same mealId with current meal
        if let userId = user?.userId {
            loadAllOrderForCurrentUser(userId, completion: { orderedMeal in
                self.createBadgeLabel(orderedMeal, navigationItem: navigationItem, selector: selector, source: source, user: user, animated: animated)
            })
        }
    }
    
    func createBadgeLabel(_ orderedMeal: [Order], navigationItem: UINavigationItem, selector: Selector, source: UIViewController!, user: User?, animated: Bool) {
        //create shopping cart bar button
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 30))
        rightButton.setBackgroundImage(UIImage(named: "Shopping cart")?.withRenderingMode(.alwaysTemplate), for: .normal)
        rightButton.addTarget(source, action: selector, for: .touchUpInside)
        rightButton.tintColor = .white
        
        let unconfirmedOrder = getOngoingOrderArray(orderedMeal)
        if unconfirmedOrder.count != 0 && user != nil {
            //create a badge label
            var totalOrder = 0
            for item in unconfirmedOrder {
                totalOrder += item.numberOfOrder
            }
            
            let label = Helper().createLabel(x: 17, y: 3, width: 15, height: 15, textAlignment: .center, labelText: String(totalOrder), textColor: .white)
            label.layer.borderColor = UIColor.clear.cgColor
            label.layer.borderWidth = 2
            label.layer.cornerRadius = label.bounds.size.height / 2
            label.layer.masksToBounds = true
            label.font = UIFont(name: "AppleSDGothicNeo-RegularLight", size: 13)
            label.backgroundColor = .red
            rightButton.addSubview(label)
            
            if animated {
                //create animation for shopping cart button
                //make the shopping cart bar button smaller by applying scale transformation
                rightButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                
                //use spring style animation that resets the button to its initial state
                UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0,
                               options: .allowUserInteraction, animations: {
                                rightButton.transform = .identity
                }, completion: nil)
            }
            rightButton.addSubview(label)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
    }
    
    func getOngoingOrderArray(_ orderedMeal: [Order]) -> [Order] {
        var order = [Order]()
        for item in orderedMeal {
            if item.orderStatus == OrderStatus.ongoing {
                order.append(item)
            }
        }
        return order
    }
    
    func loadAddress(_ addressId: String, completion: @escaping (_ address: Address)-> Void) {
        addressRef.child(addressId).observeSingleEvent(of: .value, with: { snapshot in
            let address = Address(snapshotValue: snapshot.value as! [String: AnyObject], addressId: addressId)
            completion(address)
        })
    }
    
    func loadUser(_ userId: String, completion: @escaping (_ user: User, _ snapshotValue: [String: AnyObject])-> Void) {
        usersRef.child(userId).observeSingleEvent(of: .value, with: { snapshot in
            let user = User(snapshotValue: snapshot.value as! [String: AnyObject], userId: userId)
            completion(user, snapshot.value as! [String: AnyObject])
        })
    }
    
    func loadOrderedMeal(_ order: Order, completion: @escaping (_ meal: Meal)-> Void) {
        mealsRef.child(order.mealId).observeSingleEvent(of: .value, with: { snapshot in
            let meal = Meal(snapshotValue: snapshot.value as! [String: AnyObject], mealId: order.mealId)
            completion(meal)
        })
    }
    
    func loadOrder(_ orderId: String, completion: @escaping (_ order: Order)-> Void) {
        ordersRef.child(orderId).observeSingleEvent(of: .value, with: { snapshot in
            let order = Order(snapshotValue: snapshot.value as! [String: AnyObject], orderId: orderId)
            completion(order)
        })
    }
    
    func loadMealInformation(_ mealId: String, childrenName: String, completion: ((_ value: Any)-> Void)?) {
        mealsRef.child(mealId).child(childrenName).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? Any {
                completion!(value)
            }
        })
    }
    
    func loadUserInformation(_ userId: String, childrenName: String, completion: @escaping (_ value: Any)-> Void) {
        usersRef.child(userId).child(childrenName).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? Any {
                completion(value)
            }
        })
    }
    
    func loadOrderInformation(_ orderId: String, childrenName: String, completion: @escaping (_ value: Any)-> Void) {
        ordersRef.child(orderId).child(childrenName).observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value {
                completion(value)
            }
        })
    }
    
    
    func loadAllMealListing(_ userId: String, completion: @escaping (_ meals: [Meal])-> Void) {
        
        usersRef.child(userId).child("listing").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                let mealIdArray = (snapshot.value as! NSDictionary).allKeys as! [String]
            
                var newItems: [Meal] = []
                var userIdItems: [String] = []
                
                //get all the meal information that matches the ID returned from above query
                mealsRef.observeSingleEvent(of: .value, with: { snapshot in
                    for meal in snapshot.children {
                        let meal = meal as! FIRDataSnapshot
                        
                        if mealIdArray.contains(meal.key) {
                            let newItem = Meal(snapshot: meal)
                            let snapshotValue = meal.value as! [String: AnyObject]
                            
                            if let cookId = snapshotValue["cook"] as? String {
                                userIdItems.append(cookId)
                            }
                            newItems.append(newItem)
                        }
                    }
                    
                    if newItems.count != 0 {
                        self.fetchUser(newItems, userIdItems: userIdItems, completion: completion)
                    } else {
                        completion(newItems)
                    }
                })
            }
        })
    }
    
    func fetchUser(_ newItems: [Meal], userIdItems: [String], completion: @escaping (_ newItems: [Meal])-> Void) {
        for (index, element) in newItems.enumerated() {
            self.loadUser(userIdItems[index], completion: { user, snapshotValue in
                element.cook = user
                if index == newItems.count - 1 {
                    completion(newItems)
                }
            })
        }
    }
    
    func loadAllOrderForCurrentUser(_ userId: String, completion: @escaping (_ orderedMeal: [Order])-> Void) {
        ordersRef.observeSingleEvent(of: .value, with: { snapshot in
            var orderedMeal: [Order] = []
            for order in snapshot.children {
                let orderedItem = Order(snapshot: order as! FIRDataSnapshot)
                if orderedItem.orderedBy == userId {
                    orderedMeal.append(orderedItem)
                }
            }
            completion(orderedMeal)
        })
    }
    
    func loadAllOrder(completion: @escaping (_ orderedMeal: [Order])-> Void) {
        ordersRef.observeSingleEvent(of: .value, with: { snapshot in
            var orderedMeal: [Order] = []
            for order in snapshot.children {
                let orderedItem = Order(snapshot: order as! FIRDataSnapshot)
                orderedMeal.append(orderedItem)
            }
            completion(orderedMeal)
        })
    }
   
    func setUserPhoto(_ photo: UIImageView!, userId: String) {
        let childPath = "\("UserPhotos")/\(userId)"
        StorageService.getPhoto(photo, childPath: childPath)
    }
    
    func setMealPhoto(_ photo: UIImageView!, mealId: String) {
        let childPath = "\("MealPhotos")/\(mealId)"
        StorageService.getPhoto(photo, childPath: childPath)
    }
    
    func setIngredientPhoto(_ photo: UIImageView!, name: String) {
        let childPath = "\("IngredientPhotos")/\(name)"
        StorageService.getPhoto(photo, childPath: childPath)
    }
    
    func createPickerView(_ controller: UIViewController!, textField: UITextField!) -> UIPickerView! {
        let pickerView = UIPickerView()
        pickerView.delegate = controller as? UIPickerViewDelegate
        textField.inputView = pickerView
        return pickerView
    }
    
    
    func createDatePickerView(_ controller: UIViewController!, textField: UITextField!, selector: Selector, completion:
        ((_ pickerView: UIDatePicker)-> Void)?) -> UIDatePicker! {
        let pickerView = UIDatePicker()
        pickerView.addTarget(controller, action: selector, for: .valueChanged)
        if let completion = completion {
            completion(pickerView)
        }
        textField.inputView = pickerView
        return pickerView
    }
    
    func createLabel(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, textAlignment: NSTextAlignment, labelText: String, textColor: UIColor) -> UILabel {
        let label = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
        label.textAlignment = textAlignment
        label.textColor = textColor
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20)
        label.text = labelText
        return label
    }
    
    func createImageViewForEmptyScreen(_ imageName: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.frame = CGRect(x: x, y: y, width: width, height: height)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    func createFilterViewForEmptyScreen(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIView {
        let layerView = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        layerView.backgroundColor = UIColor().hexStringToUIColor(hexString: "#996A5A", alpha: 0.5)
        return layerView
    }
    
    func displayAlertMessage(_ controller: UIViewController, messageToDisplay: String, completionHandler: ((UIAlertAction)-> Void)?) {
        let alertController = UIAlertController(title: "Gusto Deli", message: messageToDisplay, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: completionHandler))
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func displayAccessCameraAlertMessage(_ controller: UIViewController, imagePickerController: UIImagePickerController) {
        let alert = UIAlertController(title: "Gusto Deli", message: "Choose photo", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take picture", style: .default, handler: { action in
            self.openCamera(controller, imagePickerController: imagePickerController)
        }))
        alert.addAction(UIAlertAction(title: "Picture Galery", style: .default, handler: { action in
            imagePickerController.sourceType = .photoLibrary
            controller.present(imagePickerController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(_ controller: UIViewController, imagePickerController: UIImagePickerController) {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            imagePickerController.sourceType = .camera
            controller.present(imagePickerController, animated: true, completion: nil)
        } else {
            displayAlertMessage(controller, messageToDisplay: "There is no camera in this device.", completionHandler: nil)
        }
    }
    
    func createToolbar(_ withCancelButton: Bool, doneSelector: Selector, cancelSelector: Selector?) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = .blackTranslucent
        toolBar.barTintColor = .white
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: doneSelector)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: cancelSelector)
        
        if withCancelButton {
            toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        } else {
            toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        }
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    func createToolbarWithText(_ text: String, doneSelector: Selector, frameSize: CGSize) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = .blackTranslucent
        toolBar.barTintColor = .white
        toolBar.sizeToFit()
        
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: doneSelector)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frameSize.width/2 + 100,
                                          height: frameSize.height))
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        label.backgroundColor = .clear
        label.textColor = .blue
        label.text = text
        label.textAlignment = .center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([textBtn, flexSpace, okBarBtn], animated: true)
        return toolBar
    }
    
    func adjustingHeight(_ show:Bool, notification: Notification, scrollView: UIScrollView) {
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let changeInHeight = (keyboardFrame.height + 40) * (show ? 1 : -1)
        scrollView.contentInset.bottom += changeInHeight
        scrollView.scrollIndicatorInsets.bottom += changeInHeight
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    
    func loadImageWithCacheWithUrlString(_ urlString: String) {
        
        //Check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) {
            self.image = cachedImage as? UIImage
            return
        }
        
        //Otherwise, fire off a new download
        let url = NSURL(string: urlString)
        let request = URLRequest(url:url! as URL)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
            
            }.resume()
        
    }
    
    func setRoundedBorder() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
    func setBorder() {
        self.layer.cornerRadius = 0
        self.clipsToBounds = true
    }
    
    func setBorderWidthColor(_ borderWidth: CGFloat, borderColor: UIColor!) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
    func addShadowToPriceTag() {
        self.layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
        self.layer.shadowRadius = 2.0
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.masksToBounds = false
    }
}

extension UIVisualEffectView {
    func setRoundedBorder() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true

    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension UITextView {
    func applyPlaceholderStyle(placeholderText: String) {
        self.textColor = UIColor.lightGray
        self.text = placeholderText
    }
    
    func applyNonPlaceholderStyle() {
        self.textColor = UIColor.darkText
        self.alpha = 1.0
    }
    
    func moveCursorToStart() {
        //place cursor at the start of the text view
        DispatchQueue.main.async(execute: {
            self.selectedRange = NSMakeRange(0, 0)
        })
    }
}

extension UITextField {
    func isValidEmailAddress() -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = self.text! as NSString
            let results = regex.matches(in: self.text!, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0 {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        return returnValue
    }
}

extension UINavigationItem {
    func setBlankTitle() {
        self.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.backBarButtonItem!.title = ""
    }
}
extension UINavigationBar {
    func setupThemeColorNavBar() {
        self.barStyle = .blackOpaque
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
        self.barTintColor = .white
        self.tintColor = .white
        self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.backgroundColor = UIColor().themeColor()
    }
}


extension UIView {
    func slideInFromBottom(_ duration: TimeInterval = 0.1, completionDelegate: AnyObject? = nil) {
        let slideInFromBottomTransition = CATransition()
        
        if let delegate: CAAnimationDelegate = completionDelegate as! CAAnimationDelegate? {
            slideInFromBottomTransition.delegate = delegate
        }
        
        slideInFromBottomTransition.type = kCATransitionPush
        slideInFromBottomTransition.subtype = kCATransitionFromTop
        slideInFromBottomTransition.duration = duration
        slideInFromBottomTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromBottomTransition.fillMode = kCAFillModeRemoved
        
        self.layer.add(slideInFromBottomTransition, forKey: "slideInFromBottomTransition")
    }
    
    func putShadowOnView() {
        var shadowFrame = CGRect.zero
        shadowFrame.size.width = 0.0
        shadowFrame.size.height = 0.0
        shadowFrame.origin.x = 0.0
        shadowFrame.origin.y = 0.0
        
        let shadow = UIView(frame: shadowFrame)
        shadow.isUserInteractionEnabled = false
        shadow.layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        shadow.layer.shadowOpacity = 1.0
        shadow.layer.shadowOffset = .zero
        shadow.layer.shadowRadius = 10
        shadow.layer.masksToBounds = false
        shadow.clipsToBounds = false
        
        self.superview?.insertSubview(shadow, belowSubview: self)
        shadow.addSubview(self)
    }
    
    func removeAnimation() {
        UIView.animate(withDuration: 0.25, animations:{
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.alpha = 0.0
        }, completion: { (finished: Bool) in
            if (finished) {
                self.removeFromSuperview()
            }
        })
    }
    
    func showAnimation() {
        self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations:{
            self.alpha = 1.0
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
}

extension UIButton {
    
    func setupButton(imageName: String, source: UIViewController, selector: Selector) {
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        self.setImage(image, for: .normal)
        self.addTarget(source, action: selector, for: .touchUpInside)
    }
    
    func customizeStandardButton() {
        self.layer.cornerRadius = 25
        self.addBottomShadow()
    }
    
    func setBorderWidthColor(_ borderWidth: CGFloat, borderColor: UIColor!, cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
    
    func addShadowToPriceTag() {
        self.layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
    }
    
    func addBottomShadow() {
        //create elliptical shadow for image through UIBezierPath
        let ovalRect = CGRect(x: 0.0, y: self.frame.size.height + 5, width: self.frame.size.width, height: 5)
        
        self.layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 3.0
        self.layer.shadowPath = UIBezierPath(ovalIn: ovalRect).cgPath
    }
    
    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        
        self.imageEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, -insetAmount)
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -insetAmount, 0, insetAmount)
        self.contentEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, insetAmount)
    }
    
    func updateDoneButtonState(_ obj: String) {
        self.isEnabled = !obj.isEmpty
    }
    
    func setWhiteTint(_ imageName: String) {
        let origImage = UIImage(named: imageName)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = .white
    }
}

extension UICollectionViewCell {
    func addShadowToCell() {
        self.contentView.layer.cornerRadius = 20.0
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
}

extension UITableViewCell {
    func addShadowToCell() {
        self.contentView.layer.cornerRadius = 20.0
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
}

extension UIColor {
    func hexStringToUIColor(hexString: String, alpha: CGFloat) -> UIColor {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.characters.count) != 6) {
            return .gray
        }
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat((rgbValue & 0x0000FF)) / 255.0,
            alpha: alpha)
    }
    func themeColor() -> UIColor {
        return UIColor().hexStringToUIColor(hexString: "#FFBE3D", alpha: 1.0)
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
