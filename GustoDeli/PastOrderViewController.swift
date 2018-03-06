//
//  PastOrderViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class PastOrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK:- IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var foodBackgroundView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var noOrderLabel: UILabel!
    
    //MARK:- Properties
    var user: User!
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if user.myOrder.count != 0 {
            foodBackgroundView.isHidden = true
            colorView.isHidden = true
            noOrderLabel.isHidden = true
        }
    }

    //MARK:- Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return user.myOrder.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderTableViewCell
        cell.addShadowToCell()
        //cell.order = user.order[indexPath.section]
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
