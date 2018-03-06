//
//  ButtonTableViewCell.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    //MARK:- IBOutlet
    @IBOutlet weak var mButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mButton.layer.cornerRadius = 25
    }

}
