//
//  ProfileViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/16/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //MARK:- IBOutlets
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var fullNameTextField: HoshiTextField!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var genderTextField: HoshiTextField!
    @IBOutlet weak var locationTextField: HoshiTextField!
    @IBOutlet weak var selfDescriptionTextField: HoshiTextField!
    @IBOutlet weak var savedAddressButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var descriptionBorderHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionBorder: UIView!
    
    //MARK:- Properties
    var activeTextField: UITextField?
    let imagePickerController = UIImagePickerController()
    var user: User!
    var pickerDataSource = ["Female", "Male"]
    var genderPickerView: UIPickerView!
    var selectedGender = ""
    
    let userRef = FIRDatabase.database().reference().child("Users")
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        scrollViewTopConstraint.constant = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height)!
    }
    
    //MARK:- UIPickerView implementations
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
        let attribute = [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Regular", size: 17),
                         NSForegroundColorAttributeName: UIColor.black]
        return NSAttributedString(string: pickerDataSource[row], attributes: attribute)
    }
    
    //MARK:- Action
    @IBAction func unwindToSettingFromCookDescriptionVC(_ sender: UIStoryboardSegue) {
        if let sourceVC = sender.source as? CookDescriptionViewController {
            let capitalizedDescription = sourceVC.cookDescription.capitalizingFirstLetter()
            selfDescriptionTextField.text = capitalizedDescription
            descriptionBorder.backgroundColor = UIColor().themeColor()
            descriptionBorderHeight.constant = 2.0
        }
    }
    
    @IBAction func tappedAddressButton(_ sender: UIButton) {
        performSegue(withIdentifier: "savedAddress", sender: self)
    }
    
    @IBAction func unwindFromAreaVC(_ sender: UIStoryboardSegue) {
        if let sourceVC = sender.source as? LocationViewController {
            locationTextField.text = sourceVC.selectedArea
        }
    }
    
    @IBAction func unwindFromChangePasswordVC(_ sender: UIStoryboardSegue) {
        if let sourceVC = sender.source as? ChangePasswordViewController {
            passwordTextField.text = sourceVC.newPassword
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "backToMainPage", sender: self)
    }
    
    @IBAction func tappedSaveButton(_ sender: UIBarButtonItem) {
        //Validate name/email/password text field is complete or not before return
        let nameText = fullNameTextField.text ?? ""
        let passwordText = passwordTextField.text ?? ""
        
        if !(nameText.isEmpty || passwordText.isEmpty) {
            performSegue(withIdentifier: "unwindToMainPage", sender: self)
        } else {
            Helper().displayAlertMessage(self, messageToDisplay: "Please complete at least full name, email and password information.", completionHandler: nil)
        }
    }
    
    @IBAction func tappedPhotoIcon(_ sender: UITapGestureRecognizer) {
        //Hide keyboard
        activeTextField?.resignFirstResponder()
        imagePickerController.delegate = self
        Helper().displayAccessCameraAlertMessage(self, imagePickerController: imagePickerController)
    }
    
    @IBAction func swipedRight(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "backToMainPage", sender: self)
    }

    
    //MARK:- Private
    fileprivate func setupUI() {
        savedAddressButton.customizeStandardButton()
        self.navigationController?.navigationBar.setupThemeColorNavBar()
        userPhoto.loadImageWithCacheWithUrlString(user.userPhoto)
        userPhoto.setRoundedBorder()
        userPhoto.setBorderWidthColor(3.0, borderColor: UIColor().hexStringToUIColor(hexString: "#8A8A8A", alpha: 1.0))
        
        fullNameTextField.text = user.userName
        emailTextField.text = user.emailAddress
        passwordTextField.text = user.password
        genderTextField.text = user.gender.rawValue
        
        genderPickerView = Helper().createPickerView(self, textField: genderTextField)
        genderTextField.inputAccessoryView = Helper().createToolbar(true, doneSelector: #selector(tappedDone), cancelSelector: #selector(tappedCancel))
        
        if user.userLocation != nil {
            locationTextField.text = user.userLocation
        }
        
        if user.userDescription != "" {
            selfDescriptionTextField.text = user.userDescription
            descriptionBorder.backgroundColor = UIColor().themeColor()
            descriptionBorderHeight.constant = 2.0
        }
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
    
    //MARK:- UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        userPhoto.image = selectedImage
        
        //upload meal photo to storage
        PostService.create(for: selectedImage, childPath: "\("UserPhotos")/\(user.userId)", completion: {urlString in 
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == fullNameTextField {
            if (passwordTextField.text?.isEmpty)! {
                passwordTextField.becomeFirstResponder()
            }
        } else if textField == passwordTextField {
            if (genderTextField.text?.isEmpty)! {
                genderTextField.becomeFirstResponder()
            }
        } else if textField == genderTextField {
            if (selfDescriptionTextField.text?.isEmpty)! {
                selfDescriptionTextField.becomeFirstResponder()
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == locationTextField {
            performSegue(withIdentifier: "showArea", sender: self)
            return false
        } else if textField == passwordTextField {
            performSegue(withIdentifier: "changePassword", sender: self)
            return false
        } else if textField == selfDescriptionTextField {
            performSegue(withIdentifier: "description", sender: self)
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    //update user's info into Firebase (only if there's a differrence)
    fileprivate func updateUserInformation() {
        
        let fullNameText = fullNameTextField.text ?? ""
        if fullNameText != user.userName {
            
            userRef.child(user.userId).updateChildValues(["userName": fullNameText])
            user.userName = fullNameText
        }
        
        let genderText = genderTextField.text ?? ""
        if genderText != user.gender.rawValue {
            
            userRef.child(user.userId).updateChildValues(["gender": genderText])
            if genderText == Gender.Female.rawValue {
                user.gender = Gender.Female
            } else {
                user.gender = Gender.Male
            }
            
        }
        
        let selfDescriptionText = selfDescriptionTextField.text ?? ""
        if selfDescriptionText != user.userDescription {
            
            userRef.child(user.userId).updateChildValues(["userDescription": selfDescriptionText])
            user.userDescription = selfDescriptionText
        }
        
        let locationText = locationTextField.text ?? ""
        if locationText != user.userLocation {
            
            userRef.child(user.userId).updateChildValues(["userLocation": locationText])
            user.userLocation = locationText
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToMainPage" {
            guard let nav = segue.destination as? UINavigationController,
                let controller = nav.viewControllers.first as? MealPreviewViewController else {
                fatalError("Unknown destination for segue unwindToMainPage: \(segue.destination)")
            }
            updateUserInformation()
            controller.user = user
        } else if segue.identifier == "showArea" {
            guard let controller = segue.destination as? LocationViewController else {
                fatalError("Unknown destination for segue showArea: \(segue.destination)")
            }
            controller.selectedArea = locationTextField.text ?? ""

        } else if segue.identifier == "savedAddress" {
            guard let controller = segue.destination as? SavedAddressViewController else {
                fatalError("Unknown destination for segue savedAddress: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "backToMainPage" {
            guard let controller = segue.destination as? MealPreviewViewController else {
                fatalError("Unknown destination for segue backToMainPage: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "changePassword" {
            guard let controller = segue.destination as? ChangePasswordViewController else {
                fatalError("Unknown destination for segue changePassword: \(segue.destination)")
            }
            controller.user = user
        }else if segue.identifier == "description" {
            guard let controller = segue.destination as? CookDescriptionViewController else {
                fatalError("Unknown destination for segue description: \(segue.destination)")
            }
            if user.userDescription != nil {
                controller.cookDescription = user.userDescription!
            }
            controller.sourceVC = self
        }
    }
    

}
