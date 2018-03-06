//
//  MealInfoViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class MealInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate ,UITextViewDelegate, UITextFieldDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    let PLACEHOLDER_TEXT1 = "Side dish that comes together with the main dish. (Optional)"
    let PLACEHOLDER_TEXT2 = "Describe meal that you are selling."
    
    var mealname = ""
    var sideOrder = "Not specified"
    var mealDescription = ""
    var mealDescriptionTextEmpty = true

    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
    }

    //MARK:- TableView data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section != 0 {
            return 125
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as! TextFieldTableViewCell
            if mealname != "" {
                cell.mTextField.text = mealname
            } else {
                cell.mTextField.text = "Roasted Chicken"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as! TextViewTableViewCell
            if indexPath.section == 1 {
                if sideOrder != "" {
                    cell.mTextView.text = sideOrder
                } else {
                    cell.mTextView.applyPlaceholderStyle(placeholderText: PLACEHOLDER_TEXT1)
                }
            } else {
                if mealDescription != "" {
                    cell.mTextView.text = mealDescription
                    mealDescriptionTextEmpty = false
                } else {
                    cell.mTextView.applyPlaceholderStyle(placeholderText: PLACEHOLDER_TEXT2)
                }

            }
            return cell
        }
        
    }
    
    //MARK:- Action
    @IBAction func tappedDoneButton(_ sender: UIBarButtonItem) {
        let mealnameText = getMealNameTextField().text ?? ""
        
        if !(mealnameText.isEmpty || mealDescriptionTextEmpty) {
            performSegue(withIdentifier: "toAddMealVC", sender: self)
        } else {
            Helper().displayAlertMessage(self, messageToDisplay: "Please complete mandatory information.", completionHandler: nil)
        }
    }
    
    //MARK:- Private
    fileprivate func getMealNameTextField() -> UITextField! {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextFieldTableViewCell
        return cell.mTextField
    }
    
    fileprivate func getSideDishTextView() -> UITextView! {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! TextViewTableViewCell
        return cell.mTextView
    }
    
    fileprivate func getDescriptionTextView() -> UITextView! {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! TextViewTableViewCell
        return cell.mTextView
    }

    
    @objc fileprivate func cancelButtonTapped() {
        if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
    }
    
    fileprivate func isMatchPlaceholder(_ textView: UITextView) -> Bool {
        if (textView == getSideDishTextView()) {
            if (textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == PLACEHOLDER_TEXT1) {
                return true
            }
            return false
        } else {
            if (textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == PLACEHOLDER_TEXT2) {
                return true
            }
            return false
        }
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        mealname = textField.text!
        if getSideDishTextView().text == PLACEHOLDER_TEXT1 {
            getSideDishTextView().becomeFirstResponder()
        }
        return true
    }
    
    //MARK:- UITextViewDelegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if isMatchPlaceholder(textView) {
            textView.moveCursorToStart()
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            mealname = getMealNameTextField().text!
            
            if (textView == getSideDishTextView()) {
                if !isMatchPlaceholder(getSideDishTextView()) {
                    sideOrder = getSideDishTextView().text
                }
                if isMatchPlaceholder(getDescriptionTextView()) {
                    getDescriptionTextView().becomeFirstResponder()
                }
            } else {
                if !isMatchPlaceholder(getDescriptionTextView()) {
                    mealDescription = getDescriptionTextView().text
                    mealDescriptionTextEmpty = false
                }
            }
            return false
        }
        
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            if isMatchPlaceholder(textView) {
                if text.utf16.count == 0 {
                    return false
                }
                textView.applyNonPlaceholderStyle()
                textView.text = ""
            }
            return true
        } else {
            if (textView == getSideDishTextView()) {
                textView.applyPlaceholderStyle(placeholderText: PLACEHOLDER_TEXT1)
            } else  {
                textView.applyPlaceholderStyle(placeholderText: PLACEHOLDER_TEXT2)
                mealDescriptionTextEmpty = true
            }
            textView.moveCursorToStart()
            return false
        }
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddMealVC" {
            guard segue.destination is AddMealViewController else {
                fatalError("Unknown destinatoin for segue toAddMealVC: \(segue.destination)")
            }
        }
    }
    

}
