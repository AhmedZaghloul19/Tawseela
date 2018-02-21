//
//  User.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/8/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import Foundation
class User {
    var token :String?
    var type : Role?
    var id : String?
    var name : String?
    var image : String?
    var user_rates:[Rate] = []
    var driver_rates:[Rate] = []
    var usersRateAvg:Double?
    
    init(id: String, name: String, image: String,token:String,type:Role) {
        self.id = id
        self.name = name
        self.image = image
        self.token = token
        self.type = type
    }
    
    init(data:AnyObject){
        if let data = data as? NSDictionary {
            print(data)
            self.id = data.getValueForKey(key: "id", callback: "")
            self.name = data.getValueForKey(key: "name", callback: "")
            self.image = data.getValueForKey(key: "logo", callback: "")
            self.token = data.getValueForKey(key: "token", callback: "")
            self.type = Role(rawValue: data.getValueForKey(key: "type", callback: "user"))
            print(data)
            let rates = data.getValueForKey(key: "user_rate", callback: [[String:Any]()])
            for rate in rates {
                let rt = Rate(data: rate as AnyObject)
                self.user_rates.append(rt)
            }
        }
    }
    
}

class Rate  {
    var phone :String?
    var rate:Double?
    var review:String?
    var date:String?
    
    init(data:AnyObject){
        if let data = data as? NSDictionary {
            print(data)
            self.phone = data.getValueForKey(key: "phone", callback: "")
            self.rate = data.getValueForKey(key: "rate", callback: 0.0)
            self.review = data.getValueForKey(key: "review", callback: "")
        }
    }

}
