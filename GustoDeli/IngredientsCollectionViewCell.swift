//
//  IngredientsCollectionViewCell.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class IngredientsCollectionViewCell: UICollectionViewCell {
    //MARK:- IBOutlets
    @IBOutlet weak var ingredientImageView: UIImageView!
    @IBOutlet weak var ingredientNameLabel: UILabel!
    
    var ing: String! {
        didSet {
            setupUI()
        }
    }
    
    fileprivate func setupUI() {
        self.backgroundColor = .white
        ingredientNameLabel.text = ing
        //Get the ingredient's photo from Firebase
        let ingredientRef = FIRDatabase.database().reference().child("Ingredients").child(ing)
        ingredientRef.observeSingleEvent(of: .value, with: { snapshot in
            if let urlString = snapshot.value as? String {
                self.ingredientImageView.loadImageWithCacheWithUrlString(urlString)
            }
        })
    }
}
