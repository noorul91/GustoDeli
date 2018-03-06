//
//  AskGustoViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/18/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class AskGustoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    var user: User!
    
    //MARK:- Life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setBlankTitle()
    }
    
    //MARK:- Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "YOUR QUESTION"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LabelTableViewCell
        if indexPath.row == 0 {
            cell.mLabel.text = "General Inquiry"
        } else {
            cell.mLabel.text = "Report an App Problem"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "generalInq", sender: self)
        } else {
            performSegue(withIdentifier: "appProb", sender: self)
        }
    }
    
    //MARK:- Action
    @IBAction func unwindFromInqVC(_ sender: UIStoryboardSegue) {
        guard let controller = sender.source as? GeneralInqViewController else {
            fatalError("Unknown sender.source in unwindFromInqVC function: \(sender.source)")
        }
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "generalInq" {
            guard let controller = segue.destination as? GeneralInqViewController else {
                fatalError("Unknown destination for segue generalInq: \(segue.destination)")
            }
            controller.user = user
            controller.mode = GeneralInqViewController.Mode.inquiryMode
        } else if segue.identifier == "appProb" {
            guard let controller = segue.destination as? GeneralInqViewController else {
                fatalError("Unknown destination for segue appProb: \(segue.destination)")
            }
            controller.user = user
            controller.mode = GeneralInqViewController.Mode.reportAppProblemMode
        }
    }
    

}
