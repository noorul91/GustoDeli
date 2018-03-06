//
//  AddMealViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class AddMealViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    

    //MARK:- IBOutlets
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mealPhoto: UIImageView!
    @IBOutlet weak var mealPhotoWidth: NSLayoutConstraint!
    @IBOutlet weak var mealPhotoHeight: NSLayoutConstraint!
    @IBOutlet weak var mealPhotoTop: NSLayoutConstraint!
    @IBOutlet weak var mealPhotoLeading: NSLayoutConstraint!
    @IBOutlet weak var blurBackgroundViewHeight: NSLayoutConstraint!
    @IBOutlet weak var blurBackgroundViewWidth: NSLayoutConstraint!
    @IBOutlet weak var blurBackgroundViewTop: NSLayoutConstraint!
    @IBOutlet weak var blurBackgroundViewLeading: NSLayoutConstraint!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var soldOutButton: UIButton!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var blurBackgroundView: UIVisualEffectView!
    
    //MARK:- Properties
    let dateAndTimeFormat = "MMM d, yyyy hh:mm a"
    let dayDateAndTimeFormat = "EEEE, MMM d, yyyy"
    let timeFormat = "hh:mm a"
    var activeTextField: UITextField?
    var mealDict = ["mealname": "", "sideOrder": "", "mealDescription": "", "orderCutOffTime": "", "deliveryTime": "", "deliveryDate": "", "selectedIngredients": "", "category": "", "selfDescription": ""]
    var quantity: Int = 0
    var mealPrice: CGFloat = 0.0
    var mealPhotoSelected = false
    var selectedIng: [String] = []
    var cook: User!
    var quantityPickerView: UIPickerView!
    var cutOffDatePickerView = UIDatePicker()
    var datePickerView = UIDatePicker()
    var timePickerView1 = UIDatePicker()
    var timePickerView2 = UIDatePicker()
    var selectedFromDeliveryTime = Date()
    var selectedDeliveryDate = Date()
    var selectedCutOffTime = Date()
    let imagePickerController = UIImagePickerController()
    var editMode = false
    var meal: Meal?
    var pickerDataSource = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14"]
    var previewButton = UIBarButtonItem()
    var dotButton = UIButton()
    
    //MARK:- Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        scrollViewTopConstraint.constant = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.size.height
        updateDoneButtonState()
        self.navigationItem.setBlankTitle()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK:- Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        if editMode {
            return 3
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 9
        } else if section == 1 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return 164
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "MEAL DETAILS"
        } else if section == 1 {
            return "ABOUT COOK"
        }
        return ""
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EntryTableViewCell
            switch (indexPath.row) {
            case 0:
                cell.mLabel.text = "Meal name:"
                if mealDict["mealname"] != "" {
                    cell.mTextField.text = mealDict["mealname"]?.capitalizingFirstLetter()
                } else {
                    cell.mTextField.placeholder = "Name your meal"
                }
            case 1:
                cell.mLabel.text = "Price:"
                cell.mTextField.placeholder = "Select meal price"
                cell.mTextField.inputAccessoryView = Helper().createToolbar(false, doneSelector: #selector(tappedDone), cancelSelector: nil)
                cell.mTextField.keyboardType = .numberPad
                cell.mTextField.isUserInteractionEnabled = true
                if editMode {
                    if let formattedPrice = meal?.getFormattedMealPrice() {
                        cell.mTextField.text = "RM \(formattedPrice)"
                    }
                } else {
                    if mealPrice != 0.0 {
                        let formattedPrice = NSString(format: "%.2f", mealPrice)
                        cell.mTextField.text = "RM \(formattedPrice)"
                    }
                }
            case 2:
                cell.mLabel.text = "Category:"
                cell.mTextField.placeholder = "Select meal category"
                if editMode {
                    cell.mTextField.text = meal?.category
                } else {
                    
                }
            case 3:
                cell.mLabel.text = "Ingredients:"
                cell.mTextField.placeholder = "Ingredients used"
                if mealDict["selectedIngredients"] != "" {
                    cell.mTextField.text = mealDict["selectedIngredients"]
                }
            case 4:
                cell.mLabel.text = "Quantity available:"
                cell.mTextField.placeholder = "Quantity"
                quantityPickerView = Helper().createPickerView(self, textField: cell.mTextField)
                cell.mTextField.inputAccessoryView = Helper().createToolbarWithText("Select quantity available for this meal.", doneSelector: #selector(donePressedQuantity), frameSize: self.view.frame.size)
                cell.mTextField.isUserInteractionEnabled = true
                if quantity != 0  {
                    cell.mTextField.text = String(quantity)
                }
            case 5:
                cell.mLabel.text = "Order Cut-Off Time:"
                cell.mTextField.placeholder = "Select cut-off time"
                cutOffDatePickerView = Helper().createDatePickerView(self, textField: cell.mTextField, selector: #selector(cutOffPickerValueChanged) , completion: { pickerView in
                    self.setupCutOffDatePickerView(pickerView)
                })
                cell.mTextField.inputAccessoryView = timePickerViewSetup(4)
                cell.mTextField.isUserInteractionEnabled = true
                if editMode {
                    cell.mTextField.text = meal?.orderCutOffTime
                }
                
            case 6:
                cell.mLabel.text = "Delivery Date:"
                
                datePickerView = Helper().createDatePickerView(self, textField: cell.mTextField, selector: #selector(datePickerValueChanged), completion: { pickerView in
                    self.setupDatePickerView(pickerView)
                })
                cell.mTextField.inputAccessoryView = timePickerViewSetup(1)
                if let m = meal {
                    cell.mTextField.text = m.deliveryDate
                } else {
                    cell.mTextField.placeholder = "Delivery date"
                }
                cell.mTextField.isUserInteractionEnabled = true
                
        
            case 7:
                cell.mLabel.text = "Delivery Time Starts:"
                
                timePickerView1 = Helper().createDatePickerView(self, textField: cell.mTextField, selector: #selector(timePicker1ValueChanged), completion: { pickerView in
                    self.setupTimePickerView1(pickerView)
                })
                cell.mTextField.inputAccessoryView = timePickerViewSetup(2)
                cell.mTextField.isUserInteractionEnabled = true
                cell.mTextField.placeholder = "Delivery time starts at"
                if mealDict["deliveryTime"] != "" {
                    if let arr = mealDict["deliveryTime"]?.components(separatedBy: " - ") {
                        cell.mTextField.text = arr[0]
                    }
                }
            default:
                cell.mLabel.text = "Delivery Time Ends:"
                cell.mTextField.placeholder = "Delivery time ends at"
                timePickerView2 = Helper().createDatePickerView(self, textField: cell.mTextField, selector: #selector(timePicker2ValueChanged), completion: { pickerView in
                    self.setupTimePickerView2(pickerView)
                })
                if mealDict["deliveryTime"] != "" {
                    if let arr = mealDict["deliveryTime"]?.components(separatedBy: " - ") {
                        cell.mTextField.text = arr[1]
                    }
                }
                cell.mTextField.inputAccessoryView = timePickerViewSetup(3)
                cell.mTextField.isUserInteractionEnabled = true
            }
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cookCell", for: indexPath) as! AboutCookTableViewCell
                cell.setAttributedTitle = false
                cell.cook = cook
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EntryTableViewCell
                cell.mLabel.text = "Description:"
                if mealDict["selfDescription"] != "" {
                    cell.mTextField.text = mealDict["selfDescription"]
                }
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell", for: indexPath) as! AddressTableViewCell
            cell.photo.image = cell.photo.image?.withRenderingMode(.alwaysTemplate)
            cell.photo.tintColor = .red
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "addMeal", sender: self)
            } else if indexPath.row == 2 {
                performSegue(withIdentifier: "category", sender: self)
            } else if indexPath.row == 3 {
                performSegue(withIdentifier: "addIngredient", sender: self)
            }
        } else if indexPath.section == 1 {
            performSegue(withIdentifier: "addDescription", sender: self)
        } else {
            //prompt alert to confirm deletion
            let alert = UIAlertController(title: "Gusto Deli", message: "Delete this listing?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
                self.performSegue(withIdentifier: "delete", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Don't Delete", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! EntryTableViewCell
        cell.mTextField.text = pickerDataSource[row]
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        
        if textField == getPriceTextField() {
            if (textField.text?.isEmpty)! {
                textField.text = "RM "
            }
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if activeTextField != getDeliveryTimeTextField(false) {
            if activeTextField == getPriceTextField() {
                DispatchQueue.main.async { () -> Void in
                    self.dotButton.isHidden = false
                    let keyboardWindow = UIApplication.shared.windows.last
                    self.dotButton.frame = CGRect(x: 0, y: (keyboardWindow?.frame.size.height)!-53, width: 106, height: 53)
                    keyboardWindow?.addSubview(self.dotButton)
                    keyboardWindow?.bringSubview(toFront: self.dotButton)
                    UIView.animate(withDuration: (((notification.userInfo! as NSDictionary).object(forKey: UIKeyboardAnimationCurveUserInfoKey) as AnyObject).doubleValue)!, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: 0)
                    }, completion: { action in
                        Helper().adjustingHeight(true, notification: notification, scrollView: self.scrollView)
                    })
                }
            } else {
                Helper().adjustingHeight(true, notification: notification, scrollView: self.scrollView)
            }
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        if activeTextField != getDeliveryTimeTextField(false) {
            Helper().adjustingHeight(false, notification: notification, scrollView: self.scrollView)
        }
    }
    
    //MARK:- Private
    fileprivate func constructIngredientsListText(_ selectedIng: [String]) -> String {
        var text = selectedIng[0]
        
        if selectedIng.count > 1 {
            for index in 1..<selectedIng.count {
                text = text + ", " + selectedIng[index]
            }
        }
        return text
    }
    
    fileprivate func setupDatePickerView(_ pickerView: UIDatePicker!) {
        pickerView.datePickerMode = .date
        //delivery date must be at least 2 hours after selected cut off time
        pickerView.minimumDate = Calendar.current.date(byAdding: .hour, value: 2, to: selectedCutOffTime)
        //pickerView date must be the most 1 year after cut off date
        pickerView.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: pickerView.minimumDate!)
    }
    
    fileprivate func setupTimePickerView1(_ pickerView: UIDatePicker!) {
        pickerView.datePickerMode = .time
        pickerView.minuteInterval = 15
        
        //Verify if the cut off date & delivery date is the same. If it is, then set the minimum date
        let order = NSCalendar.current.compare(selectedCutOffTime, to: selectedDeliveryDate, toGranularity: .day)
        switch(order) {
        case .orderedSame:
            pickerView.minimumDate = Calendar.current.date(byAdding: .hour, value: 2, to: selectedCutOffTime)
            selectedFromDeliveryTime = pickerView.minimumDate!
        default:
            break
        }
    }
    
    fileprivate func setupTimePickerView2(_ pickerView: UIDatePicker!) {
        pickerView.datePickerMode = .time
        
        //Set timePickerView2's minimum date to a minute later than timePickerView1's minimum date
        pickerView.minuteInterval = 15
        let minDate = Calendar.current.date(byAdding: .hour, value: 1, to: selectedFromDeliveryTime)
        pickerView.minimumDate = minDate
    }
    
    fileprivate func setupCutOffDatePickerView(_ pickerView: UIDatePicker!) {
        //round off current Date() to nearest 15 minutes interval
        let rightNow = Date()
        let interval = 15
        let nextDiff = interval - Calendar.current.component(.minute, from: rightNow) % interval
        var nextDate = Date()
        if nextDiff == interval {
            nextDate = Calendar.current.date(byAdding: .minute, value: 0, to: rightNow) ?? Date()
        } else {
            nextDate = Calendar.current.date(byAdding: .minute, value: nextDiff, to: rightNow) ?? Date()
        }
        
        //cut off date must be at least 1 hour from now
        pickerView.minimumDate = Calendar.current.date(byAdding: .hour, value: 1, to: nextDate)
        pickerView.minuteInterval = 15
        
        //maximum cut off date will be 1 year from today
        pickerView.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: nextDate)
        if let minDate = pickerView.minimumDate {
            self.mealDict["orderCutOffTime"] = Helper().getFormattedDateString(minDate, format: dateAndTimeFormat)
            selectedCutOffTime = minDate
        }
    }
    
    @objc fileprivate func tappedDone() {
        //validate price format
        if let priceTextField = getPriceTextField() {
            let price = priceTextField.text?.trimmingCharacters(in: CharacterSet(charactersIn: "RM "))
            
            let arr = price?.components(separatedBy: ".")
            if arr?.count != 2 {
                if arr?[0] != "" {
                    priceTextField.text = priceTextField.text! + ".00"
                    if let double = Double(price!) {
                        mealPrice = CGFloat(double)
                    }
                } else {
                    priceTextField.text = ""
                }
                
                view.endEditing(true)
            } else {
                if arr?[1].characters.count != 2 {
                    Helper().displayAlertMessage(self, messageToDisplay: "Please ensure your price format is correct.", completionHandler: nil)
                } else {
                    if let double = Double(price!) {
                        mealPrice = CGFloat(double)
                    }
                    view.endEditing(true)
                }
            }
        }
    }
    
    fileprivate func setupUI() {
        dotButton.setTitle(".", for: UIControlState())
        dotButton.setTitleColor(.black, for: UIControlState())
        dotButton.frame = CGRect(x: 0, y: 163, width: 106, height: 53)
        dotButton.addTarget(self, action: #selector(dotButtonTapped), for: .touchUpInside)
        
        mealDict["selfDescription"] = cook.userDescription
        
        if meal != nil {
            mealDict["mealname"] = (meal?.mealName)!
            mealDict["mealDescription"] = (meal?.mealDescription)!
            mealDict["sideOrder"] = (meal?.mealSideDish)!
            mealDict["deliveryTime"] = (meal?.deliveryTimeRange)!
            mealDict["orderCutOffTime"] = (meal?.orderCutOffTime)!
            mealDict["deliveryDate"] = (meal?.deliveryDate)!
            mealDict["category"] = (meal?.category)!
            mealPrice = (meal?.mealPrice)!
            quantity = (meal?.quantity)!
            selectedIng = (meal?.ingredients)!
        }
        
        if editMode {
            soldOutButton.isHidden = false
            viewBottomConstraint.constant = 100
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        if editMode {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitButtonTapped))
        } else {
            previewButton = UIBarButtonItem(title: "Preview", style: .plain, target: self, action: #selector(previewButtonTapped))
            self.navigationItem.rightBarButtonItem = previewButton
        }
        
        if let photoUrl = meal?.mealPhotoUrl {
            mealPhoto.loadImageWithCacheWithUrlString(photoUrl)
            
            mealPhoto.setBorder()
            
            blurBackgroundViewWidth.constant = 375
            blurBackgroundViewHeight.constant = 247
            blurBackgroundViewLeading.constant = 0
            blurBackgroundViewTop.constant = 0
            blurBackgroundView.layer.cornerRadius = 0
            blurBackgroundView.layer.borderWidth = 0
            
            mealPhotoWidth.constant = 375
            mealPhotoHeight.constant = 247
            mealPhotoTop.constant = 0
            mealPhotoLeading.constant = 0
            viewBottomConstraint.constant += 50
        } else {
            blurBackgroundView.setRoundedBorder()
            blurBackgroundView.layer.borderWidth = 1.0
            blurBackgroundView.layer.borderColor = UIColor().themeColor().cgColor
            mealPhoto.image = mealPhoto.image!.withRenderingMode(.alwaysTemplate)
            mealPhoto.tintColor = UIColor().themeColor()
        }
        
        self.hideKeyboardWhenTappedAround()
        soldOutButton.customizeStandardButton()
        updateDoneButtonState()
    }
    
    @objc fileprivate func dotButtonTapped() {
        if let priceTextField = getPriceTextField() {
            priceTextField.text = priceTextField.text! + "."
        }
    }
    
    @objc fileprivate func getPriceTextField() -> UITextField! {
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EntryTableViewCell
        return cell.mTextField
    }
    
    @objc fileprivate func getDeliveryTimeTextField(_ from: Bool) -> UITextField! {
        var indexPath: IndexPath!
        if from {
            indexPath = IndexPath(row: 7, section: 0)
        } else {
            indexPath = IndexPath(row: 8, section: 0)
        }
        let cell = tableView.cellForRow(at: indexPath) as! EntryTableViewCell
        return cell.mTextField
    }
    
    @objc fileprivate func cancelButtonTapped() {
        activeTextField?.resignFirstResponder()
        
        let alert = UIAlertController(title: "Are you sure you want to cancel your listing?", message: "Photos & details will not be saved.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "I'm Sure", style: .default, handler: { action in
            if self.editMode {
                self.performSegue(withIdentifier: "cancelEdit", sender: self)
            } else {
                self.performSegue(withIdentifier: "cancelnonEdit", sender: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func previewButtonTapped() {
        performSegue(withIdentifier: "preview", sender: self)
    }
    
    @objc fileprivate func submitButtonTapped() {
        //Update only if there's any change done
        
        if let m = meal {
            if m.mealPrice != mealPrice {
                Helper().updateMealInformation(m.mealId, childName: "mealPrice", value: mealPrice as AnyObject, completion: { _ in
                    m.mealPrice = self.mealPrice
                })
            }
            if m.quantity != quantity {
                Helper().updateMealInformation(m.mealId, childName: "quantity", value: quantity as AnyObject, completion: { _ in
                    m.quantity = self.quantity
                })
            }
            updateMealInformation(m, mealDictString: "mealname", childName: "mealName")
            updateMealInformation(m, mealDictString: "sideOrder", childName: "mealSideDish")
            updateMealInformation(m, mealDictString: "mealDescription", childName: "mealDescription")
            updateMealInformation(m, mealDictString: "deliveryDate", childName: "deliveryDate")
            updateMealInformation(m, mealDictString: "deliveryTime", childName: "deliveryTimeRange")
            updateMealInformation(m, mealDictString: "category", childName: "category")
            updateMealInformation(m, mealDictString: "orderCutOffTime", childName: "orderCutOffTime")
            
            //Check user's description
            if cook.userDescription != mealDict["selfDescription"] {
                Helper().updateUserInformation(cook.userId, childName: "userDescription", value: mealDict["selfDescription"] as AnyObject, completion: { _ in
                    self.cook.userDescription = self.mealDict["selfDescription"]
        
                    //Check ingredients item
                    if let match = m.ingredients?.containsSameElements(as: self.selectedIng) {
                        if !match {
                            self.verifyIngredientChanges()
                        } else {
                            self.performSegue(withIdentifier: "submit", sender: self)
                        }
                    }
                })
            } else {
                //Check ingredients item
                if let match = m.ingredients?.containsSameElements(as: self.selectedIng) {
                    if !match {
                        self.verifyIngredientChanges()
                    } else {
                        if self.mealPhotoSelected {
                            self.verifyPhotoChanges(m)
                        } else {
                            self.performSegue(withIdentifier: "submit", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func verifyIngredientChanges() {
        print("verifyIngredientChanges")
        if let meal = meal {
            //Remove exisiting ingredients
            let ingredientRef = FIRDatabase.database().reference().child("Meals").child(meal.mealId).child("ingredients")
            ingredientRef.removeValue { (error, ref) in
                if error != nil {
                    print("error \(String(describing: error))")
                } else {
                    meal.ingredients = self.selectedIng
                    //Successfully deleted existing ingredients
                    //Save newly selected ingredients
                    for item in self.selectedIng {
                        ingredientRef.child(item).setValue(true)
                    }
                    if self.mealPhotoSelected {
                        self.verifyPhotoChanges(meal)
                    } else {
                        self.performSegue(withIdentifier: "submit", sender: self)
                    }
                }
            }
        }
    }
    
    fileprivate func verifyPhotoChanges(_ meal: Meal) {
        print("verifyPhotoChanges")
        //Clean up existing meal photo url directory
        let imageRef = FIRStorage.storage().reference(forURL: meal.mealPhotoUrl)
        imageRef.delete(completion: { error in
            if let error = error {
                print("error: \(error)")
            }
            //Successfully deleted previous photo from Firebase, so we upload the new meal photo to storage
            PostService.create(for: self.mealPhoto.image!, childPath: "\("MealPhotos")/\(meal.mealId)", completion: {urlString in
                
                Helper().updateMealInformation(meal.mealId, childName: "mealPhotoUrl", value: urlString as AnyObject, completion: {_ in
                    self.meal?.mealPhotoUrl = urlString
                    //Prompt message saying that listing will be reviewed.
                    Helper().displayAlertMessage(self, messageToDisplay: "Your revised listing has been submitted.", completionHandler: { action in
                        self.performSegue(withIdentifier: "submit", sender: self)
                    })
                })
            })
        })
    }
    
    @objc fileprivate func datePickerValueChanged(sender: UIDatePicker) {
        setDeliveryDate(sender)
    }
    
    @objc fileprivate func cutOffPickerValueChanged(_ sender: UIDatePicker) {
        selectedCutOffTime = sender.date
        mealDict["orderCutOffTime"] = Helper().getFormattedDateString(sender.date, format: dateAndTimeFormat)
    }
    
    fileprivate func setDeliveryDate(_ sender: UIDatePicker) {
        let cell = tableView.cellForRow(at: IndexPath(row: 6, section: 0)) as! EntryTableViewCell
        let formattedDate = Helper().getFormattedDateString(sender.date, format: dayDateAndTimeFormat)
        
        selectedDeliveryDate = sender.date
        cell.mTextField.text = formattedDate
        if let m = meal {
            m.deliveryDate = formattedDate
        }
        mealDict["deliveryDate"] = formattedDate
    }
    
    @objc fileprivate func timePicker1ValueChanged(sender: UIDatePicker) {
        setDeliveryTimeFrom(sender)
    }
    
    fileprivate func setDeliveryTimeFrom(_ sender: UIDatePicker) {
        getDeliveryTimeTextField(true).text = Helper().getFormattedDateString(sender.date, format: timeFormat)
        selectedFromDeliveryTime = sender.date
        tableView.reloadRows(at: [IndexPath(row: 8, section: 0)], with: .bottom)
    }
    
    @objc fileprivate func timePicker2ValueChanged(sender: UIDatePicker) {
        setDeliveryTimeTo(sender)
    }
    
    fileprivate func setDeliveryTimeTo(_ sender: UIDatePicker) {
        getDeliveryTimeTextField(false).text = Helper().getFormattedDateString(sender.date, format: timeFormat)
    }
    
    fileprivate func timePickerViewSetup(_ forToolBar: Int) -> UIToolbar {
        if forToolBar == 1 {
            return Helper().createToolbarWithText("Select available delivery date", doneSelector: #selector(donePressedDeliveryDate), frameSize: self.view.frame.size)
        } else if forToolBar == 2 {
            return Helper().createToolbarWithText("Delivery available from...", doneSelector: #selector(donePressedFromDeliveryTime), frameSize: self.view.frame.size)
        } else if forToolBar == 3 {
            return Helper().createToolbarWithText("Delivery available until...", doneSelector: #selector(donePressedToDeliveryTime), frameSize: self.view.frame.size)
        } else {
            return Helper().createToolbarWithText("Select cut off time for your order.", doneSelector: #selector(donePressedCutOffTime), frameSize: self.view.frame.size)
        }
    }
    
    @objc fileprivate func donePressedQuantity(_ sender: UIBarButtonItem) {
        var cell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! EntryTableViewCell
        if (cell.mTextField.text?.isEmpty)! {
            cell.mTextField.text = "1"
        }
        if let selectedQuantity = cell.mTextField.text {
            quantity = Int(selectedQuantity)!
        }
        cell.mTextField.resignFirstResponder()
        cell = tableView.cellForRow(at: IndexPath(row: 5, section: 0)) as! EntryTableViewCell
        if (cell.mTextField.text?.isEmpty)! {
            cell.mTextField.becomeFirstResponder()
        }
    }
    
    @objc fileprivate func donePressedCutOffTime(_ sender: UIBarButtonItem) {
        var cell = tableView.cellForRow(at: IndexPath(row: 5, section: 0)) as! EntryTableViewCell
        cell.mTextField.text = mealDict["orderCutOffTime"]
        cell.mTextField.resignFirstResponder()
        cell = tableView.cellForRow(at: IndexPath(row: 6, section: 0)) as! EntryTableViewCell
        if (cell.mTextField.text?.isEmpty)! {
            cell.mTextField.becomeFirstResponder()
        }
    }
    
    @objc fileprivate func donePressedDeliveryDate(_ sender: UIBarButtonItem) {
        setDeliveryDate(datePickerView)
        
        let cell1 = tableView.cellForRow(at: IndexPath(row: 6, section: 0)) as! EntryTableViewCell
        cell1.mTextField.resignFirstResponder()
        if let deliveryTimeFromField = getDeliveryTimeTextField(true) {
            if (deliveryTimeFromField.text?.isEmpty)! {
                deliveryTimeFromField.becomeFirstResponder()
            }
        }
        updateDoneButtonState()
    }
    
    @objc fileprivate func donePressedFromDeliveryTime(_ sender: UIBarButtonItem) {
        setDeliveryTimeFrom(timePickerView1)
        if let deliveryTimeFromField = getDeliveryTimeTextField(true) {
            mealDict["deliveryTime"] = deliveryTimeFromField.text!
            if let m = meal {
                m.deliveryTimeRange = mealDict["deliveryTime"]
            }
        }
        getDeliveryTimeTextField(true).resignFirstResponder()
        getDeliveryTimeTextField(false).becomeFirstResponder()
        updateDoneButtonState()
    }
    
    @objc fileprivate func donePressedToDeliveryTime(_ sender: UIBarButtonItem) {
        setDeliveryTimeTo(timePickerView2)
        if let deliveryTimeToField = getDeliveryTimeTextField(false) {
            if let arr = mealDict["deliveryTime"]?.components(separatedBy: " - ") {
                if arr.count != 1 {
                    mealDict["deliveryTime"] = arr[0] + " - " + deliveryTimeToField.text!
                } else {
                    mealDict["deliveryTime"] = mealDict["deliveryTime"]! + " - " + deliveryTimeToField.text!
                }
            }
            if let m = meal {
                m.deliveryTimeRange = mealDict["deliveryTime"]
            }
            getDeliveryTimeTextField(false).resignFirstResponder()
            updateDoneButtonState()
        }
    }
    
    fileprivate func updateDoneButtonState() {
        previewButton.isEnabled = !( mealDict["mealname"] == "" || mealPrice == 0.0 ||  mealDict["mealDescription"] == "" || mealDict["deliveryDate"] == "" || mealDict["deliveryTime"] == "" || mealDict["selectedIngredients"] == "" || !mealPhotoSelected)
    }
    
    fileprivate func updateMealInformation(_ meal: Meal, mealDictString: String, childName: String) {
        Helper().updateMealInformation(meal.mealId, childName: childName, value: mealDict[mealDictString] as AnyObject, completion: { _ in
            if mealDictString == "mealname" {
                if meal.mealName != self.mealDict[mealDictString] {
                    meal.mealName = self.mealDict[mealDictString]
                }
            } else if mealDictString == "sideOrder" {
                if meal.mealSideDish != self.mealDict[mealDictString] {
                    meal.mealSideDish = self.mealDict[mealDictString]
                }
            } else if mealDictString == "mealDescription" {
                if meal.mealDescription != self.mealDict[mealDictString] {
                    meal.mealDescription = self.mealDict[mealDictString]
                }
            } else if mealDictString == "deliveryDate" {
                if meal.deliveryDate != self.mealDict[mealDictString] {
                    meal.deliveryDate = self.mealDict[mealDictString]
                }
            } else if mealDictString == "deliveryTime" {
                if meal.deliveryTimeRange != self.mealDict[mealDictString] {
                    meal.deliveryTimeRange = self.mealDict[mealDictString]
                }
            } else if mealDictString == "category" {
                if meal.category != self.mealDict[mealDictString] {
                    meal.category = self.mealDict[mealDictString]
                }
            } else {
                if meal.orderCutOffTime != self.mealDict[mealDictString] {
                    meal.orderCutOffTime = self.mealDict[mealDictString]
                }
            }
        })
    }
    
    //MARK:- Action
    @IBAction func unwindToAddMealVC(_ sender: UIStoryboardSegue) {
        if let source = sender.source as? MealInfoViewController {
            mealDict["mealname"] = source.mealname.capitalizingFirstLetter()
            mealDict["sideOrder"] = source.sideOrder
            mealDict["mealDescription"] = source.mealDescription
            
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EntryTableViewCell
            cell.mTextField.text = mealDict["mealname"]
            tableView.reloadData()
            updateDoneButtonState()
        }
    }
    
    @IBAction func unwindToAddMealFromIngVC(_ sender: UIStoryboardSegue) {
        if let source = sender.source as? IngredientsViewController {
            
            selectedIng = source.selectedIngredients
            mealDict["selectedIngredients"] = constructIngredientsListText(selectedIng)
            
            let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! EntryTableViewCell
            cell.mTextField.text = mealDict["selectedIngredients"]
            tableView.reloadData()
            updateDoneButtonState()
        }
    }
    
    @IBAction func unwindToAddMealFromCookDescriptionVC(_ sender: UIStoryboardSegue) {
        if let source = sender.source as? CookDescriptionViewController {
            let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! EntryTableViewCell
            let capitalizedDescription = source.cookDescription.capitalizingFirstLetter()
            cell.mTextField.text = capitalizedDescription
            mealDict["selfDescription"] = capitalizedDescription
            tableView.reloadData()
            updateDoneButtonState()
        }
    }
    
    @IBAction func unwindFromCategoryVC(_ sender: UIStoryboardSegue) {
        if let sourceVC = sender.source as? CategoryViewController {
            mealDict["category"] = sourceVC.selectedCategory
            let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! EntryTableViewCell
            cell.mTextField.text = sourceVC.selectedCategory
        }
    }
    
    @IBAction func tappedPhotoIcon(_ sender: UITapGestureRecognizer) {
        activeTextField?.resignFirstResponder()
        imagePickerController.delegate = self
        Helper().displayAccessCameraAlertMessage(self, imagePickerController: imagePickerController)
    }
    
    @IBAction func tappedSoldButton(_ sender: UIButton) {
        //prompt alert to confirm sold out
        let alert = UIAlertController(title: "Confirm Mark as Sold?", message: "You will no longer receive offers for the listing after marked as SOLD.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Mark as Sold", style: .default, handler: { action in
            self.performSegue(withIdentifier: "soldOut", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        mealPhoto.image = selectedImage
        blurBackgroundViewWidth.constant = 375
        blurBackgroundViewHeight.constant = 247
        blurBackgroundViewLeading.constant = 0
        blurBackgroundViewTop.constant = 0
        blurBackgroundView.layer.cornerRadius = 0
        blurBackgroundView.layer.borderWidth = 0
        
        mealPhotoWidth.constant = 375
        mealPhotoHeight.constant = 247
        mealPhotoTop.constant = 0
        mealPhotoLeading.constant = 0
        viewBottomConstraint.constant += 50
        mealPhotoSelected = true
        updateDoneButtonState()
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addMeal" {
            guard let controller = segue.destination as? MealInfoViewController else {
                fatalError("Unknown destination for segue addMeal: \(segue.destination)")
            }
            if mealDict["mealname"] != "" {
                controller.mealname = mealDict["mealname"]!
            }
            if mealDict["sideOrder"] != "" {
                controller.sideOrder = mealDict["sideOrder"]!
            }
            if mealDict["mealDescription"] != "" {
                controller.mealDescription = mealDict["mealDescription"]!
            }
        } else if segue.identifier == "addIngredient" {
            guard let controller = segue.destination as? IngredientsViewController else {
                fatalError("Unknown destination for segue addIngredient: \(segue.destination)")
            }
            controller.selectedIngredients = selectedIng
            
        } else if segue.identifier == "addDescription" {
            guard let controller = segue.destination as? CookDescriptionViewController else {
                fatalError("Unknown destination for segue addDescription: \(segue.destination)")
            }
            
            if let description = mealDict["selfDescription"] {
                controller.cookDescription = description
            }
            controller.sourceVC = self
        }else if segue.identifier == "preview" {
            print("preview segue")
            guard let controller = segue.destination as? GustoViewController else {
                fatalError("Unknown destination for segue preview: \(segue.destination)")
            }
            let meal = Meal(mealName: mealDict["mealname"], mealDescription: mealDict["mealDescription"], mealSideDish: mealDict["sideOrder"], quantity: quantity, mealPrice: mealPrice, orderCutOffTime: mealDict["orderCutOffTime"], deliveryDate: mealDict["deliveryDate"],  deliveryTimeRange: mealDict["deliveryTime"], category: mealDict["category"], ingredients: selectedIng, cook: cook)!
          
            meal.mealPhoto = mealPhoto.image
            controller.meal = meal
            controller.mode = GustoViewController.Mode.Preview
            controller.user = cook
        } else if segue.identifier == "soldOut" {
            guard let controller = segue.destination as? ListingViewController else {
                fatalError("Unknown destination for segue soldOut: \(segue.destination)")
            }
            /**
            let keyArrays = Array(cook.meals.keys)
            for i in keyArrays {
                if i.mealId == meal?.mealId {
                    i.soldOut = true
                }
            }**/
            controller.user = cook
        } else if segue.identifier == "delete" {
            guard let controller = segue.destination as? ListingViewController else {
                fatalError("Unknown destination for segue delete: \(segue.destination)")
            }
            /**
            let keyArrays = Array(cook.meals.keys)
            for i in keyArrays {
                if i.mealId == meal?.mealId {
                    cook.meals.removeValue(forKey: i)
                }
            }**/
            controller.user = cook
        } else if segue.identifier == "category" {
            guard let controller = segue.destination as? CategoryViewController else {
                fatalError("Unknown destination for segue category: \(segue.destination)")
            }
            if mealDict["category"] != "" {
                controller.selectedCategory = mealDict["category"]!
            }
        }
        
    }

}
