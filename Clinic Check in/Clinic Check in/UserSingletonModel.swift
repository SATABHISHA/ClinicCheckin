//
//  UserSingletonModel.swift
//  Clinic Check in
//
//  Created by MK on 30/04/18.
//  Copyright © 2018 Savant care. All rights reserved.
//

import Foundation

class UserSingletonModel: NSObject {
    static let sharedInstance = UserSingletonModel()
    
    var numberWithCode:String!
    var fullname:String!
    var userid:Int!
    var uuid: String!
    
    //------variables for countdown-------
    var remainingtime:String?
    
    //------variables for login-------
    var countrycode:String?
    var firebaseInstanceId:String!
    
//----variables for contact page----
    var indexData:String!
    
    //------variables for screening---------
    var selectedScreen = [String:AnyObject]()
}
