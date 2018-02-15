//
//  UserRecord.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/8/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import Foundation
class UserRecord {
    var mobile:String?
    var user:User?
    
    init(data:AnyObject){
        if let data = data as? NSDictionary {
            print(data)
            user = User(data: data as AnyObject)
        }
    }
    
    init() {
        
    }
    
}
