//
//  AddressDetailViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class AddressDetailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    //MARK:- IBOutlets
    @IBOutlet weak var buildingNameTextField: UITextField!
    @IBOutlet weak var streetNameTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var confirmAddressButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var workButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var otherLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    //MARK:- Properties
    var address: String?
    var organizedAddress: Address?
    var deliveryAddress: String!
    var user: User!
    var checkoutMode = false
    var editMode = false
    var saveAddress = false
    var selectedButton: UIButton?
    var deliveryAddressId: String?
    
    //MARK:- Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func keyboardWillShow(notification: Notification) {
        Helper().adjustingHeight(true, notification: notification, scrollView: scrollView)
    }
    
    func keyboardWillHide(notification: Notification) {
        Helper().adjustingHeight(false, notification: notification, scrollView: scrollView)
    }

    override func viewWillAppear(_ animated: Bool) {
        scrollViewTopConstraint.constant = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.size.height
        self.navigationItem.setBlankTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    //MARK:- Action
    @IBAction func tappedConfirmAddressButton(_ sender: Any) {
        if let button = sender as? UIButton, button == confirmAddressButton {
            let buildingNameText = buildingNameTextField.text ?? ""
            let streetNameText = streetNameTextField.text ?? ""
            let zipCodeText = zipCodeTextField.text ?? ""
            let cityText = cityTextField.text ?? ""
            
            if !(buildingNameText.isEmpty || streetNameText.isEmpty || zipCodeText.isEmpty || cityText.isEmpty || selectedButton == nil) {
                performLeaveScreenAction()
            } else {
                Helper().displayAlertMessage(self, messageToDisplay: "Please complete your information.", completionHandler: nil)
            }
        }
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if selectedButton != nil {
            selectedButton?.isSelected = false
            if selectedButton == homeButton {
                homeLabel.textColor = .black
            } else if selectedButton == workButton {
                workLabel.textColor = .black
            } else {
                otherLabel.textColor = .black
            }
        }
        sender.isSelected = true
        selectedButton = sender
        if sender == homeButton {
            homeLabel.textColor = UIColor().themeColor()
        } else if sender == workButton {
            workLabel.textColor = UIColor().themeColor()
        } else {
            otherLabel.textColor = UIColor().themeColor()
        }
    }
    
    //MARK:- Private
    fileprivate func performLeaveScreenAction() {
        if checkoutMode {
            
            //prompt action sheet asking user whether to save the address
            let alert = UIAlertController(title: "Gusto Deli", message: "Save the new address into your Address Book?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Save Address", style: .default, handler: { action in
                self.saveAddress = true
                self.performSegue(withIdentifier: "deliveryAddress", sender: self)
            }))
            
            alert.addAction(UIAlertAction(title: "Don't Save", style: .default, handler: { action in
                self.saveAddress = false
                self.performSegue(withIdentifier: "deliveryAddress", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)

        } else if editMode {
            let alert = UIAlertController(title: "Gusto Deli", message: "Save the new address into your Address Book?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Save Address", style: .default, handler: { action in
                self.saveAddress = true
                self.performSegue(withIdentifier: "editOrder", sender: self)
            }))
            
            alert.addAction(UIAlertAction(title: "Don't Save", style: .default, handler: { action in
                self.saveAddress = false
                self.performSegue(withIdentifier: "editOrder", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "insertUpdateAddress", sender: self)
        }
    }
    
    @objc fileprivate func tappedDone() {
        if let zipCodeTest = zipCodeTextField.text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "") {
            //check zip code format
            if zipCodeTest.characters.count != 5 {
                Helper().displayAlertMessage(self, messageToDisplay: "Please insert correct zip code for the delivery address.", completionHandler: nil)
            } else {
                view.endEditing(true)
                if (cityTextField.text?.isEmpty)! {
                    cityTextField.becomeFirstResponder()
                }
            }
        }
        
    }
    
    fileprivate func setTintedImage(_ button: UIButton, imageName: String) {
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .selected)
        button.tintColor = UIColor().themeColor()
    }
    
    fileprivate func setupUI(){
        homeButton.addBottomShadow()
        workButton.addBottomShadow()
        otherButton.addBottomShadow()
        
        setTintedImage(homeButton, imageName: "Home icon")
        setTintedImage(workButton, imageName: "Work icon")
        setTintedImage(otherButton, imageName: "Other location icon")
        
        zipCodeTextField.inputAccessoryView = Helper().createToolbar(false, doneSelector: #selector(tappedDone), cancelSelector: nil)
        
        buildingNameTextField.text = "B-9-1, Kiara Jalil Residence 1"
        streetNameTextField.text = "Jalan 3/155"
        zipCodeTextField.text = "58200"
        cityTextField.text = "Bukit Jalil"
        
        confirmAddressButton.customizeStandardButton()
        
        if address != nil {
            var arr: [String] = (address!.components(separatedBy: ", "))
            
            //make sure the address does not have building name
            if arr[0].lowercased().range(of: "jalan") != nil &&
                arr[1].lowercased().range(of: "jalan") != nil {
                buildingNameTextField.text = arr[0]
            } else if arr[0].lowercased().range(of: "jalan") == nil {
                buildingNameTextField.text = arr[0]
            } else {
                streetNameTextField.text = arr[0]
            }
            
            //check if the title is repeated in subtitle. If yes, then omit the second one
            //e.g. Hospital Serdang, Hospital Serdang, Jalan Hospital,....
            if arr[1] == arr[0] {
                arr.remove(at: 1)
            }
            //remove the country element at the end
            arr.remove(at: arr.count - 1)
            
            var count = arr.count - 1
            var found = false
            
            while !found && count != -1 {
                let separatedArr = arr[count].components(separatedBy: " ")
                for i in 0..<separatedArr.count {
                    let zipCodeTest = separatedArr[i].components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
                    if zipCodeTest != "" {
                        //check if the zip code is valid or just a street name
                        if zipCodeTest.characters.count == 5 {
                            zipCodeTextField.text = zipCodeTest
                            var cityString = ""
                            for j in (i+1)..<separatedArr.count {
                                cityString = cityString + " " + separatedArr[j]
                            }
                            if (count + 1) != arr.count {
                                cityString = cityString + ", " + arr[count + 1]
                            }
                            cityTextField.text = cityString
                            found = true
                        } else {
                            //the number is part of a street name
                            if count >= 0 {
                                streetNameTextField.text = arr[count]
                                var cityString = arr[count + 1]
                                if (count + 1) != arr.count {
                                    for j in (count + 2)..<arr.count {
                                        cityString = cityString + ", " + arr[j]
                                    }
                                }
                                cityTextField.text = cityString
                                found = true
                                count = -1
                            }
                        }
                    }
                }
                if !found {
                    count -= 1
                }
            }
            if count >= 0 && count < arr.count {
                if (count - 1) >= 1 {
                    var temp = arr[1]
                    for i in 2..<count {
                        temp = temp + ", " + arr[i]
                    }
                    streetNameTextField.text = temp
                } else {
                    streetNameTextField.text = arr[(count - 1)]
                }
            }
            
            //handle if zipcode is not found
            if count == -1 {
                if arr.count == 2 {
                    cityTextField.text = arr[1]
                }
            }
        } else if organizedAddress != nil {
            buildingNameTextField.text = organizedAddress?.buildingName
            streetNameTextField.text = organizedAddress?.streetName
            if let zipCode = organizedAddress?.zipCode {
                zipCodeTextField.text = String(zipCode)
            }
            cityTextField.text = organizedAddress?.city
        }
    }
    
    fileprivate func getAddressType() -> AddressType {
        if selectedButton == homeButton {
            return AddressType.Home
        } else if selectedButton == workButton {
            return AddressType.Work
        } else {
            return AddressType.Other
        }
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField == buildingNameTextField {
            if !(buildingNameTextField.text?.isEmpty)! {
                streetNameTextField.becomeFirstResponder()
            }
        } else if textField == streetNameTextField {
            if !(streetNameTextField.text?.isEmpty)! {
                zipCodeTextField.becomeFirstResponder()
            }
        } else if textField == zipCodeTextField {
            if !(zipCodeTextField.text?.isEmpty)! {
                cityTextField.becomeFirstResponder()
            }
        }
        return true
    }
    
    fileprivate func createAddress() -> Address {
        return Address(addressType: AddressType(rawValue: getAddressType().rawValue)!, buildingName: buildingNameTextField.text ?? "", streetName: streetNameTextField.text ?? "", zipCode: Int(zipCodeTextField.text!)!, city: cityTextField.text ?? "")
    }
    
    fileprivate func constructAddressString() {
        deliveryAddress = buildingNameTextField.text! + ", "
        deliveryAddress = deliveryAddress! + streetNameTextField.text! + ", " + zipCodeTextField.text! + ", " + cityTextField.text!
    }

    fileprivate func saveAddressIdToUser(_ userId: String, addressRefKey: String) {
        let userRef = FIRDatabase.database().reference().child("Users").child(userId).child("addresses").child(addressRefKey)
        userRef.setValue(true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deliveryAddress" {
            guard segue.destination is CheckoutViewController else {
                fatalError("Unknown destination for segue deliveryAddress: \(segue.destination)")
            }
            
            constructAddressString()
            //update existing address for current user into Firebase
            let addressRef = FIRDatabase.database().reference().child("addresses").childByAutoId()
            if saveAddress {
                saveAddressIdToUser(user.userId, addressRefKey: addressRef.key)
            }
            //save new address for current user into Firebase
            addressRef.setValue(createAddress().toAnyObject())
            deliveryAddressId = addressRef.key

        } else if segue.identifier == "insertUpdateAddress" {
            guard let controller = segue.destination as? SavedAddressViewController else {
                fatalError("Unknown destination for segue addAddressDetail: \(segue.destination)")
            }
            
            var addressRef: FIRDatabaseReference
            if organizedAddress != nil {
                //update existing address for current user into Firebase
                addressRef = FIRDatabase.database().reference().child("addresses").child((organizedAddress?.id)!)
            } else {
                addressRef = FIRDatabase.database().reference().child("addresses").childByAutoId()
                saveAddressIdToUser(user.userId, addressRefKey: addressRef.key)
            }
            
            //save new address for current user into Firebase
            addressRef.setValue(createAddress().toAnyObject())
            controller.user = user
        } else if segue.identifier == "editOrder" {
            guard segue.destination is OrderSummaryViewController else {
                fatalError("Unknown destination for segue editOrder: \(segue.destination)")
            }
            constructAddressString()
            /**
            if saveAddress {
                let addressCount = controller.user.addresses.count
                controller.user.addresses.append(getNewAddress(addressCount, prevAddressesId: 0))
            }**/
        }
    }
    

}
