//
//  User.swift
//  GustoDeli
//
//  Created by Noorul Atieqah Binti Mohamad Rosli on 8/18/17.
//  Copyright © 2017 Noorul Atieqah Binti Mohamad Rosli. All rights reserved.
//

import UIKit
import Firebase

enum Gender: String {
    case Female = "Female"
    case Male = "Male"
}

enum AddressType: String {
    case Home = "Home"
    case Work = "Work"
    case Other = "Other"
}

struct Address {
    let id : String
    let addressType: AddressType
    let buildingName: String
    let streetName: String
    let zipCode: Int
    let city: String
    
    init(addressType: AddressType, buildingName: String, streetName: String, zipCode: Int, city: String, id : String = "") {
        self.id = id
        self.addressType = addressType
        self.buildingName = buildingName
        self.streetName = streetName
        self.zipCode = zipCode
        self.city = city
    }
    
    init(snapshot: FIRDataSnapshot) {
        id = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        let addressTypeFromFirebase = snapshotValue["addressType"] as! String
        if addressTypeFromFirebase == AddressType.Home.rawValue {
            addressType = AddressType.Home
        } else if addressTypeFromFirebase == AddressType.Work.rawValue {
            addressType = AddressType.Work
        } else {
            addressType = AddressType.Other
        }
        buildingName = snapshotValue["buildingName"] as! String
        streetName = snapshotValue["streetName"] as! String
        zipCode = snapshotValue["zipCode"] as! Int
        city = snapshotValue["city"] as! String
    }
    
    init(snapshotValue: [String: AnyObject], addressId: String!) {
        id = addressId
        let addressTypeFromFirebase = snapshotValue["addressType"] as! String
        if addressTypeFromFirebase == AddressType.Home.rawValue {
            addressType = AddressType.Home
        } else if addressTypeFromFirebase == AddressType.Work.rawValue {
            addressType = AddressType.Work
        } else {
            addressType = AddressType.Other
        }
        buildingName = snapshotValue["buildingName"] as! String
        streetName = snapshotValue["streetName"] as! String
        zipCode = snapshotValue["zipCode"] as! Int
        city = snapshotValue["city"] as! String
    }
    
    func toAnyObject() -> Any {
        return ["addressType": addressType.rawValue,
         "buildingName": buildingName,
         "streetName": streetName,
         "zipCode": zipCode,
         "city": city]
    }
}

class User {
    let userId: String
    var userName: String!
    var userPhoto: String!
    var userDescription: String?
    var userLocation: String?
    var emailAddress: String!
    var password: String!
    var gender = Gender.Female
    var addresses = [String]()
    var followers = [String]()
    var followings = [String]()
    var myOrder = [String]()
    var listing = [String]()
    
    init(authData: FIRUser) {
        userId = authData.uid
        emailAddress = authData.email!
    }
    
    init(snapshotValue: [String: AnyObject], userId: String!) {
        self.userId = userId
        userName = snapshotValue["userName"] as! String
        emailAddress = snapshotValue["emailAddress"] as! String
        password = snapshotValue["password"] as! String
        userPhoto = snapshotValue["userPhoto"] as! String
        let genderFromFirebase = snapshotValue["gender"] as! String
        if genderFromFirebase == Gender.Female.rawValue {
            gender = Gender.Female
        } else {
            gender = Gender.Male
        }
        userDescription = snapshotValue["userDescription"] as? String
        userLocation = snapshotValue["userLocation"] as? String

        if snapshotValue["addresses"] != nil {
            addresses = getDictionaryKeyArrays(snapshotValue["addresses"] as! NSDictionary)
        } 
        if snapshotValue["listing"] != nil {
            listing = getDictionaryKeyArrays(snapshotValue["listing"] as! NSDictionary)
        }
        if snapshotValue["order"] != nil {
            getMyOrdersExceptOngoing(snapshotValue["order"] as! NSDictionary)
        }
        if snapshotValue["followers"] != nil {
            followers = getDictionaryKeyArrays(snapshotValue["followers"] as! NSDictionary)
        }
        if snapshotValue["followings"] != nil {
            followings = getDictionaryKeyArrays(snapshotValue["followings"] as! NSDictionary)
        }
    }

    
    init(keyValuePair: [String: AnyObject], userId: String!) {
        self.userId = userId
        self.userName = keyValuePair["userName"] as! String
        self.emailAddress = keyValuePair["emailAddress"] as! String
        self.password = keyValuePair["password"] as! String
        self.userPhoto = keyValuePair["userPhoto"] as! String
    }
    
    func getDictionaryKeyArrays(_ dict: NSDictionary) -> [String] {
        return dict.allKeys as! [String]
    }
    
    func getMyOrdersExceptOngoing(_ dict: NSDictionary) {
        myOrder = getDictionaryKeyArrays(dict)
        
        //Retrieve all active orders from Firebase
        
        for (index, element) in myOrder.enumerated() {
            var indexArray: [Int] = []
            Helper().loadOrderInformation(element, childrenName: "orderStatus", completion: { value in
                if let status = value as? String {
                    if status == OrderStatus.ongoing.rawValue {
                        indexArray.append(index)
                    }
                    if index == self.myOrder.count - 1 {
                        for e in indexArray {
                            self.myOrder.remove(at: e)
                        }
                    }
                }
            })
        }
    }
}

extension User: Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.userId == rhs.userId
    }
}

