//
//  Event.swift
//  navesoft
//
//  Created by Camilo Mariño on 3/6/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation

class Event:NSObject {
    
    var _id:String?
    var type:String?
    var trailer:String? //Booking o Contenedor, dependiendo del evento
    var tamano:String?
    var patio:String?
    var linea:String?
    var destino:String?
    var polyline:String?
    var averageSpeed:Double = 0
    var segundo:String?
    var secondConfirmation:Bool = false
    override init() {
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        _id = aDecoder.decodeObjectForKey("_id") as? String
        type = aDecoder.decodeObjectForKey("type") as? String
        trailer = aDecoder.decodeObjectForKey("trailer") as? String
        tamano = aDecoder.decodeObjectForKey("tamano") as? String
        patio = aDecoder.decodeObjectForKey("patio") as? String
        linea = aDecoder.decodeObjectForKey("linea") as? String
        destino = aDecoder.decodeObjectForKey("destino") as? String
        polyline = aDecoder.decodeObjectForKey("polyline") as? String
        averageSpeed = aDecoder.decodeDoubleForKey("averageSpeed")
        segundo = aDecoder.decodeObjectForKey("segundo") as? String
        secondConfirmation = aDecoder.decodeBoolForKey("secondConfirmation")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(_id, forKey: "_id")
        aCoder.encodeObject(type, forKey: "type")
        aCoder.encodeObject(trailer, forKey: "trailer")
        aCoder.encodeObject(tamano, forKey: "tamano")
        aCoder.encodeObject(patio, forKey: "patio")
        aCoder.encodeObject(linea, forKey: "linea")
        aCoder.encodeObject(destino, forKey: "destino")
        aCoder.encodeObject(polyline,forKey: "polyline")
        aCoder.encodeDouble(averageSpeed, forKey: "averageSpeed")
        aCoder.encodeObject(segundo,forKey: "segundo")
        aCoder.encodeBool(secondConfirmation, forKey: "secondConfirmation")
        
    }
}