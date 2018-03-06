//
//  FAQViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {

    enum TabIndex: Int {
        case firstChildTab = 0
        case secondChildTab = 1
    }
    
    //MARK:- IBOutlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var askButton: UIButton!
    @IBOutlet weak var segmentedControl: TabSegmentedControl!
    

    
    //MARK:- Properties
    var user: User!
    var currentViewController: UIViewController!
    
    lazy var firstChildTabVC: UIViewController? = {
        var firstChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "topicVC")
        return firstChildTabVC
    }()
    
    lazy var secondChildTabVC: UIViewController? = {
        var secondChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "questionVC")
        return secondChildTabVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    //MARK:- Action
    @IBAction func switchTabs(_ sender: TabSegmentedControl) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "backToMainPage", sender: self)
    }
    
    //MARK:- Private
    fileprivate func setupUI() {
        self.navigationController?.navigationBar.setupThemeColorNavBar()
        askButton.customizeStandardButton()
        
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
    

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToMainPage" {
            guard let controller = segue.destination as? MealPreviewViewController else {
                fatalError("Unknown destinatoin for segue backToMainPage: \(segue.destination)")
            }
            controller.user = user
        } else if segue.identifier == "askGustoDeli" {
            guard let controller = segue.destination as? AskGustoViewController else {
                fatalError("Unknown destinatoin for segue askGustoDeli: \(segue.destination)")
            }
            controller.user = user
        }
    }

}
