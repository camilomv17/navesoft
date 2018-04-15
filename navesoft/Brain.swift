//
//  Brain.swift
//  navesoft
//
//  Created by Camilo Mariño on 2/14/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import JSQMessagesViewController
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let BLUE_COLOR = UIColor(red:(0/255),green:(50/255),blue:(125/255),alpha:1.0)
let ULTRA_LIGHT_GRAY_COLOR = UIColor(red:(235/255),green:(235/255),blue:(235/255),alpha:1.0)
let SERVER_IP = "http://avizatcl.navesoft.com"
class Brain:NSObject{
    
    static var brain:Brain!
    var currentUser:User?
    var currentEvent:Event?
    var lastLocation:CLLocation?
    var serverIp:String?
    var serverCode:String?;
    var messagesQueue:NSMutableArray?
    
    var isSendingMessage:Bool?
    
    override init() {
        super.init()
        
        currentUser = DataManager.getSharedInstance()?.user
        currentEvent = DataManager.getSharedInstance()?.event
        serverIp = UserDefaults.standard.object(forKey: "serverIp") as? String
        serverCode = UserDefaults.standard.object(forKey: "serverCode") as? String;

        messagesQueue = NSMutableArray()
        isSendingMessage = false
        
    }
    
    static func sharedBrain()->Brain{
        if(brain==nil){
            brain = Brain()
        }
        return brain;
    }
    
    static func isIphone4()->Bool{
        let cs = UIScreen.main.bounds
        if(cs.height==480){
            return true
        }
        return false
    }
    
    func save(){
        DataManager.getSharedInstance()?.user = self.currentUser;
        DataManager.getSharedInstance()?.event = self.currentEvent;
        
        DataManager.getSharedInstance()?.save();
        
        let preferences = UserDefaults.standard
        
        let currentLevelKey = "serverIp"
        
        preferences.set(serverIp, forKey: currentLevelKey)
        preferences.set(serverCode, forKey: "serverCode");
        
        //  Save to disk
        let didSave = preferences.synchronize()
        
        if !didSave {
            //  Couldn't save (I've never seen this happen in real world testing)
        }

    }
    
    static func isValidContainer(_ container:String) -> Bool{
        let _c = container.uppercased()
        if(_c.characters.count != 11){
            return false;
        }
        
        let verDict = NSMutableDictionary()
        verDict.setValue(10, forKey: "A")
        verDict.setValue(12, forKey: "B")
        verDict.setValue(13, forKey: "C")
        verDict.setValue(14, forKey: "D")
        verDict.setValue(15, forKey: "E")
        verDict.setValue(16, forKey: "F")
        verDict.setValue(17, forKey: "G")
        verDict.setValue(18, forKey: "H")
        verDict.setValue(19, forKey: "I")
        verDict.setValue(20, forKey: "J")
        verDict.setValue(21, forKey: "K")
        verDict.setValue(23, forKey: "L")
        verDict.setValue(24, forKey: "M")
        verDict.setValue(25, forKey: "N")
        verDict.setValue(26, forKey: "O")
        verDict.setValue(27, forKey: "P")
        verDict.setValue(28, forKey: "Q")
        verDict.setValue(29, forKey: "R")
        verDict.setValue(30, forKey: "S")
        verDict.setValue(31, forKey: "T")
        verDict.setValue(32, forKey: "U")
        verDict.setValue(34, forKey: "V")
        verDict.setValue(35, forKey: "W")
        verDict.setValue(36, forKey: "X")
        verDict.setValue(37, forKey: "Y")
        verDict.setValue(38, forKey: "Z")
        
        let letters = CharacterSet.letters
        let digits = CharacterSet.decimalDigits
        var idx = 0
        var sum = 0.0
        var verification = ""
        for character in _c.unicodeScalars{
            
            if(idx<=3){
                if !letters.contains(UnicodeScalar(character.value)!){
                    return false;
                }
                else{
                    sum = sum + ((verDict.object(forKey: String(character)) as? Double)! * pow(2, Double(idx)))
                }
            }
            else{
                if !digits.contains(UnicodeScalar(character.value)!){
                    return false;
                }
                else{
                    if(idx <= 9){
                        sum = sum + (Double(String(character))! * pow(2, Double(idx)))
                    }
                    else{
                        verification = String(character)
                    }
                    
                }
            }
            idx = idx + 1
        }
        
        let firstDivision = sum / 11
        
        let integerPart = Int(firstDivision)
        
        let final = sum - Double(integerPart * 11)
        
        if(final - Double(verification)! != 0){
            return false
        }
        
        return true;
        
        
        
        
    }
    
    func addMessageToQueue(_ message:JSQMessage){
        messagesQueue?.addObject(message)
        startSendingMessages()
    }
    
    func startSendingMessages(){
        if(messagesQueue?.count>0){
            if(!isSendingMessage!){
                isSendingMessage = true
                sendNextMessage()
            }
        }
    }
    
    func sendNextMessage(){
        let next:JSQMessage = (messagesQueue?.objectAtIndex(0))! as! JSQMessage
        
        
        let request = NSMutableURLRequest(url: URL(string: "\(SERVER_IP)/api/call/sendMessage")!)
        request.httpMethod = "POST"
        let postString = "id=\((currentUser?.id)!)&message=\(next.text!)&eventId=\((currentEvent?._id)!)"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.dataUsingEncoding(String.Encoding.utf8)
        let length = CUnsignedLong((data?.length)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.HTTPBody = data

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8)
            print("responseString = \(responseString)")
            
            var error:NSError?
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                if(json.object(forKey: "status") as? String == "OK"){
                    self.messagesQueue?.removeObject(at: 0)
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "messageSent"), object: self)
                    if(self.messagesQueue?.count>0){
                        self.sendNextMessage()
                    }
                    else{
                        self.isSendingMessage = false
                    }
                }
                
                DispatchQueue.main.async(execute: {
                
                });
                
                
            }
            catch{
                print("FFUUUUUU")
            }
        }) 
        task.resume()
    }
}
