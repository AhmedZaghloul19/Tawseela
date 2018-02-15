//
//  GooglePlace.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/8/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import Foundation

class GooglePlacesItem {
    var id:String?
    var icon:String?
    var name:String?
    var lat:Float?
    var lng:Float?
    var vicinity:String?
    
    init(data:AnyObject){
        if let data = data as? NSDictionary {
            self.id = data.getValueForKey(key: "id", callback: "")
            self.name = data.getValueForKey(key: "name", callback: "")
            self.icon = data.getValueForKey(key: "icon", callback: "")
            self.vicinity = data.getValueForKey(key: "vicinity", callback: "")
            let geo = data.getValueForKey(key: "geometry", callback: NSDictionary())
            let loc = geo.getValueForKey(key: "location", callback: NSDictionary())
            lat = loc.getValueForKey(key: "lat", callback: 0.0)
            lng = loc.getValueForKey(key: "lng", callback: 0.0)
        }
    }
    
    init(id:String,icon:String,name:String,lat:Float,lng:Float,vicinity:String) {
        self.id = id
        self.icon = icon
        self.name = name
        self.lat = lat
        self.lng = lng
        self.vicinity = vicinity
    }
}
