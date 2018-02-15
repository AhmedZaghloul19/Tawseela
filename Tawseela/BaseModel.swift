//
//  BaseModel.swift
//  CafeSupreme
//
//  Created by Ahmed on 8/23/17.
//  Copyright © 2017 RKAnjel. All rights reserved.
//

import Foundation
/**
 Base Model For All Models of the app.
 ````
 public var id : Int?
 public var name : String?
 public var image : String?
 ````
 
 - id: ID of the Object.
 - name: Name of the object.
 - image: Image Path (url) for the image of the object.
 
 ## Important Notes ##
 - Most of app models depends on this class
 - Most of app models contains **id,name,image**
 */
public class BaseModel {
    public var id : String?
    public var name : String?
    public var image : String?
        
    init(id:String,name:String,image:String) {
        self.id = id
        self.name = name
        self.image = image
    }
    
    init() {
        
    }
}
