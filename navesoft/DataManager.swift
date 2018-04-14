//
//  DataManager.swift
//  Transconexiones
//
//  Created by Camilo Mariño on 11/8/15.
//  Copyright © 2015 Camilo Mariño. All rights reserved.
//

import Foundation

class DataManager: NSObject,NSCoding {
    static var sharedInstance:DataManager?
    var user:User?
    var event:Event?
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        user = aDecoder .decodeObjectForKey("user") as? User
        
        event = aDecoder.decodeObjectForKey("event") as? Event
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder .encodeObject(user, forKey: "user")
        aCoder.encodeObject(event, forKey: "event")

    }
    
    func synced(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
     static func getSharedInstance() -> DataManager?{
        if(sharedInstance == nil){
            sharedInstance = loadData("AvizaTState") as? DataManager
            
            if(sharedInstance == nil){
                sharedInstance = DataManager()
            }
        }
        return sharedInstance
    }
    
    func save(){
        saveData(self, filename: "AvizaTState")
    }
    
    
    
}