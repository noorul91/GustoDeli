//
//  ThanksViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/18/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class ThanksViewController: UIViewController {

    //MARK:- Properties
    var user: User!
    
    //MARK:- Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        setupEmptyScreen()
    }

    //MARK:- Private
    fileprivate func setupEmptyScreen() {
        if let cookName = user.userName {
            self.view.backgroundColor = .white
            let label = Helper().createLabel(x: view.frame.width/2 - 125, y: 30, width: 250, height: 100, textAlignment: .center, labelText: "No thanks received by \(cookName) yet.", textColor: .lightGray)
            label.numberOfLines = 0
            label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 17)
            view.addSubview(label)
        }
    }

}
