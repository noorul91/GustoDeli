//
//  MenuViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/16/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class MenuViewController: UIViewController {

    //MARK:- IBOutlets
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonBackgroundView: UIVisualEffectView!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var myAdsButton: UIButton!
    
    //MARK:- Properties
    var user: User?
    
    lazy var loginVC: LoginViewController? = {
        var loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        loginVC.sourceController = self
        return loginVC
    }()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK:- Action
    @IBAction func tappedCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func swipedLeft(_ gesture: UIGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func profileButtonTapped(_ sender: UIButton) {
        if user != nil {
            performSegue(withIdentifier: "toProfile", sender: self)
        } else {
            //User is not logged in yet, so we prompt log in screen
            if let controller = loginVC {
                self.present(controller, animated: true, completion: nil)
            }
            
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        //prompt alert to confirm logout
        let alert = UIAlertController(title: "Gusto Deli", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction) in
            do {
                try! FIRAuth.auth()!.signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
            self.performSegue(withIdentifier: "logout", sender: self)
            
        })
        alert.addAction(UIAlertAction(title: "No", style: .default) { (action: UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        })
        self.present(alert, animated: true, completion: nil)
    }
 
    
    //MARK:- Private
    fileprivate func setupUI() {
        if user != nil {
            userPhoto.loadImageWithCacheWithUrlString((user?.userPhoto)!)
            userPhoto.setRoundedBorder()
            userPhoto.setBorderWidthColor(3.0, borderColor: UIColor().hexStringToUIColor(hexString: "#8A8A8A", alpha: 1.0))
            
            userNameLabel.text = user?.userName
            
            if user?.listing.count != 0 {
                createBadgeLabelForListing()
            }
            if user?.myOrder.count != 0 {
                createBadgeLabelForOrder()
            }
        } else {
            userPhoto.isHidden = true
            userNameLabel.isHidden = true
            logoutButton.isHidden = true
        }
        closeButtonBackgroundView.setRoundedBorder()
        
    }
    
    fileprivate func createBadgeLabelForListing() {
        if let totalListing = user?.listing.count {
            view.addSubview(createBadgeLabel(190, y: 213, numberString: String(totalListing)))
        }
        
    }

    fileprivate func createBadgeLabelForOrder() {
        if let totalOrder = user?.myOrder.count {
            view.addSubview(createBadgeLabel(190, y: 153, numberString: String(totalOrder)))
        }
    }
    
    fileprivate func createBadgeLabel(_ x: CGFloat, y: CGFloat, numberString: String)-> UILabel {
        let label = Helper().createLabel(x: x, y: y, width: 40, height: 30, textAlignment: .center, labelText: numberString, textColor: UIColor().hexStringToUIColor(hexString: "#484848", alpha: 1.0))
        label.layer.cornerRadius = 14
        label.layer.masksToBounds = true
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 25)
        label.backgroundColor = UIColor().themeColor()
        return label
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            guard let nav = segue.destination as? UINavigationController,
                let controller = nav.viewControllers.first as? ProfileViewController else {
                    fatalError("Unknown destination for segue toProfile: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "logout" {
            guard segue.destination is LoginViewController else {
                fatalError("Unknown destination for segue logout: \(segue.destination)")
            }
        } else if segue.identifier == "showMyOrders" {
            guard let nav = segue.destination as? UINavigationController,
                let controller = nav.viewControllers.first as? MyOrdersViewController else {
                    fatalError("Unknown destination for segue showMyOrders: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "toFAQ" {
            guard let nav = segue.destination as? UINavigationController,
                let controller = nav.viewControllers.first as? FAQViewController else {
                    fatalError("Unknown destination for segue toFAQ: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "toAbout" {
            guard let nav = segue.destination as? UINavigationController,
                let controller = nav.viewControllers.first as? AboutViewController else {
                    fatalError("Unknown destination for segue toAbout: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "toListing" {
            guard let nav = segue.destination as? UINavigationController,
                let controller = nav.viewControllers.first as? ListingViewController else {
                    fatalError("Unknown destination for segue toListing: \(segue.destination)")
            }
            controller.user = user
            controller.source = self
        }
        
    }
}
