//
//  LoginViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    //MARK:- Properties
    var user: User!
    var sourceController: UIViewController!
    var meal: Meal?
    
    lazy var navControllerMealPreview: UINavigationController? = {
        var navControllerMealPreview = self.storyboard?.instantiateViewController(withIdentifier: "mainNavController") as! UINavigationController
        navControllerMealPreview.pushViewController(self.mainViewController!, animated: false)
        return navControllerMealPreview
    }()
    
    lazy var navControllerShoppingBag: UINavigationController? = {
        var navControllerShoppingBag = self.storyboard?.instantiateViewController(withIdentifier: "mainNavController") as! UINavigationController
        navControllerShoppingBag.pushViewController(self.mainViewController!, animated: false)
        let shoppingVC = self.storyboard?.instantiateViewController(withIdentifier: "shoppingVC") as! ShoppingCartViewController
        shoppingVC.user = self.user
        navControllerShoppingBag.pushViewController(shoppingVC, animated: false)
        return navControllerShoppingBag
    }()
    
    lazy var navControllerGusto: UINavigationController? = {
        var navControllerGusto = self.storyboard?.instantiateViewController(withIdentifier: "mainNavController") as! UINavigationController
        navControllerGusto.pushViewController(self.mainViewController!, animated: false)
        let gustoVC = self.storyboard?.instantiateViewController(withIdentifier: "gustoVC") as! GustoViewController
        gustoVC.meal = self.meal
        gustoVC.user = self.user
        navControllerGusto.pushViewController(gustoVC, animated: false)
        return navControllerGusto
    }()
    
    lazy var mainViewController: MealPreviewViewController? = {
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "mainVC") as! MealPreviewViewController
        mainViewController.user = self.user
        return mainViewController
    }()

    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        emailAddressTextField.text = "noorul.atieqah@gmail.com"
        passwordTextField.text = "password"
        loginButton.customizeStandardButton()
    }
    
    //MARK:- Action
    @IBAction func tappedLoginButton(_ sender: UIButton) {
        let emailText = emailAddressTextField.text ?? ""
        let passwordText = passwordTextField.text ?? ""
        
        if !(emailText.isEmpty || passwordText.isEmpty) {
            if emailAddressTextField.isValidEmailAddress() {
                //Firebase login processs
                FIRAuth.auth()!.signIn(withEmail: self.emailAddressTextField.text!,
                                       password: self.passwordTextField.text!) { user, error in
                                        if error != nil  {
                                            Helper().displayAlertMessage(self, messageToDisplay: "Can't sign in. Please enter correct email & password.", completionHandler: nil)
                                        } else {
                                            if let user = FIRAuth.auth()?.currentUser {
                                                if !user.isEmailVerified {
                                                    self.promptAlertEmailNotVerified(emailText, user: user)
                                                } else {
                                                    //logging in
                                                    self.fetchUserInformationAndLogIn()
                                                }
                                            }
                                        }
                }
            } else {
                Helper().displayAlertMessage(self, messageToDisplay: "Email address is not valid", completionHandler: nil)
            }
        } else {
            Helper().displayAlertMessage(self, messageToDisplay: "Please complete your email address & password.", completionHandler: nil)
        }
    }
    
    @IBAction func tappedPasswordButton(_ sender: UIButton) {
        performSegue(withIdentifier: "forgotPassword", sender: self)
    }
    
    @IBAction func tappedRegisterButton(_ sender: UIButton) {
        performSegue(withIdentifier: "register", sender: self)
    }
    
    @IBAction func unwindFromTCToLogin(_ sender: UIStoryboardSegue) {
        if sender.source is T_CViewController {
            
        }
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == emailAddressTextField {
            if (passwordTextField.text?.isEmpty)! {
                passwordTextField.becomeFirstResponder()
            }
        }
        return true
    }
    
    //MARK:- Private
    
    fileprivate func fetchUserInformationAndLogIn() {
        /**
         * Attach an authentication observer to the Firebase auth object, that in turn assigns the user property
         * when a user successfully signs in.
         **/
        FIRAuth.auth()!.addStateDidChangeListener() { (auth, user) in
            guard let user = user else { return }
            self.user = User(authData: user)
            //load current user info from Firebase
            Helper().loadUser(self.user.userId, completion: { (user, snapshotValue) in
                self.user = user
                if (self.sourceController is MealPreviewViewController ||
                    self.sourceController is MenuViewController) {
                    self.present(self.navControllerMealPreview!, animated: true, completion: nil)
                } else if self.sourceController is GustoViewController {
                    self.present(self.navControllerGusto!, animated: true, completion: nil)
                } else if self.sourceController is ShoppingCartViewController {
                    self.present(self.navControllerShoppingBag!, animated: true, completion: nil)
                }
            })
        }
    }
    
    fileprivate func promptAlertEmailNotVerified(_ emailText: String, user: FIRUser) {
        let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email to \(emailText).", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Okay", style: .default) { (_) in
            user.sendEmailVerification(completion: nil)
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "t&c" {
            guard let nav = segue.destination as? UINavigationController,
                let controller = nav.viewControllers.first as? T_CViewController else {
                fatalError("Unknown destination for segue t&c: \(segue.destination)")
            }
            controller.sourceViewController = self
        }
    }
}
