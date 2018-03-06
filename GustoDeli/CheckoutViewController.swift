//
//  CheckoutViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/16/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class CheckoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkoutButton: UIButton!
    
    //MARK:- Properties
    var selectedOrder = [Order]()
    var user: User!
    var activeTextField: UITextField?
    
    //MARK:- Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        scrollViewTopConstraint.constant = UIApplication.shared.statusBarFrame.size.height
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        checkoutButton.customizeStandardButton()

        Helper().loadAllOrderForCurrentUser(user.userId, completion: { selectedOrder in
            self.selectedOrder = selectedOrder
            self.collectionView.reloadData()
            self.tableView.reloadData()
        })
    }
    
    //MARK:- UICollectionViewDataSource protocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedOrder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summaryCell", for: indexPath) as! OrderCollectionViewCell
        cell.source = self
        cell.order = selectedOrder[indexPath.item]
        return cell
    }
    
    //MARK:- Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 2
        } else if section == 0 {
            return 5
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "YOUR DETAILS"
        } else if section == 1 {
            return "PAYMENT OPTIONS"
        } else if section == 2 {
            return "PAYMENT SUMMARY"
        }
        return ""
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 10
        }
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as! TextFieldTableViewCell
            
            if indexPath.row == 0 {
                cell.mTextField.placeholder = "Name"
                cell.mTextField.text = user.userName
            } else if indexPath.row == 1 {
                cell.mTextField.placeholder = "Phone Number (in case of emergency)"
                cell.mTextField.inputAccessoryView = Helper().createToolbar(false, doneSelector: #selector(tappedDone), cancelSelector: nil)
                cell.mTextField.keyboardType = .numberPad
                cell.mTextField.tag = 1
                cell.mTextField.text = "012"
            } else if indexPath.row == 2 {
                cell.mTextField.placeholder = "Email"
                cell.mTextField.keyboardType = .emailAddress
                cell.mTextField.tag = 2
                cell.mTextField.text = user.emailAddress
                cell.mTextField.isUserInteractionEnabled = false
            } else if indexPath.row == 3 {
                cell.mTextField.placeholder = "Delivery Address"
                cell.mTextField.isUserInteractionEnabled = false
                
                if selectedOrder.count != 0 {
                    let deliveryAddressId = selectedOrder[0].deliveryAddressId
                    if deliveryAddressId != "" {
                        Helper().loadAddress(deliveryAddressId!, completion: { address in
                            let deliveryAddress = address.buildingName + ", " + address.streetName + ", " + String(address.zipCode) + ", " + address.city
                            cell.mTextField.text = deliveryAddress
                        })
                    }
                }
                
                return cell
            } else {
                cell.mTextField.placeholder = "Delivery Instruction (Optional)"
                cell.mTextField.tag = 4
                cell.accessoryType = .none
                cell.mTextField.autocapitalizationType = .sentences
                
                if selectedOrder.count != 0 {
                    let remarkText = selectedOrder[0].remark
                    if remarkText != "" {
                        cell.mTextField.text = selectedOrder[0].remark
                    }
                }
                return cell
            }
            
            if (cell.mTextField.text?.isEmpty)! {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentOptionCell", for: indexPath) as! LabelTableViewCell
            cell.mLabel.text = "Cash On Delivery"
            cell.accessoryType = .checkmark
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalPriceCell", for: indexPath) as! DoubleLabelTableViewCell
                cell.mLabel1.text = "Total Price: "
                
                Helper().getTotalPriceForAllOrders(user.userId, completion: {formattedPrice in
                    cell.mLabel2.text = "RM \(formattedPrice)"
                })
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "promoCodeCell", for: indexPath)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 3 {
            activeTextField?.resignFirstResponder()
            
            //verify if there's already any saved address for current user
            Helper().loadAllAddressForCurrentUser(user.userId, completion: { snapshotExist, addresses in
                if snapshotExist {
                    if let addresses = addresses {
                        self.performSegue(withIdentifier: "selectDeliveryAddress", sender: self)
                    } else {
                        self.performSegue(withIdentifier: "addDeliveryAddress", sender: self)
                    }
                } else {
                    self.performSegue(withIdentifier: "addDeliveryAddress", sender: self)
                }
            })
        }
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        activeTextField = nil
        if textField.tag == 4 {
            if let remarkText = textField.text {
                if remarkText != "" {
                    updateCellAndSaveRemark(remarkText)
                }
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    //MARK:- Action
    @IBAction func unwindFromDeliveryAddressVC(_ sender: UIStoryboardSegue) {
        guard let controller = sender.source as? AddressDetailViewController else {
            fatalError("Unknown sender.source in unwindFromDeliveryAddressVC function: \(sender.source)")
        }
        updateCell(controller.deliveryAddress)
        saveDeliveryAddressId(controller.deliveryAddressId!)
    }
    
    @IBAction func unwindFromSavedAddressVC(_ sender: UIStoryboardSegue) {
        guard let controller = sender.source as? SavedAddressViewController else {
            fatalError("Unknown sender.source in unwindFromSavedAddressVC function: \(sender.source)")
        }
        updateCell(controller.addressString)
        saveDeliveryAddressId(controller.deliveryAddressId!)
    }
    
    @IBAction func didTappedPlaceOrderButton() {
        let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextFieldTableViewCell
        let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TextFieldTableViewCell
        let cell3 = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! TextFieldTableViewCell
        let cell4 = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! TextFieldTableViewCell
        
        let userNameText = cell1.mTextField.text ?? ""
        let phoneNumberText = cell2.mTextField.text ?? ""
        let emailText = cell3.mTextField.text ?? ""
        let deliveryAddressText = cell4.mTextField.text ?? ""
        
        if !(userNameText.isEmpty || phoneNumberText.isEmpty || emailText.isEmpty || deliveryAddressText.isEmpty) {
            saveToFirebase()
        } else {
            Helper().displayAlertMessage(self, messageToDisplay: "Please complete all required information.", completionHandler: nil)
        }
    }
    
    //MARK:- Private
    
    fileprivate func saveToFirebase() {

        let usersRef = FIRDatabase.database().reference().child("Users")
        //Save orderId as unconfirmed order and associate it to user
        for order in selectedOrder {
        
            //Update order status as unconfirmed
            Helper().updateOrderInformation(order.orderId, childName: "orderStatus", value: OrderStatus.unconfirmed.rawValue as AnyObject)
            
            Helper().loadMealInformation(order.mealId, childrenName: "numberOfUnconfirmedOrder", completion: { value in
                if let unconfirmedOrder = value as? Int {
                    let updatedNumberOfOrder = unconfirmedOrder + 1
                    Helper().updateMealInformation(order.mealId, childName: "numberOfUnconfirmedOrder", value: updatedNumberOfOrder as AnyObject, completion: nil)
                }
            })
            
            //Retrieve the cook user id for current order
            Helper().loadOrderInformation(order.orderId, childrenName: "mealId", completion: { value in
                if let mealId = value as? String {
                    Helper().loadMealInformation(mealId, childrenName: "cook", completion: { value in
                        if let cookId = value as? String {
                            usersRef.child(cookId).child("listing").child(mealId).child(order.orderId).setValue(true)
                            self.performSegue(withIdentifier: "completeOrder", sender: self)
                        }
                    })
                }
            }) 
        }
    }
    
    fileprivate func updateCellAndSaveRemark(_ remarkText: String) {
        for order in selectedOrder {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: IndexPath(row: 4, section: 0)) as! TextFieldTableViewCell
            cell.accessoryType = .checkmark
            order.remark = remarkText
            Helper().updateOrderInformation(order.orderId, childName: "remark", value: remarkText as AnyObject)
        }
    }
    
    fileprivate func saveDeliveryAddressId(_ deliveryId: String) {
        //update Order information in Firebase
        for order in selectedOrder {
            Helper().updateOrderInformation(order.orderId, childName: "deliveryAddressId", value: deliveryId as AnyObject)
        }
    }
    
    fileprivate func updateCell(_ address: String) {
        let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! TextFieldTableViewCell
        cell.mTextField.text = address
        cell.accessoryType = .checkmark
    }
    
    @objc fileprivate func tappedDone() {
        view.endEditing(true)

        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TextFieldTableViewCell
        if (cell.mTextField.text?.isEmpty)! {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
            for order in selectedOrder {
                Helper().updateOrderInformation(order.orderId, childName: "phoneNumber", value: cell.mTextField.text as AnyObject)
            }
        }
    }

    // MARK:- Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectDeliveryAddress" {
            guard let controller = segue.destination as? SavedAddressViewController else {
                fatalError("Unknown destination for segue selectDeliveryAddress: \(segue.destination)")
            }
            controller.user = user
            controller.checkoutMode = true
        } else if segue.identifier == "addDeliveryAddress" {
            guard let controller = segue.destination as? AddressDetailViewController else {
                fatalError("Unknown destination for segue addDeliveryAddress: \(segue.destination)")
            }
            controller.user = user
            controller.checkoutMode = true
        } else if segue.identifier == "completeOrder" {
            guard let controller = segue.destination as? CompleteOrderViewController else {
                fatalError("Unknown destination for segue completeOrder: \(segue.destination)")
            }
            controller.user = user
        }
    }
}
