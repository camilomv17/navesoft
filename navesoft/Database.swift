//
//  File.swift
//  Transconexiones
//
//  Created by Camilo Mariño on 11/8/15.
//  Copyright © 2015 Camilo Mariño. All rights reserved.
//

import Foundation

func pathForFile(_ filename:String) ->String?{
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(filename)
    return fileURL.path;
    
}

func loadData(_ filename:String) -> AnyObject?{
    let filePath = pathForFile(filename);
    let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!));
    if(data != nil){
    
    let unarchiver = NSKeyedUnarchiver(forReadingWith: data!);
    let retrieval = unarchiver.decodeObject(forKey: "data");
    
    unarchiver.finishDecoding()
    
    return retrieval as AnyObject;
    }
    else{ return nil}
    
}

func saveData(_ thedata:AnyObject,filename:String){
    let data = NSMutableData()
    
    let archiver = NSKeyedArchiver(forWritingWith: data);
    
    archiver.encode(thedata, forKey: "data");
    
    archiver.finishEncoding()
    
    data.write(toFile: pathForFile(filename)!, atomically: true);
    
}

