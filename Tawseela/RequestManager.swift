//
//  RequestManager.swift
//  CafeSupreme
//
//  Created by Ahmed on 8/21/17.
//  Copyright © 2017 RKAnjel. All rights reserved.
//

import Foundation

/**
 **Manager of all API Reqesuts**.
 ````
 static let defaultManager = RequestManager()
 private let requestTimourInterval = 20.0
 ````
 
 - defaultManager: Default manager to confirm singleton pattern.
 - requestTimourInterval: Maximum time taken for the request.
 
 ## Important Notes ##
 - This Class Confirms **Singleton Design Pattern**
 
 */
class RequestManager{
    static let defaultManager = RequestManager()
    private init (){}
    
    private let requestTimourInterval = 20.0

    /**
     Requesting the Places from Google Places the API.
     
     - Parameter long: User longitude.
     - Parameter lat: User latitude.
     - Parameter type: type for Query (Resturant,Cafe,... etc).
     
     ## Important Notes ##
     
     - Returns: A closure contain array of Type **GooglePlacesItem** and Boolean to determine if service returned success or not.
     
     */
    func getPlacesFromGoogle(long:Double,lat:Double,WithType type:String,compilition : @escaping (_ error : Bool,_ results:[GooglePlacesItem]?)->Void){

        let mutableURLRequest = NSMutableURLRequest(url: URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=500&type=\(type)&key=AIzaSyB6RXiyFyFljpeVl1SO1Vw1Ro0oazNBTBE")! ,
                                                    cachePolicy: .useProtocolCachePolicy,
                                                    timeoutInterval: requestTimourInterval)
        mutableURLRequest.setBodyConfigrationWithMethod(method: "GET")
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: mutableURLRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let res:HTTPURLResponse = response as? HTTPURLResponse {
                debugPrint(res.statusCode)
                if (error != nil || res.statusCode != 200) {
                    compilition(true, nil)
                    return
                } else {
                    let json: NSDictionary!
                    do {
                        json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! NSDictionary
                        debugPrint(json)
                    } catch {
                        compilition(true, nil)
                        return
                    }
                    
                    var searchResults:[GooglePlacesItem] = []
                    
                    if let response = json["results"] as? NSArray {
                        for res in response{
                            searchResults.append(GooglePlacesItem(data: res as AnyObject))
                        }
                            compilition(false,searchResults)
                    }else{
                        compilition(true, nil)
                    }
                }
            }else {
                compilition(true, nil)
            }
            
        })
        dataTask.resume()
    }

}
