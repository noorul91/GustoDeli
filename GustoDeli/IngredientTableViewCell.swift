//
//  IngredientTableViewCell.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit

class IngredientTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    //MARK:- IBOutlet
    @IBOutlet weak var mCollectionView: UICollectionView!
    
    //MARK:- Properties
    var ingredients: [String]! {
        didSet {
            mCollectionView.reloadData()
        }
    }

    //MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ingredientCell", for: indexPath) as! IngredientsCollectionViewCell
        cell.ing = ingredients[indexPath.item]
        return cell
    }

}
