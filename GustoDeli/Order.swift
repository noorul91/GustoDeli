//
//  Order.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/17/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

enum OrderStatus : String {
    case ongoing = "Ongoing"
    case unconfirmed = "Unconfirmed"
    case confirmed = "Confirmed"
}

class Order {
    var orderId: String!
    var mealId: String!
    var numberOfOrder: Int!
    var orderedBy: String!
    var deliveryDate: String!
    var deliveryAddressId: String?
    var deliveryTime: String?
    var remark: String?
    var phoneNumber: String?
    var orderStatus: OrderStatus!
    
    init?(mealId: String!, numberOfOrder: Int!, orderedBy: String!, deliveryDate: String!, orderId: String = "",deliveryAddressId: String? = "", deliveryTime: String? = "", remark: String? = "", phoneNumber: String? = "", orderStatus: OrderStatus! = OrderStatus.ongoing) {
        self.orderId = orderId
        self.mealId = mealId
        self.numberOfOrder = numberOfOrder
        self.orderedBy = orderedBy
        self.deliveryDate = deliveryDate
        self.deliveryAddressId = deliveryAddressId
        self.deliveryTime = deliveryTime
        self.remark = remark
        self.phoneNumber = phoneNumber
        self.orderStatus = orderStatus
    }
    
    init(snapshot: FIRDataSnapshot) {
        orderId = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        mealId = snapshotValue["mealId"] as! String
        numberOfOrder = snapshotValue["numberOfOrder"] as! Int
        orderedBy = snapshotValue["orderedBy"] as! String
        deliveryAddressId = snapshotValue["deliveryAddressId"] as? String
        deliveryTime = snapshotValue["deliveryTime"] as? String
        remark = snapshotValue["remark"] as? String
        phoneNumber = snapshotValue["phoneNumber"] as? String
        deliveryDate = snapshotValue["deliveryDate"] as! String
        
        let status = snapshotValue["orderStatus"] as! String
        orderStatus = getOrderStatus(status)
    }
    
    init(snapshotValue: [String: AnyObject], orderId: String!) {
        self.orderId = orderId
        mealId = snapshotValue["mealId"] as! String
        numberOfOrder = snapshotValue["numberOfOrder"] as! Int
        orderedBy = snapshotValue["orderedBy"] as! String
        deliveryAddressId = snapshotValue["deliveryAddressId"] as? String
        deliveryTime = snapshotValue["deliveryTime"] as? String
        remark = snapshotValue["remark"] as? String
        phoneNumber = snapshotValue["phoneNumber"] as? String
        deliveryDate = snapshotValue["deliveryDate"] as! String
        
        let status = snapshotValue["orderStatus"] as! String
        orderStatus = getOrderStatus(status)
    }

    func getOrderStatus(_ status: String) -> OrderStatus {
        switch(status) {
        case OrderStatus.ongoing.rawValue:
            return OrderStatus.ongoing
        case OrderStatus.unconfirmed.rawValue:
            return OrderStatus.unconfirmed
        default:
            return OrderStatus.confirmed
        }
    }
    
    func toAnyObject() -> Any {
        return ["mealId": mealId,
                "numberOfOrder": numberOfOrder,
                "orderedBy": orderedBy,
                "deliveryAddressId": deliveryAddressId as Any,
                "deliveryDate": deliveryDate,
                "deliveryTime": deliveryTime as Any,
                "remark": remark as Any,
                "phoneNumber" : phoneNumber as Any,
                "orderStatus": orderStatus.rawValue as Any]
    }
}

extension Order: Equatable {
    static func ==(lhs: Order, rhs: Order) -> Bool {
        return lhs.orderId == rhs.orderId
    }
}
