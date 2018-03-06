//
//  LocationViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/18/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchControllerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchControllerView: UIView!
    @IBOutlet weak var searchControllerViewHeightConstraint: NSLayoutConstraint!
    
    //MARK:- Properties
    var areaArray = [String]()
    var filteredArray = [String]()
    var resultSearchController = UISearchController()
    var selectedArea = ""
    
    //MARK:- Life cycles

    override func viewWillAppear(_ animated: Bool) {
        searchControllerViewTopConstraint.constant = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        areaArray = ["Subang Jaya", "U.S.J Subang Jaya", "Bandar Sunway", "Glenmarie", "Kelana Jaya", "Petaling Jaya"]
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            searchControllerView.addSubview(controller.searchBar)
            return controller
        })()
        tableView.reloadData()
    }
    
    //MARK:- Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (resultSearchController.isActive && resultSearchController.searchBar.text != "") {
            return filteredArray.count
        }
        
        if !resultSearchController.isActive {
            searchControllerViewHeightConstraint.constant = 44.0
        }
        return areaArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LabelTableViewCell
        if (resultSearchController.isActive && resultSearchController.searchBar.text != "") {
            cell.mLabel.text = filteredArray[indexPath.row]
            return cell
        } else {
            if selectedArea != "" {
                if selectedArea == areaArray[indexPath.row] {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
            cell.mLabel.text = areaArray[indexPath.row]
            return cell
        }
    }
    
    //MARK:- UISearchResultsUpdating
    @available(iOS 8.0, *)
    //this method is called whenever the user updates the Search bar with input
    func updateSearchResults(for searchController: UISearchController) {
        searchControllerViewHeightConstraint.constant = 0
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    
    
    //MARK:- Private
    fileprivate func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredArray = areaArray.filter { area in
            return area.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setArea" {
            guard let controller = segue.destination as? ProfileViewController else {
                fatalError("Unknown destination for segue setArea: \(segue.destination)")
            }
            
            guard let selectedCell = sender as? LabelTableViewCell else {
                fatalError("Unknown segue setArea sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let cell = tableView.cellForRow(at: indexPath) as? LabelTableViewCell
            selectedArea = (cell?.mLabel.text!)!
        }
    }
}
