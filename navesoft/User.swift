//
//  User.swift
//  navesoft
//
//  Created by Camilo Mariño on 2/28/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation

class User: NSObject,NSCoding {
    var id:String?
    var cedula:String?
    var nombre:String?
    var celular:String?
    var placas:String?
    var tipo:String?
    var empresa:String?
    override init() {
        super.init()
    }
    
     required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        id = aDecoder.decodeObjectForKey("id") as? String
        cedula = aDecoder.decodeObjectForKey("cedula") as? String
        nombre = aDecoder.decodeObjectForKey("nombre") as? String
        celular = aDecoder.decodeObjectForKey("celular") as? String
        placas = aDecoder.decodeObjectForKey("placas") as? String
        tipo  = aDecoder.decodeObjectForKey("tipo") as? String
        empresa = aDecoder.decodeObjectForKey("empresa") as? String
        
    }
    
     func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(cedula, forKey: "cedula")
        aCoder.encodeObject(nombre, forKey: "nombre")
        aCoder.encodeObject(celular, forKey: "celular")
        aCoder.encodeObject(placas, forKey: "placas")
        aCoder.encodeObject(tipo, forKey: "tipo")
        aCoder.encodeObject(empresa, forKey: "empresa")
    }
}