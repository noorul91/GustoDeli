//
//  T_CViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class T_CViewController: UIViewController {

    //MARK:- IBOutlets
    var sourceViewController: UIViewController!
    
    //MARK:- Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setupThemeColorNavBar()
    }
    
    //MARK:- Action
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        if (sourceViewController as? LoginViewController) != nil {
            performSegue(withIdentifier: "backToLoginpage", sender: self)
        } else if (sourceViewController as? SignUpViewController) != nil {
            performSegue(withIdentifier: "backToSignupPage", sender: self)
        } else if (sourceViewController as? AboutViewController) != nil {
            performSegue(withIdentifier: "backToAboutPage", sender: self)
        }
    }
}
