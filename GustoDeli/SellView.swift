//
//  SellView.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class SellView: UIView {

    //MARK:- IBOutlet
    @IBOutlet weak var sellButton: UIButton!

    //MARK:- Properties
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    
    override func awakeFromNib() {
        sellButton.addShadowToPriceTag()
        frame = CGRect(x: screenWidth - 80, y: screenHeight - 90, width: 80, height: 80)
    }
}
