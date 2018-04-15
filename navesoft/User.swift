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
        id = aDecoder.decodeObject(forKey: "id") as? String
        cedula = aDecoder.decodeObject(forKey: "cedula") as? String
        nombre = aDecoder.decodeObject(forKey: "nombre") as? String
        celular = aDecoder.decodeObject(forKey: "celular") as? String
        placas = aDecoder.decodeObject(forKey: "placas") as? String
        tipo  = aDecoder.decodeObject(forKey: "tipo") as? String
        empresa = aDecoder.decodeObject(forKey: "empresa") as? String
        
    }
    
     func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(cedula, forKey: "cedula")
        aCoder.encode(nombre, forKey: "nombre")
        aCoder.encode(celular, forKey: "celular")
        aCoder.encode(placas, forKey: "placas")
        aCoder.encode(tipo, forKey: "tipo")
        aCoder.encode(empresa, forKey: "empresa")
    }
}
