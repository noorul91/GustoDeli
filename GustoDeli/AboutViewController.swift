//
//  AboutViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/18/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK:- Properties
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setupThemeColorNavBar()
    }
    
    //MARK:- TableView data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Contact Us"
        }
        return ""
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LabelTableViewCell
        if indexPath.section == 0 {
            cell.mLabel.text = "013-4442326"
        } else {
            if indexPath.row == 0 {
                cell.mLabel.text = "Rate Us on App Store"
            } else if indexPath.row == 1 {
                cell.mLabel.text = "Report an App Problem"
            } else if indexPath.row == 2 {
                cell.mLabel.text = "Terms & Conditions"
            } else {
                cell.mLabel.text = "Visit GustoDeli.com.my"
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            //prompt window to call the number
            let cell = tableView.cellForRow(at: indexPath) as! LabelTableViewCell
        
            var editedPhoneNumber = ""
            cell.mLabel.text?.characters.forEach { (character) in
                switch character {
                case "0"..."9":
                    editedPhoneNumber.characters.append(character)
                default:
                    break
                }
            }
            let url = URL(string: "telprompt://" + editedPhoneNumber)
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        } else if indexPath.section == 1 && indexPath.row == 0 {
            //go to Rate us on app store page
           
        } else if indexPath.section == 1 && indexPath.row == 1 {
            //go to Report an App Problem page
            performSegue(withIdentifier: "appProb", sender: self)
        } else if indexPath.section == 1 && indexPath.row == 2 {
            //go to T&C page
            performSegue(withIdentifier: "t&c", sender: self)
        } else if indexPath.section == 1 && indexPath.row == 3 {
            //open GustoDeli.com.my website
            
            let url = URL(string: "http://www.google.com")!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    //MARK:- Action
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "backToMainPage", sender: self)
    }
    
    @IBAction func unwindFromInqVCToAboutVC(_ sender: UIStoryboardSegue) {
        guard let controller = sender.source as? GeneralInqViewController else {
            fatalError("Unknown sender.source in unwindFromInqVCToAboutVC function: \(sender.source)")
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToMainPage" {
            guard let controller = segue.destination as? MealPreviewViewController else {
                fatalError("Unknown destination for segue backToMainPage: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "t&c" {
            guard let controller = segue.destination as? T_CViewController else {
                    fatalError("Unknown destination for segue t&c: \(segue.destination)")
            }
            controller.sourceViewController = self
        } else if segue.identifier == "appProb" {
            guard let controller = segue.destination as? GeneralInqViewController else {
                fatalError("Unknown destination for segue appProb: \(segue.destination)")
            }
            controller.isFromAboutPage = true
            controller.user = user
            controller.mode = GeneralInqViewController.Mode.reportAppProblemMode
        }
    }

}
