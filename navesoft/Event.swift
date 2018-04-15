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
        _id = aDecoder.decodeObject(forKey: "_id") as? String
        type = aDecoder.decodeObject(forKey: "type") as? String
        trailer = aDecoder.decodeObject(forKey: "trailer") as? String
        tamano = aDecoder.decodeObject(forKey: "tamano") as? String
        patio = aDecoder.decodeObject(forKey: "patio") as? String
        linea = aDecoder.decodeObject(forKey: "linea") as? String
        destino = aDecoder.decodeObject(forKey: "destino") as? String
        polyline = aDecoder.decodeObject(forKey: "polyline") as? String
        averageSpeed = aDecoder.decodeDouble(forKey: "averageSpeed")
        segundo = aDecoder.decodeObject(forKey: "segundo") as? String
        secondConfirmation = aDecoder.decodeBool(forKey: "secondConfirmation")
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(_id, forKey: "_id")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(trailer, forKey: "trailer")
        aCoder.encode(tamano, forKey: "tamano")
        aCoder.encode(patio, forKey: "patio")
        aCoder.encode(linea, forKey: "linea")
        aCoder.encode(destino, forKey: "destino")
        aCoder.encode(polyline,forKey: "polyline")
        aCoder.encode(averageSpeed, forKey: "averageSpeed")
        aCoder.encode(segundo,forKey: "segundo")
        aCoder.encode(secondConfirmation, forKey: "secondConfirmation")
        
    }
}
