//
//  GeneralInqViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/18/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class GeneralInqViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate {

    enum Mode: String {
        case inquiryMode
        case reportAppProblemMode
        case reportUserMode
    }
    
    //MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    var user: User!
    var mode: Mode!
    var isFromAboutPage = false
    let PLACEHOLDER_TEXT1 = "Please enter your question (up to 1000 characters)."
    let PLACEHOLDER_TEXT2 = "Please enter your complaint (up to 1000 characters)."
    var placeholder = ""
    var reportedCook: User?
    
    //MARK:- Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setBlankTitle()
    }
    
    //MARK:- Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        if mode == Mode.reportUserMode {
            return 3
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Name"
        }
        if mode == Mode.reportUserMode {
            if section == 1 {
                return "Seller's Name"
            }
            return "Complaint"
        }
        return "Your Question"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        }
        if mode == Mode.reportUserMode {
            if indexPath.section == 1 {
                return 44
            }
        }
        return 201
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as! TextFieldTableViewCell
            return cell
        } else {
            if mode == Mode.reportUserMode && indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as! TextFieldTableViewCell
                cell.mTextField.text = reportedCook?.userName
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as! TextViewTableViewCell
            cell.mTextView.applyPlaceholderStyle(placeholderText: placeholder)
            return cell
        }
    }

    
    //MARK:- Action
    
    @IBAction func submitButtonTapped(_ sender: UIBarButtonItem) {
        
        let nameText = getNameTextField().text ?? ""
        var questionText = ""
        questionText = getQuestionTextView().text != placeholder ? getQuestionTextView().text : ""
        
        if !(nameText.isEmpty || (questionText.isEmpty)) {

            var message = ""
            if mode == Mode.inquiryMode {
                message = "Your inquiry has been successfully sent to Gusto Deli."
            } else {
                message = "Your report has been successfully sent to Gusto Deli."
            }
            
            var segueIdentifier = "backToInq"
            if isFromAboutPage {
                segueIdentifier = "unwindToAbout"
            } else if mode == Mode.reportUserMode {
                segueIdentifier = "backToGustoDeliVC"
            }
            
            Helper().displayAlertMessage(self, messageToDisplay: message, completionHandler: { action in
                self.performSegue(withIdentifier: segueIdentifier, sender: self)
            })
        } else {
            Helper().displayAlertMessage(self, messageToDisplay: "Please complete all the details.", completionHandler: nil)
        }
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if getQuestionTextView().text == placeholder {
            getQuestionTextView().becomeFirstResponder()
        }
        return true
    }

    //MARK:- UITextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == placeholder {
            textView.moveCursorToStart()
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        
        if newLength > 0 {
            //check if the only text is the placeholder & remove it if needed
            if (textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == placeholder) {
                if text.utf16.count == 0 {
                    //they hit the back button so ignore it
                    return false
                }
                textView.applyNonPlaceholderStyle()
                textView.text = ""
            }
            return true
        } else {
            //no text found, so show the placeholder
            textView.applyPlaceholderStyle(placeholderText: placeholder)
            textView.moveCursorToStart()
            return false
        }
    }
    
    //MARK:- Private
    fileprivate func setupUI() {
        if mode == Mode.reportUserMode {
            titleLabel.text = "Report User"
            placeholder = PLACEHOLDER_TEXT2
        } else if mode == Mode.inquiryMode {
            titleLabel.text = "General Inquiry"
            placeholder = PLACEHOLDER_TEXT1
        } else {
            titleLabel.text = "Report an App Problem"
            placeholder = PLACEHOLDER_TEXT1
        }
    }
    
    fileprivate func getNameTextField() -> UITextField! {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextFieldTableViewCell
        return cell.mTextField
    }
    
    fileprivate func getQuestionTextView() -> UITextView! {
        var indexPath = IndexPath(row: 0, section: 1)
        if mode == Mode.reportUserMode {
            indexPath = IndexPath(row: 0, section: 2)
        }
        let cell = tableView.cellForRow(at: indexPath) as! TextViewTableViewCell
        return cell.mTextView
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToInq" {
            guard let controller = segue.destination as? AskGustoViewController else {
                fatalError("Unknown destinatoin for segue backToInq: \(segue.destination)")
            }
        }
    }
    

}
