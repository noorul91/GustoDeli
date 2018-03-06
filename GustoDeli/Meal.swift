//
//  Meal.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

class Meal {
    var mealId: String
    var mealName: String!
    var mealPhoto: UIImage?
    var mealPhotoUrl: String!
    var category: String!
    var quantity: Int!
    var mealDescription: String!
    var mealSideDish: String?
    var mealPrice: CGFloat!
    var orderCutOffTime: String!
    var deliveryTimeRange: String!
    var deliveryDate: String!
    var ingredients: [String]?
    var cook: User!
    var numberOfOrder: Int = 0
    var numberOfUnconfirmedOrder: Int = 0
    var firstTimeMeal = true
    var soldOut = false
    
    init?(mealName: String!, mealDescription: String!, mealSideDish: String?, quantity: Int!, mealPrice: CGFloat!, orderCutOffTime: String!, deliveryDate: String!, deliveryTimeRange: String!, category: String!, ingredients: [String], cook: User!, mealId: String = "", mealPhotoUrl: String = "") {
        self.mealId = mealId
        self.mealName = mealName
        self.mealPhotoUrl = mealPhotoUrl
        self.mealDescription = mealDescription
        self.mealSideDish = mealSideDish
        self.quantity = quantity
        self.mealPrice = mealPrice
        self.orderCutOffTime = orderCutOffTime
        self.deliveryDate = deliveryDate
        self.deliveryTimeRange = deliveryTimeRange
        self.category = category
        self.ingredients = ingredients
        self.cook = cook
    }
    
    init(snapshotValue: [String: AnyObject], mealId: String!) {
        self.mealId = mealId
        mealName = snapshotValue["mealName"] as! String
        mealPhotoUrl = snapshotValue["mealPhotoUrl"] as! String
        mealDescription = snapshotValue["mealDescription"] as! String
        mealSideDish = snapshotValue["mealSideDish"] as? String
        mealPrice = snapshotValue["mealPrice"] as! CGFloat
        orderCutOffTime = snapshotValue["orderCutOffTime"] as! String
        deliveryDate = snapshotValue["deliveryDate"] as! String
        deliveryTimeRange = snapshotValue["deliveryTimeRange"] as! String
        category = snapshotValue["category"] as! String
        numberOfOrder = snapshotValue["numberOfOrder"] as! Int
        quantity = snapshotValue["quantity"] as! Int
        numberOfUnconfirmedOrder = snapshotValue["numberOfUnconfirmedOrder"] as! Int
        firstTimeMeal = snapshotValue["firstTimeMeal"] as! Bool
        soldOut = snapshotValue["soldOut"] as! Bool
        if snapshotValue["ingredients"] != nil {
            ingredients = getDictionaryKeyArrays(snapshotValue["ingredients"] as! NSDictionary)
        }
    }
    
    init(snapshot: FIRDataSnapshot) {
        mealId = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        mealName = snapshotValue["mealName"] as! String
        mealPhotoUrl = snapshotValue["mealPhotoUrl"] as! String
        mealDescription = snapshotValue["mealDescription"] as! String
        mealSideDish = snapshotValue["mealSideDish"] as? String
        mealPrice = snapshotValue["mealPrice"] as! CGFloat
        orderCutOffTime = snapshotValue["orderCutOffTime"] as! String
        deliveryDate = snapshotValue["deliveryDate"] as! String
        deliveryTimeRange = snapshotValue["deliveryTimeRange"] as! String
        category = snapshotValue["category"] as! String
        numberOfOrder = snapshotValue["numberOfOrder"] as! Int
        quantity = snapshotValue["quantity"] as! Int
        numberOfUnconfirmedOrder = snapshotValue["numberOfUnconfirmedOrder"] as! Int
        firstTimeMeal = snapshotValue["firstTimeMeal"] as! Bool
        soldOut = snapshotValue["soldOut"] as! Bool
        if snapshotValue["ingredients"] != nil {
            ingredients = getDictionaryKeyArrays(snapshotValue["ingredients"] as! NSDictionary)
        }
    }
    
    func toAnyObject() -> Any {
        return ["mealName": mealName, "mealDescription": mealDescription, "mealSideDish": mealSideDish ?? "", "mealPrice": mealPrice, "deliveryTimeRange": deliveryTimeRange, "orderCutOffTime": orderCutOffTime, "deliveryDate": deliveryDate, "cook": cook.userId, "numberOfOrder": numberOfOrder, "numberOfUnconfirmedOrder": numberOfUnconfirmedOrder, "firstTimeMeal": firstTimeMeal, "soldOut": soldOut, "mealPhotoUrl": mealPhotoUrl, "ingredients": "", "category": category, "quantity": quantity]
    }
    
    func getDictionaryKeyArrays(_ dict: NSDictionary) -> [String] {
        return dict.allKeys as! [String]
    }
    
    func getFormattedMealPrice() -> String {
        return NSString(format: "%.2f", mealPrice) as String
    }
}

