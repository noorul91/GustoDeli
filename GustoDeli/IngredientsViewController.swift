//
//  IngredientsViewController.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class IngredientsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    //MARK:- IBOutlets
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var mCollectionView: UICollectionView!
    
    //MARK:- Properties
    var ingredients : [String] = []
    var selectedIngredients: [String] = []
    let ingredientsRef = FIRDatabase.database().reference(withPath: "Ingredients")
    
    //MARK:- Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mCollectionView?.allowsMultipleSelection = true

        //load ingredients from Firebase
        ingredientsRef.observeSingleEvent(of: .value, with: { snapshot in
            var newItems: [String] = []
            for item in snapshot.children {
                let item = item as! FIRDataSnapshot
                newItems.append(item.key)
            }
            self.ingredients = newItems
            self.mCollectionView.reloadData()
        })
        updateDoneButtonState()
    }
    
    //MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! IngredientsCollectionViewCell
        cell.ing = ingredients[indexPath.row]
        
        if selectedIngredients.contains(ingredients[indexPath.row]) {
            //highlight the cell
            cell.layer.borderWidth = 5.0
            cell.layer.borderColor = UIColor().themeColor().cgColor
            cell.isSelected = true
            mCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init(rawValue: 0))
        } else {
            cell.layer.borderWidth = 0
            cell.layer.borderColor = nil
            cell.isSelected = false
        }
        return cell
    }
    
    //MARK:- Action
    @IBAction func tappedDoneButton(_ sender: UIButton!) {
        performSegue(withIdentifier: "unwindToAddMealVC", sender: self)
    }
    
    //MARK:- Private 
    
    
//    fileprivate func loadIngredients() {
//        if let path = Bundle.main.path(forResource: "Ingredients", ofType: "plist") {
//            if let dictArray = NSArray(contentsOfFile: path) {
//                for item in dictArray {
//                    if let dict = item as? NSDictionary {
//                        let name = dict["name"] as! String
//                        let ing = Ingredient(name: name)
//                        ingredients.append(ing!)
//                    }
//                }
//            }
//        }
//    }
    
    fileprivate func updateDoneButtonState() {
        if selectedIngredients.count == 0 {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
    
    fileprivate func highlightCell(_ cell: IngredientsCollectionViewCell, indexPath: IndexPath) {
        if cell.isSelected {
            cell.layer.borderWidth = 5.0
            cell.layer.borderColor = UIColor().themeColor().cgColor
        } else {
            cell.layer.borderWidth = 0
            cell.layer.borderColor = nil
        }
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! IngredientsCollectionViewCell
        let ingredient = selectedCell.ingredientNameLabel.text
        selectedIngredients.append(ingredient!)
        highlightCell(selectedCell, indexPath: indexPath)
        updateDoneButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! IngredientsCollectionViewCell

        if let ingredient = selectedCell.ingredientNameLabel.text {
            if let index = selectedIngredients.index(of: ingredient) {
                selectedIngredients.remove(at: index)
            }
            highlightCell(selectedCell, indexPath: indexPath)
        }
    }
}
