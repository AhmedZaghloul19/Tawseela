//
//  Order.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/8/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import Foundation
class Order  {
    public var id:String?
    public var chat : [ChatMessage] = []
    public var date : String?
    public var del_address : String?
    public var del_lat : Float?
    public var del_lng : Float?
    public var driver_offers : [[String:Any]] = []
    public var driver_phone : String?
    public var order_details : [OrderDetails] = []
    public var pay : String?
    public var price : String?
    public var state : State?
    public var user_phone : String?
    public var requestedUser:User?
    
    init(data:AnyObject){
        if let data = data as? NSDictionary {
            self.date = data.getValueForKey(key: "date", callback: "")
            self.del_address = data.getValueForKey(key: "del_address", callback: "")
            let offers = data.getValueForKey(key: "driver_offers", callback: [[String:Any]()])
            for offer in offers {
                driver_offers.append(offer)
            }
            self.driver_phone = data.getValueForKey(key: "driver_phone", callback: "")
            self.price = data.getValueForKey(key: "price", callback: "")
            print(data.getValueForKey(key: "state", callback: "جاري الطلب"))
            self.state = State(rawValue: data.getValueForKey(key: "state", callback: "جاري الطلب"))
            self.user_phone = data.getValueForKey(key: "user_phone", callback: "")
//            self.order_details = OrderDetails(data: data.getValueForKey(key: "order_details", callback: [:]) as AnyObject)
            self.del_lat = data.getValueForKey(key: "del_lat", callback: 0.0)
            self.del_lng = data.getValueForKey(key: "del_lng", callback: 0.0)
        }
    }
}

class ChatMessage{
    var msg :String?
    var order:String?
    var senderPhone:String?
    
    init(data:AnyObject){
        if let data = data as? NSDictionary {
            self.msg = data.getValueForKey(key: "msg", callback: "")
            self.order = data.getValueForKey(key: "order", callback: "")
            self.senderPhone = data.getValueForKey(key: "phone", callback: "")
        }
    }
}

class OrderDetails : Codable{
    var address:String?
    var details:String?
    var lat:Float?
    var lng :Float?
    var name:String?
    
    init(data:AnyObject){
        if let data = data as? NSDictionary {
            print(data)
            self.address = data.getValueForKey(key: "address", callback: "")
            self.name = data.getValueForKey(key: "name", callback: "")
            self.details = data.getValueForKey(key: "details", callback: "")
            self.lat = data.getValueForKey(key: "lat", callback: 0.0)
            self.lng = data.getValueForKey(key: "lng", callback: 0.0)
        }
    }
    
    init() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.lat = aDecoder.decodeFloat(forKey: "lat")
        self.lng = aDecoder.decodeFloat(forKey: "lng")
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        self.address = aDecoder.decodeObject(forKey: "address") as? String ?? ""
        self.details = aDecoder.decodeObject(forKey: "details") as? String ?? ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lat, forKey: "lat")
        aCoder.encode(lng, forKey: "lng")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(details, forKey: "details")
    }
}
