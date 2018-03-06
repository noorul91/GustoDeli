//
//  CookDescriptionViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/16/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class CookDescriptionViewController: UIViewController, UITextViewDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var countLabel: UILabel!
    
    //MARK:- Properties
    let PLACEHOLDER_TEXT = "Appeal yourself to customers in at least 100 characters."
    var cookDescription = ""
    var sourceVC: UIViewController!

    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if cookDescription != "" {
            descriptionTextView.text = cookDescription
        } else {
            descriptionTextView.applyPlaceholderStyle(placeholderText: PLACEHOLDER_TEXT)
        }
        
        if descriptionTextView.text != PLACEHOLDER_TEXT {
            countLabel.text = "Characters count: \(descriptionTextView.text.characters.count)"
        } else {
            countLabel.text = "Characters count: 0"
        }
    }
    
    //MARK:- Action
    @IBAction func tappedSaveButton(_ sender: UIButton) {
        if !descriptionTextView.isFirstResponder {
            if descriptionTextView.text != PLACEHOLDER_TEXT {
                if descriptionTextView.text.characters.count < 100 {
                    Helper().displayAlertMessage(self, messageToDisplay: "Description must be at least 100 characters.", completionHandler: nil)
                }
            }
            if (sourceVC as? AddMealViewController) != nil {
                performSegue(withIdentifier: "unwindToAddMeal", sender: self)
            } else if (sourceVC as? ProfileViewController) != nil {
                performSegue(withIdentifier: "backToSetting", sender: self)
            }
        }
    }
    
    
    //MARK:- UITextViewDelegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == descriptionTextView && textView.text == PLACEHOLDER_TEXT {
            textView.moveCursorToStart()
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            if (textView == descriptionTextView) {
                cookDescription = textView.text
            }
            updateDoneButtonState()
            return false
        }
        
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if textView.text != PLACEHOLDER_TEXT {
            countLabel.text = "Characters count: \(newLength)"
        } else {
            countLabel.text = "Characters count: 0"
        }
        
        if newLength > 0 {
            //check if the only text is the placeholder & remove it if needed
            if (textView == descriptionTextView && textView.text == PLACEHOLDER_TEXT) {
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
            if (textView == descriptionTextView) {
                textView.applyPlaceholderStyle(placeholderText: PLACEHOLDER_TEXT)
                updateDoneButtonState()
            }
            textView.moveCursorToStart()
            return false
        }
    }
    
    //MARK:- Private
    fileprivate func updateDoneButtonState() {
        let descriptionText = descriptionTextView.text ?? ""
        doneButton.isEnabled = !(descriptionText.isEmpty) && descriptionTextView.text.characters.count >= 100
        if descriptionTextView.text != PLACEHOLDER_TEXT {
            if descriptionTextView.text.characters.count < 100 {
                Helper().displayAlertMessage(self, messageToDisplay: "Description must be at least 100 characters.", completionHandler: nil)
            }
        }
    }
}
