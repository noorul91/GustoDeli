//
//  CategoryViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 9/11/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    //MARK:- Properties
    var categoryArray = [String]()
    var selectedCategory = ""
    
    //MARK:- Life cycles
    override func viewWillAppear(_ animated: Bool) {
        tableViewTopConstraint.constant = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryArray = ["Malay", "Chinese", "Indian", "Thai", "Western", "Italian", "Korean", "Japanese", "Arabian", "International", "Healthy", "Desserts", "Vegetarian", "Others"]
    }
    
    //MARK:- Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! LabelTableViewCell
        cell.mLabel.text = categoryArray[indexPath.row]
        if selectedCategory == categoryArray[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? LabelTableViewCell {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                selectedCategory = ""
            } else {
                cell.accessoryType = .checkmark
                selectedCategory = cell.mLabel.text!
            }
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwind" {
            guard segue.destination is AddMealViewController else {
                fatalError("Unknown destination for segue unwind: \(segue.destination)")
            }
            
            guard let selectedCell = sender as? LabelTableViewCell else {
                fatalError("Unknown segue setArea sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let cell = tableView.cellForRow(at: indexPath) as? LabelTableViewCell
            selectedCategory = (cell?.mLabel.text!)!
        }
    }

}
