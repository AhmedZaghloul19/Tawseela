//
//  AppNotification.swift
//  Amriya
//
//  Created by Ahmed Zaghloul on 11/19/17.
//  Copyright © 2017 RKAnjel. All rights reserved.
//

import Foundation

class AppNotification {
    
    public var title:String?
    public var message:String?
    public var kind:NotificationType?
    public var id:String?
    
    init(data:AnyObject){
        if let data = data as? NSDictionary {
            message = data.getValueForKey(key: "message", callback: "")
            kind = NotificationType(rawValue: data.getValueForKey(key: "kind", callback: "pay"))
            id = data.getValueForKey(key: "data", callback: "")
            title = data.getValueForKey(key: "title", callback: "")
        }
    }
}


