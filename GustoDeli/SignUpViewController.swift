//
//  SignUpViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK:- IBOutlets
    @IBOutlet weak var nameTextField: HoshiTextField!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var tcButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var genderTextField: HoshiTextField!
    @IBOutlet weak var cameraIconBackgroundView: UIVisualEffectView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userImageHeight: NSLayoutConstraint!
    @IBOutlet weak var userImageWidth: NSLayoutConstraint!
    @IBOutlet weak var userImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageTopConstraint: NSLayoutConstraint!
    
    //MARK:- Properties
    var pickerDataSource = ["Female", "Male"]
    var genderPickerView: UIPickerView!
    var selectedGender = ""
    var activeTextField: UITextField?
    let imagePickerController = UIImagePickerController()
    
    let storageRef = FIRStorage.storage().reference(withPath: "UserPhotos")
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK:- UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGender = pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleDate = pickerDataSource[row]
        let myTitle = NSAttributedString(string: titleDate, attributes: [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Regular", size: 17)!, NSForegroundColorAttributeName: UIColor.black])
        return myTitle
    }

    //MARK:- Action
    @IBAction func tappedSignUpButton(_ sender: UIButton) {
        print("tappedSignUpButton")
        let nameText = nameTextField.text ?? ""
        let emailText = emailTextField.text ?? ""
        let passwordText = passwordTextField.text ?? ""
        let genderText = genderTextField.text ?? ""
        
        if !(nameText.isEmpty || emailText.isEmpty || passwordText.isEmpty || userImage.image == nil) {
            if emailTextField.isValidEmailAddress() {
                //create new user in Firebase
                FIRAuth.auth()!.createUser(withEmail: emailText,
                                           password: passwordText) { user, error in
                                            if error != nil  {
                                                print(error?.localizedDescription)
                                                Helper().displayAlertMessage(self, messageToDisplay: "Can't register. Please enter correct email & password.", completionHandler: nil)
                                            } else {
                                                if let user = FIRAuth.auth()?.currentUser {
                                                    
                                                    let usersRef = FIRDatabase.database().reference(withPath: "Users").child(user.uid)
                                                    usersRef.setValue(["userName" : nameText,
                                                                      "emailAddress": emailText,
                                                                      "password": passwordText,
                                                                      "gender": genderText,
                                                                      "userDescription": "",
                                                                      "userLocation": "",
                                                                      "userPhoto": ""])
                                                    
                                                    FIRAuth.auth()!.signIn(withEmail: self.emailTextField.text!,
                                                                           password: self.passwordTextField.text!)
                                                
                                                    let filePath = "\("UserPhotos")/\(user.uid)"
                                                    PostService.create(for: self.userImage!.image!, childPath: filePath, completion: {urlString in
                                                        print("here")
                                                        Helper().updateUserInformation(user.uid, childName: "userPhoto", value: urlString as! AnyObject, completion: { _ in
                                                            user.sendEmailVerification(completion: { action in
                                                                self.performSegue(withIdentifier: "confirmEmail", sender: self)
                                                            })
                                                        })
                                                    })
                                                    
                                                    
                                                }
                                            }
                }
            
            } else {
                Helper().displayAlertMessage(self, messageToDisplay: "Email address is not valid.", completionHandler: nil)
            }
        } else {
            Helper().displayAlertMessage(self, messageToDisplay: "Please complete your information.", completionHandler: nil)
        }
    }
    
    @IBAction func tappedLoginButton(_ sender: UIButton) {
       performSegue(withIdentifier: "login", sender: self)
    }
    
    @IBAction func unwindFromTCToSignUp(_ sender: UIStoryboardSegue) {
        if let source = sender.source as? T_CViewController {
            
        }
        
    }
    
    @IBAction func tappedPicture(_ sender: UITapGestureRecognizer) {
        activeTextField?.resignFirstResponder()
        imagePickerController.delegate = self
        
        Helper().displayAccessCameraAlertMessage(self, imagePickerController: imagePickerController)
    }
    
    //MARK:- UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        userImageHeight.constant = 120
        userImageWidth.constant = 120
        userImageLeadingConstraint.constant = 0
        userImageTopConstraint.constant = 0
        userImage.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }

    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == nameTextField {
            if (emailTextField.text?.isEmpty)! {
                emailTextField.becomeFirstResponder()
            }
        } else if textField == emailTextField {
            if (passwordTextField.text?.isEmpty)! {
                passwordTextField.becomeFirstResponder()
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    //MARK: - Private
    
    fileprivate func setupUI() {
        cameraIconBackgroundView.setRoundedBorder()
        signUpButton.customizeStandardButton()
        genderPickerView = Helper().createPickerView(self, textField: genderTextField)
        genderTextField.inputAccessoryView = Helper().createToolbar(true, doneSelector: #selector(tappedDone), cancelSelector: #selector(tappedCancel))
        
        nameTextField.text = "Noorul"
        emailTextField.text = "noorul.atieqah91@gmail.com"
        passwordTextField.text = "password"
        genderTextField.text = "Female"
        selectedGender = "Female"
    }
    
    @objc fileprivate func tappedDone() {
        if selectedGender != "" {
            genderTextField.text = selectedGender
        } else {
            genderTextField.text = pickerDataSource[0]
        }
        genderTextField.resignFirstResponder()
    }
    
    @objc fileprivate func tappedCancel() {
        genderTextField.resignFirstResponder()
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login" {
            guard segue.destination is LoginViewController else {
                fatalError("Unknown destination for segue login: \(segue.destination)")
            }
        } else if segue.identifier == "t&c" {
            guard let nav = segue.destination as? UINavigationController,
                let controller = nav.viewControllers.first as? T_CViewController else {
                fatalError("Unknown destination for segue t&c: \(segue.destination)")
            }
            controller.sourceViewController = self
        } else if segue.identifier == "confirmEmail" {
            guard let controller = segue.destination as? EmailConfirmationViewController else {
                    fatalError("Unknown destination for segue confirmEmail: \(segue.destination)")
            }
        }
    }
    

}
