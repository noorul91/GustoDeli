//
//  CompleteOrderViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/16/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class CompleteOrderViewController: UIViewController {

    //MARK:- IBOutlets
    @IBOutlet weak var homePageButton: UIButton!
    @IBOutlet weak var trackOrderButton: UIButton!
    
    //MARK:- Properties
    var user: User!
  
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        homePageButton.setBorderWidthColor(2, borderColor: UIColor().themeColor(), cornerRadius: 25)
        homePageButton.addBottomShadow()
        trackOrderButton.customizeStandardButton()
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    //MARK:- Action
    @IBAction func tappedTrackOrderButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toOrderDetails", sender: self)
    }
    
    @IBAction func tappedHomePageButton(_ sender: UIButton) {
        performSegue(withIdentifier: "orderAccepted", sender: self)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "orderAccepted" {
            guard let controller = segue.destination as? MealPreviewViewController else {
                    fatalError("Unknown destination for segue orderAccepted: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "toOrderDetails" {
            guard let controller = segue.destination as? OrderSummaryViewController else {
                    fatalError("Unknown destination for segue toOrderDetails: \(segue.destination)")
            }
        }
    }
 

}
