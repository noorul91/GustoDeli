//
//  Ingredient.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Ingredient: Equatable {
    var name: String
    var photo: UIImage?
    
    init?(name: String) {
        self.name = name
        
        guard !name.isEmpty else {
            return nil
        }
    }
    
    init(snapshot: FIRDataSnapshot) {
        name = snapshot.key
        //urlString = snapshot.value as! String
    }
    
    func toAnyObject() -> Any {
        return ["name": name, "urlString": ""]
    }
}

func ==(lhs: Ingredient, rhs: Ingredient) -> Bool {
    return lhs.name == rhs.name
}
