//
//  ForgotPasswordViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/30/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    //MARK:- IBOutlets
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.setupThemeColorNavBar()
        resetPasswordButton.customizeStandardButton()
    }

    //MARK:- Action
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "backToLoginPage", sender: self)
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
        if emailAddressTextField.isValidEmailAddress() {
            FIRAuth.auth()?.sendPasswordReset(withEmail: emailAddressTextField.text!, completion: { (error) in
                if let error = error {
                    Helper().displayAlertMessage(self, messageToDisplay: error.localizedDescription, completionHandler: nil)
                } else {
                    Helper().displayAlertMessage(self, messageToDisplay: "An email has been sent to your inbox. Follow the instructions to replace your password.", completionHandler: {action in
                        self.performSegue(withIdentifier: "backToLoginPage", sender: self)
                    })
                }
            })
        } else {
            Helper().displayAlertMessage(self, messageToDisplay: "Email address is not valid", completionHandler: nil)
        }
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
