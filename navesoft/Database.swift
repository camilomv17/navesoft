//
//  File.swift
//  Transconexiones
//
//  Created by Camilo Mariño on 11/8/15.
//  Copyright © 2015 Camilo Mariño. All rights reserved.
//

import Foundation

func pathForFile(filename:String) ->String?{
    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    let fileURL = documentsURL.URLByAppendingPathComponent(filename)
    return fileURL!.path;
    
}

func loadData(filename:String) -> AnyObject?{
    let filePath = pathForFile(filename);
    let data = NSData(contentsOfFile:filePath!);
    if(data != nil){
    
    let unarchiver = NSKeyedUnarchiver(forReadingWithData: data!);
    let retrieval = unarchiver.decodeObjectForKey("data");
    
    unarchiver.finishDecoding()
    
    return retrieval;
    }
    else{ return nil}
    
}

func saveData(thedata:AnyObject,filename:String){
    let data = NSMutableData()
    
    let archiver = NSKeyedArchiver(forWritingWithMutableData: data);
    
    archiver.encodeObject(thedata, forKey: "data");
    
    archiver.finishEncoding()
    
    data.writeToFile(pathForFile(filename)!, atomically: true);
    
}

