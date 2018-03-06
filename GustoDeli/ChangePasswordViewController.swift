//
//  ChangePasswordViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/16/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate  {
    
    //MARK:- IBOutlets
    @IBOutlet weak var updatePasswordButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    var user: User!
    var newPassword = ""

    let userRef = FIRDatabase.database().reference().child("Users")
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        updatePasswordButton.customizeStandardButton()
    }
    
    //MARK:- TableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TextFieldTableViewCell
        
        if indexPath.row == 0 {
            cell.mTextField.placeholder = "Current Password"
            cell.mTextField.tag = 0
        } else if indexPath.row == 1 {
            cell.mTextField.placeholder = "New Password"
            cell.mTextField.tag = 1
        } else {
            cell.mTextField.placeholder = "Confirm New Password"
            cell.mTextField.tag = 2
        }
        return cell
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 0 {
            if (getNewPasswordTextField().text?.isEmpty)! {
                getNewPasswordTextField().becomeFirstResponder()
            }
        } else if textField.tag == 1 {
            if (getConfirmNewPasswordTextField().text?.isEmpty)! {
                getConfirmNewPasswordTextField().becomeFirstResponder()
            }
        }
        return true
    }

    //MARK:- Action
    
    @IBAction func updatePasswordButtonTapped(_ sender: UIButton) {
        print("updatePasswordButtonTapped")
        //verify that the old password is matched
        if getOldPasswordTextField().text != user.password {
            Helper().displayAlertMessage(self, messageToDisplay: "Please ensure that your current password is correct.", completionHandler: nil)
        }
        
        //verify that the new password text field must match the confirmed new password text field
        newPassword = getNewPasswordTextField().text ?? ""
        let confirmNewPassword = getConfirmNewPasswordTextField().text ?? ""
        
        if newPassword != confirmNewPassword {
            Helper().displayAlertMessage(self, messageToDisplay: "Please ensure that your new password and its confirmation matches.", completionHandler: nil)
        } else {
            //update password into Firebase
            let currentUser = FIRAuth.auth()?.currentUser
            let credential = FIREmailPasswordAuthProvider.credential(withEmail: user.emailAddress, password: user.password)
            currentUser?.reauthenticate(with: credential, completion: { error in
                if error != nil {
                    Helper().displayAlertMessage(self, messageToDisplay: "Error re-authenticating user", completionHandler: nil)
                } else {
                    //User has been re-authenticated.Changing to new password.
                    currentUser?.updatePassword(self.newPassword, completion: { error in
                        if let error = error {
                            Helper().displayAlertMessage(self, messageToDisplay: error.localizedDescription, completionHandler: nil)
                        } else {
                            self.userRef.child(self.user.userId).updateChildValues(["password": self.newPassword])
                            Helper().displayAlertMessage(self, messageToDisplay: "Password is successfully updated.", completionHandler: {action in
                                self.performSegue(withIdentifier: "updatePassword", sender: self)})
                        }
                    })
                }
            })
        }
    }
    
    //MARK:- Private
    fileprivate func getOldPasswordTextField() -> UITextField! {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextFieldTableViewCell
        return cell.mTextField
    }
    
    fileprivate func getNewPasswordTextField() -> UITextField! {
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! TextFieldTableViewCell
        return cell.mTextField
    }
    
    fileprivate func getConfirmNewPasswordTextField() -> UITextField! {
        let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! TextFieldTableViewCell
        return cell.mTextField
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updatePassword" {
            guard segue.destination is ProfileViewController else {
                fatalError("Unknown destination for segue updatePassword: \(segue.destination)")
            }
        }
    }

}
