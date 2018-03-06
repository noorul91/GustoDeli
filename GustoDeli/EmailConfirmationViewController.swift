//
//  EmailConfirmationViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EmailConfirmationViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var resendEmailButton: UIButton!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var emailImage: UIImageView!
    
    //MARK:- Properties
    var user: User!
    let usersRef = FIRDatabase.database().reference(withPath: "Users")
    
    //MARK:- Life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            let thisUserRef = usersRef.child(userID)
            
            thisUserRef.observeSingleEvent(of: .value, with: { snapshot in
                self.user = User(keyValuePair: snapshot.value as! [String : AnyObject], userId: userID)
                self.emailImage.image = self.emailImage.image?.withRenderingMode(.alwaysTemplate)
                self.emailImage.tintColor = UIColor().themeColor()
                self.resendEmailButton.customizeStandardButton()
                self.emailAddressLabel.text = self.user.emailAddress
            })
        }
    }
    
    //MARK:- Action
    @IBAction func resendEmailButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "signUp", sender: self)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUp" {
            guard let nav = segue.destination as? UINavigationController,
                let controller = nav.viewControllers.first as? MealPreviewViewController else {
                    fatalError("Unknown destination for segue signUp: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "login" {
            guard let nav = segue.destination as? UINavigationController,
                let _ = nav.viewControllers.first as? MealPreviewViewController else {
                    fatalError("Unknown destination for segue login: \(segue.destination)")
            }
        }
    }
}
