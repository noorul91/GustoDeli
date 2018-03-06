//
//  ListingViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class ListingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    var user: User?
    var keyArrays = [Meal]()
    var source: UIViewController!
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setupThemeColorNavBar()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 162
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        tableView.reloadData()
    }

    //MARK:- Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return keyArrays.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentMeal = keyArrays[indexPath.section]
        
        if indexPath.row == 0 {
            if indexPath.section % 2 == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "leftCell", for: indexPath) as! OrderTableViewCell
                cell.meal = currentMeal
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "rightCell", for: indexPath) as! OrderTableViewCell
                cell.meal = currentMeal
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! LabelTableViewCell
            
            if indexPath.row == 1 {
                cell.mLabel.text = String(currentMeal.numberOfUnconfirmedOrder) + " unconfirmed order"
            } else {
                cell.mLabel.text = String(currentMeal.numberOfOrder) + " confirmed order"
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let selectedCell = tableView.cellForRow(at: indexPath) as! OrderTableViewCell
            performSegue(withIdentifier: "showDetails", sender: selectedCell)
        } else {
            let selectedCell = tableView.cellForRow(at: indexPath) as! LabelTableViewCell
            performSegue(withIdentifier: "showOrder", sender: selectedCell)
        }
    }
    
    //MARK:- Action
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "backToMainPage", sender: self)
    }
    
    //MARK:- Private
    fileprivate func setupUI() {
        if user == nil {
            if self.source is MenuViewController {
                self.setupEmptyScreen()
            } else {
                self.setupEmptyScreenUserDashboard()
            }
        } else {
            if let userId = user?.userId {
                Helper().loadAllMealListing(userId, completion: { meals in
                    self.keyArrays = meals
                    self.tableView.reloadData()
                    
                    if self.keyArrays.count == 0 {
                        if self.source is MenuViewController {
                            self.setupEmptyScreen()
                        } else {
                            self.setupEmptyScreenUserDashboard()
                        }
                    }
                })
            }
        }
    }

    
    fileprivate func setupEmptyScreen() {
        let barHeight = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height)!
        let imageView = Helper().createImageViewForEmptyScreen("Food Background 3", x: 0, y: barHeight, width: screenWidth, height: screenHeight - barHeight)
        view.addSubview(imageView)
        
        let layerView = Helper().createFilterViewForEmptyScreen(x: 0, y: barHeight, width: screenWidth, height: screenHeight - barHeight)
        view.addSubview(layerView)
        
        let label = Helper().createLabel(x: screenWidth/2 - 125, y: screenHeight/2 - 60, width: 250, height: 100, textAlignment: .center, labelText: "No activities yet. Get started by selling!", textColor: .white)
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20)
        label.numberOfLines = 0
        view.addSubview(label)
    }

    fileprivate func setupEmptyScreenUserDashboard() {
        if let cookName = user?.userName {
            self.view.backgroundColor = .white
            let label = Helper().createLabel(x: screenWidth/2 - 125, y: 30, width: 250, height: 100, textAlignment: .center, labelText: "No listing by \(cookName) yet.", textColor: .lightGray)
            label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
            label.numberOfLines = 0
            view.addSubview(label)
        }
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToMainPage" {
            guard let controller = segue.destination as? MealPreviewViewController else {
                fatalError("Unknown destination for segue backToMainPage: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "showDetails" {
            guard let controller = segue.destination as? GustoViewController else {
                fatalError("Unknown destination for segue showDetails: \(segue.destination)")
            }
            guard let selectedCell = sender as? UITableViewCell else {
                fatalError("Unknown segue showDetails sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            controller.meal = keyArrays[indexPath.section]
            controller.user = user
            controller.mode = GustoViewController.Mode.Listing
        } else if segue.identifier == "showOrder" {
            guard let controller = segue.destination as? OrderScreenViewController else {
                fatalError("Unknown destination for segue showOrder: \(segue.destination)")
            }
            guard let selectedCell = sender as? UITableViewCell else {
                fatalError("Unknown segue showOrder sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            controller.meal = keyArrays[indexPath.section]
            controller.user = user
            if indexPath.row == 1 {
                controller.confirmedMode = false
            } else {
                controller.confirmedMode = true
            }
        }
    }
    

}
