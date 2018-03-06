//
//  OrderSummaryViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class OrderSummaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DeliveryTimeViewDelegate {

    //MARK:- IBOutlets
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var courierNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    
    //MARK:- Properties
    var order: Order!
    var user: User!
    var meal: Meal!
    var sellerName: String!
    var deliveryAddress: String!
    var array = [String]()
    var firstTime = true
    var deliveryTimeView: DeliveryTimeView?
    
    //MARK:- Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView2.frame = CGRect(x: tableView2.frame.origin.x, y: tableView2.frame.origin.y, width: tableView2.frame.size.width, height: tableView2.contentSize.height)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if deliveryTimeView != nil {
            deliveryTimeView?.removeAnimation()
        }
    }
    
    override func viewDidLayoutSubviews() {
        tableView2.frame = CGRect(x: tableView2.frame.origin.x, y: tableView2.frame.origin.y, width: tableView2.frame.size.width, height: tableView2.contentSize.height)
        if firstTime {
            createTotalOrderLabel()
            firstTime = false
        }
        tableView2.reloadData()
    }
    
    //MARK:- Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 2 && indexPath.row != 0 {
            return UITableViewAutomaticDimension
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 2 {
            return 2
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddressTableViewCell
            if indexPath.row == 0 {
                cell.mLabel1.text = "Delivery Address:"
                if let address = deliveryAddress {
                    cell.mLabel2.text = "\(address)"
                }
                cell.mButton.addTarget(self, action: #selector(editDeliveryAddressButtonTapped), for: .touchUpInside)
            } else if indexPath.row == 1 {
                cell.mLabel1.text = "Delivery Time:"
                if let deliveryTime = order.deliveryTime {
                    cell.mLabel2.text = "\(deliveryTime)"
                }
                cell.mButton.addTarget(self, action: #selector(editDeliveryTimeButtonTapped), for: .touchUpInside)
            } else {
                cell.mLabel1.text = "Payment Method:"
                cell.mLabel2.text = "Cash On Delivery"
                cell.mButton.isHidden = true
            }
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! AddressTableViewCell
                
                if let meal = meal {
                    if let numberOfOrder = order.numberOfOrder, let name = meal.mealName {
                        cell.mLabel1.text = "\(numberOfOrder) x \(name)"
                    }
                    cell.mLabel2.text = "RM \(meal.getFormattedMealPrice())"
                }
                return cell
            }
        }
    }
    
    //MARK:- Action
    @IBAction func unwindFromDeliveryAddressVCToSummary(_ sender: UIStoryboardSegue) {
        guard let controller = sender.source as? AddressDetailViewController else {
            fatalError("Unknown sender.source in unwindFromDeliveryAddressVCToSummary function: \(sender.source)")
        }
        updateAddressCell(controller.deliveryAddress)
    }
    
    @IBAction func unwindFromSavedAddressVCToSummary(_ sender: UIStoryboardSegue) {
        guard let controller = sender.source as? SavedAddressViewController else {
            fatalError("Unknown sender.source in unwindFromSavedAddressVCToSummary function: \(sender.source)")
        }
        updateAddressCell(controller.addressString)
    }
    
    //MARK:- Private
    fileprivate func setupUI() {
        //createArrayForDeliveryTimeRange()
        Helper().createArrayForDeliveryTimeRange(order, completionForArray: nil)
        if let id = order.orderId {
            self.title = "Order #\(id)"
        }
        
        tableView2.rowHeight = UITableViewAutomaticDimension
        tableView2.estimatedRowHeight = 44
        
        createButtonCancelOrder()
        statusLabel.text = order.orderStatus.rawValue
        sellerNameLabel.text = sellerName
    }
    
    fileprivate func createTotalOrderLabel() {
        let labelYOrigin = tableView2.frame.origin.y + tableView2.frame.size.height
        backgroundView.addSubview(Helper().createLabel(x: 10, y: labelYOrigin, width: 150, height: 50, textAlignment: .left, labelText: "TOTAL ORDER", textColor: .black))
        
        let totalOrderPrice = CGFloat(order.numberOfOrder) * meal.mealPrice
        let formattedTotalOrderPrice = NSString(format: "%.2f", totalOrderPrice) as String
        backgroundView.addSubview(Helper().createLabel(x: 220, y: labelYOrigin, width: 150, height: 50, textAlignment: .right, labelText: "RM \(formattedTotalOrderPrice)", textColor: .black))
    }
    
    fileprivate func createButtonCancelOrder() {
        let label1 = Helper().createLabel(x: backgroundView.frame.width/2 - 155, y: backgroundView.frame.height - 90, width: 310, height: 30, textAlignment: .left, labelText: "Possible while order status is unconfirmed", textColor: .gray)
        label1.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
        backgroundView.addSubview(label1)
        
//        let label2 = Helper().createLabel(x: backgroundView.frame.width/2 - 95, y: backgroundView.frame.height - 140, width:190, height: 20, textAlignment: .left, labelText: "Problem with your order?", textColor: .gray)
//        label2.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
//        //label2.backgroundColor = .blue
//        backgroundView.addSubview(label2)
//        
//        let label3 = Helper().createLabel(x: backgroundView.frame.width/2 - 135, y: backgroundView.frame.height - 120, width: 270, height: 20, textAlignment: .left, labelText: "Our support team is here to help you", textColor: .gray)
//        //label3.backgroundColor = .red
//        label3.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
//        backgroundView.addSubview(label3)
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: screenWidth/2 - 155.5, y: backgroundView.frame.height - 59, width: 311, height: 49)
        button.backgroundColor = UIColor().themeColor()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel!.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20)
        button.setTitle("Cancel Order", for: .normal)
        button.addTarget(self, action: #selector(cancelOrderButtonTapped), for: .touchUpInside)
        button.customizeStandardButton()
        backgroundView.addSubview(button)
    }
    
    fileprivate func updateAddressCell(_ address: String) {
        let cell = tableView1.cellForRow(at: IndexPath(row: 0, section: 0)) as! AddressTableViewCell
        cell.mLabel2.text = address
        //order.deliveryAddress = address
    }
    
    @objc fileprivate func editDeliveryAddressButtonTapped() {
        performSegue(withIdentifier: "selectDeliveryAddress", sender: self)
    }
    
    @objc fileprivate func editDeliveryTimeButtonTapped() {
        if deliveryTimeView == nil {
            addMenu()
        } else {
            deliveryTimeView?.alpha = 1.0
        }
    }
    
    @objc fileprivate func cancelOrderButtonTapped() {
        print("cancelOrderButtonTapped")
    }
    
    fileprivate func addMenu() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let deliveryView = Bundle.main.loadNibNamed("DeliveryTimeView", owner: self, options: nil)?[0] as! DeliveryTimeView
        deliveryView.pickerDataSource = array
        deliveryView.delegate = self
        appDelegate.window?.addSubview(deliveryView)
        deliveryView.showInView(self.view)
        deliveryTimeView = deliveryView
    }
    
//    fileprivate func createArrayForDeliveryTimeRange() {
//        
//        //load delivery time range for the ordered meal
//        Helper().loadOrderedMeal(order, completion: { meal in
//            if let timeRange = meal.deliveryTimeRange {
//                //create NSDate for the start and end delivery time
//                let arr = timeRange.components(separatedBy: " - ")
//                
//                let convertedStartDeliveryTime = Helper().convertDateAsTime(arr[0])
//                let convertedEndDeliveryTime = Helper().convertDateAsTime(arr[1])
//                var previousTime = convertedStartDeliveryTime
//                
//                var timeRangeArray = [String]()
//                
//                while (convertedEndDeliveryTime > previousTime) {
//                    previousTime = Calendar.current.date(byAdding: .hour, value: 1, to: previousTime)!
//                    let formatted = Helper().getFormattedDateString(previousTime, format: "hh:mm a")
//                    timeRangeArray.append(formatted)
//                }
//                
//                var rangeItem = Helper().getFormattedDateString(convertedStartDeliveryTime, format: "hh:mm a") + " - " + timeRangeArray[0]
//                
//                self.array.append(rangeItem)
//                if timeRangeArray.count > 1 {
//                    for index in 1..<timeRangeArray.count {
//                        rangeItem = timeRangeArray[index - 1] + " - " + timeRangeArray[index]
//                        self.array.append(rangeItem)
//                    }
//                }
//            }
//        })
//    }

    
    //MARK:- DeliveryTimeViewDelegate
    func timeWasSelected(_ selectedTime: String) {
        let cell = tableView1.cellForRow(at: IndexPath(row: 1, section: 0)) as! AddressTableViewCell
        cell.mLabel2.text = selectedTime
        order.deliveryTime = selectedTime
        deliveryTimeView?.alpha = 0.0
    }
    
    func cancelButtonTapped() {
        deliveryTimeView?.alpha = 0.0
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectDeliveryAddress" {
            guard let controller = segue.destination as? SavedAddressViewController else {
                fatalError("Unknown destination for segue selectDeliveryAddress: \(segue.destination)")
            }
            controller.editMode = true
            controller.user = user
        } 
    }
 

}
