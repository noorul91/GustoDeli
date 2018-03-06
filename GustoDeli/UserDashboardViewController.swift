//
//  UserDashboardViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/18/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class UserDashboardViewController: UIViewController {

    //MARK:- IBOutlets
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userBackgroundPhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var numberOfFollowerLabel: UILabel!
    @IBOutlet weak var numberOfFollowingLabel: UILabel!
    @IBOutlet weak var numberOfListingLabel: UILabel!
    @IBOutlet weak var segmentedControl: TabSegmentedControl!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    //MARK:- Properties
    var currentUser: User!
    var viewedUser: User!
    var currentViewController: UIViewController?
    
    enum TabIndex: Int {
        case firstChildTab = 0
        case secondChildTab = 1
    }
    
    lazy var firstChildTabVC: UIViewController? = {
        var firstChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "ListingVC")
        if let controller = firstChildTabVC as? ListingViewController {
            controller.user = self.viewedUser
            controller.source = self
            firstChildTabVC = controller
        }
        return firstChildTabVC
    }()
    
    lazy var secondChildTabVC: UIViewController? = {
        var secondChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "ThanksVC")
        if let controller = secondChildTabVC as? ThanksViewController {
            controller.user = self.viewedUser
            secondChildTabVC = controller
        }
        return secondChildTabVC
    }()
    
    //MARK:- Life cycles
    override func viewWillAppear(_ animated: Bool) {
        scrollViewTopConstraint.constant = UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height)!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }


    //MARK:- Action
    @IBAction func switchTabs(_ sender: UISegmentedControl) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
    
    @IBAction func tappedFollowButton(_ sender: UIButton) {
        var alreadyFollowed = false
        //verify if current user already followed viewed user
        /**
        for user in viewedUser.followers {
            if user.userId == currentUser.userId {
                alreadyFollowed = true
            }
        }
        if alreadyFollowed {
            //promopt message to confirm unfollow
            let alert = UIAlertController(title: "Gusto Deli", message: "Are you sure you want to unfollow this user?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                if let index = self.viewedUser.followers.index(of: self.currentUser) {
                    self.viewedUser.followers.remove(at: index)
                }
                if let index = self.currentUser.followings.index(of: self.currentUser) {
                    self.currentUser.followings.remove(at: index)
                }
                //update follow button appearance
                self.followButton.setImage(UIImage(named: "Follow icon"), for: UIControlState())
                self.followButton.setTitle("", for: UIControlState())
                self.followButton.layer.borderWidth = 0
                self.numberOfFollowerLabel.text = String(self.viewedUser.followers.count)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            viewedUser.followers.append(currentUser)
            currentUser.followings.append(viewedUser)
            
            //update follow button apperance
            followButton.setImage(nil, for: UIControlState())
            followButton.setTitle("Following", for: UIControlState())
            followButton.setTitleColor(UIColor().themeColor(), for: UIControlState())
            followButton.setBorderWidthColor(2.0, borderColor: UIColor().themeColor(), cornerRadius: 20.0)
        }
        numberOfFollowerLabel.text = String(viewedUser.followers.count)**/
    }
    
    //MARK:- Private
    fileprivate func setupUI() {
        numberOfFollowerLabel.text = String(viewedUser.followers.count)
        numberOfFollowingLabel.text = String(viewedUser.followings.count)
        
        //userPhoto.image = viewedUser.userPhoto
        //userBackgroundPhoto.image = viewedUser.userPhoto
        userBackgroundPhoto.setBorder()
        userPhoto.setRoundedBorder()
        userPhoto.setBorderWidthColor(3.0, borderColor: .white)
        
        descriptionLabel.text = viewedUser.userDescription
        nameLabel.text = viewedUser.userName
        locationLabel.text = viewedUser.userLocation
        //numberOfListingLabel.text = String(viewedUser.meals.count)
        
        segmentedControl.initUI()
        segmentedControl.selectedSegmentIndex = TabIndex.firstChildTab.rawValue
        displayCurrentTab(TabIndex.firstChildTab.rawValue)
        
    }
    
    fileprivate func displayCurrentTab(_ tabIndex: Int) {
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            self.addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
        }
    }
    
    fileprivate func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        switch index {
        case TabIndex.firstChildTab.rawValue:
            return firstChildTabVC
        case TabIndex.secondChildTab.rawValue:
            return secondChildTabVC
        default:
            return nil
        }
    }
}
