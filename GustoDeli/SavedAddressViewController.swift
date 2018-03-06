//
//  SavedAddressViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class SavedAddressViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addAddressButton: UIButton!
    
    //MARK:- Properties
    var user: User!
    var addresses: [Address] = []
    var checkoutMode = false
    var editMode = false
    var addressString = ""
    var selectedCell: UITableViewCell?
    var deliveryAddressId: String?
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAddressButton.customizeStandardButton()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 96
        
        //load saved addresses for current user from Firebase
        Helper().loadAllAddressForCurrentUser(user.userId, completion: { snapshotExist, addresses in
            if snapshotExist {
                if let addresses = addresses {
                    if addresses.count != 0 {
                        self.addresses = addresses
                        self.tableView.reloadData()
                    } else {
                        self.setupEmptyCartScreen()
                    }
                }
            } else {
                self.setupEmptyCartScreen()
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setBlankTitle()
    }
    
    //MARK:- Private methods
    
    fileprivate func constructAddress(_ cell: UITableViewCell, indexPath: IndexPath) -> String {
        let buildingName = addresses[indexPath.row].buildingName
        let streetName = addresses[indexPath.row].streetName
        let zipCode = addresses[indexPath.row].zipCode
        let city = addresses[indexPath.row].city
     
        addressString = buildingName + ", " + streetName
        addressString = addressString + ", \(zipCode), " + city
        return addressString
    }
    
    fileprivate func setupEmptyCartScreen() {
        let label = Helper().createLabel(x: screenWidth/2 - 140, y: screenHeight/2 - 25, width: 280,
                                         height: 50, textAlignment: .center, labelText: "Click on Add Address button to add a new address.", textColor: .lightGray)
        label.numberOfLines = 0
        view.addSubview(label)
    }
    
    //MARK:- Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressTableViewCell
        
        if addresses[indexPath.row].addressType == AddressType.Home {
            cell.mLabel1.text = "Home"
            cell.photo.image = UIImage(named: "Home icon")
        } else if addresses[indexPath.row].addressType == AddressType.Work {
            cell.mLabel1.text = "Work"
            cell.photo.image = UIImage(named: "Work icon")
        } else {
            cell.mLabel1.text = "Other"
            cell.photo.image = UIImage(named: "Other location icon")
        }
        cell.mLabel2.text = constructAddress(cell, indexPath: indexPath)
        
        cell.photo.image = cell.photo.image!.withRenderingMode(.alwaysTemplate)
        cell.photo.tintColor = UIColor.lightGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = tableView.cellForRow(at: indexPath) as! AddressTableViewCell
        if !checkoutMode && !editMode {
            print("addressDetail")
            performSegue(withIdentifier: "addressDetail", sender: selectedCell)
        } else if editMode {
            print("editAddress")
            performSegue(withIdentifier: "editAddress", sender: self)
        } else {
            print("selectAddress")
            performSegue(withIdentifier: "selectAddress", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            addresses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if addresses.count == 0 {
                setupEmptyCartScreen()
            }
        }
    }
    
    //MARK:- Action
    
    @IBAction func selectButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "addAddress", sender: self)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addressDetail" {
            guard let controller = segue.destination as? AddressDetailViewController else {
                fatalError("Unknown destination for segue addressDetail: \(segue.destination)")
            }
            guard let indexPath = tableView.indexPath(for: sender as! AddressTableViewCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            controller.organizedAddress = addresses[indexPath.row]
            controller.checkoutMode = checkoutMode
            controller.user = user
        } else if segue.identifier == "addAddress" {
            guard let controller = segue.destination as? AddressDetailViewController else {
                fatalError("Unknown destination for segue addAddress: \(segue.destination)")
            }
            controller.user = user
            controller.checkoutMode = checkoutMode
        } else if segue.identifier == "selectAddress" {
            guard segue.destination is CheckoutViewController else {
                fatalError("Unknown destination for segue selectAddress: \(segue.destination)")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell as! AddressTableViewCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let cell = tableView.cellForRow(at: indexPath) as! AddressTableViewCell
            addressString = constructAddress(cell, indexPath: indexPath)
            deliveryAddressId = addresses[indexPath.row].id
        } else if segue.identifier == "editAddress" {
            guard segue.destination is OrderSummaryViewController else {
                fatalError("Unknown destination for segue editAddress: \(segue.destination)")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell as! AddressTableViewCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let cell = tableView.cellForRow(at: indexPath) as! AddressTableViewCell
            addressString = constructAddress(cell, indexPath: indexPath)
        }
    }
}
