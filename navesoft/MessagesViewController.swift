//
//  MessagesViewController.swift
//  navesoft
//
//  Created by Camilo Mariño on 5/22/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController
class MessagesViewController:JSQMessagesViewController{
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.lightGray)
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: BLUE_COLOR)
    var messages = [JSQMessage]()

    var firstFetch:Bool?
    
    var timer:Timer?
    
    var lastCheck:Double?
    var isRequestingMessages:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        //automaticallyScrollsToMostRecentMessage = true
        self.senderId = UIDevice.current.identifierForVendor?.uuidString
        self.senderDisplayName = UIDevice.current.identifierForVendor?.uuidString
        navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "Mensajes"
        firstFetch = false
        lastCheck = 0;
        isRequestingMessages = false
        
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
   
        SwiftSpinner.setTitleFont(UIFont.systemFont(ofSize: 15))
        SwiftSpinner.show("Conectando...")
        let request = NSMutableURLRequest(url: URL(string: "\(Brain.sharedBrain().serverIp!)/api/call/getMessages")!)
        request.httpMethod = "POST"
        let postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&eventId=\((Brain.sharedBrain().currentEvent?._id)!)"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.data(using: String.Encoding.utf8)
        let length = CUnsignedLong((data?.count)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            SwiftSpinner.hide()
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(responseString)")
            
            var error:NSError?
            let newData = NSMutableArray()
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                let messages = json.object(forKey: "messages") as! NSArray
                for element in messages {
                    let dict = element as! NSDictionary
                    let message = dict.object(forKey: "mensaje") as! String
                    let isPatio = dict.object(forKey: "isPatio") as! Bool
                    let time = ( dict.object(forKey: "milliseconds") as! NSNumber).int64Value
                    
                    
                    if(isPatio){
                        
                        let d = Date(timeIntervalSince1970: (Double(time/1000)))
                        let message = JSQMessage(senderId: "OTHER", senderDisplayName: "ADMIN", date: d, text: message)
                        newData.insert(message, at: 0)
                    }
                    else{
                        let d = Date(timeIntervalSince1970: (Double(time/1000)))
                        let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: d, text: message)
                        
                        newData.insert(message, at: 0)
                    }
                    

                }
                DispatchQueue.main.async(execute: {

                self.messages = NSArray(array:newData) as! [JSQMessage]
                    self.finishSendingMessage()
                    self.firstFetch = true
                    self.lastCheck = Date().timeIntervalSince1970
                });
                
                SwiftSpinner.hide()
                
            }
            catch{
                print("FFUUUUUU")
            }
        }) 
        task.resume()
        
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(MessagesViewController.getNewMessages), userInfo: nil, repeats: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.getNewMessages), name: NSNotification.Name(rawValue: "newMessage"), object: Brain.sharedBrain())
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessage"), object: Brain.sharedBrain())
    }
    
    func getNewMessages(){
        
        if(isRequestingMessages!){
            return;
        }
        
        isRequestingMessages = true
        let request = NSMutableURLRequest(url: URL(string: "\(Brain.sharedBrain().serverIp!)/api/call/getNewMessages")!)
        request.httpMethod = "POST"
        let postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&eventId=\((Brain.sharedBrain().currentEvent?._id)!)&time=\((lastCheck!*1000))"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.data(using: String.Encoding.utf8)
        let length = CUnsignedLong((data?.count)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            SwiftSpinner.hide()
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(responseString)")
            
            var error:NSError?
            let newData = NSMutableArray(array: self.messages)
            var shouldPlaySound = false
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                let messages = json.object(forKey: "messages") as! NSArray
                for element in messages {
                    let dict = element as! NSDictionary
                    let message = dict.object(forKey: "mensaje") as! String
                    let isPatio = dict.object(forKey: "isPatio") as! Bool
                    let time = ( dict.object(forKey: "milliseconds") as! NSNumber).int64Value
                    shouldPlaySound = true
                    
                    if(isPatio){
                        
                        let d = Date(timeIntervalSince1970: (Double(time/1000)))
                        let message = JSQMessage(senderId: "OTHER", senderDisplayName: "ADMIN", date: d, text: message)
                        newData.add(message)
                    }
                    else{
                        let d = Date(timeIntervalSince1970: (Double(time/1000)))
                        let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: d, text: message)
                        
                        newData.add(message)
                    }
                    
                    
                }
                DispatchQueue.main.async(execute: {
                    
                    self.messages = NSArray(array:newData) as! [JSQMessage]
                    self.finishReceivingMessage()
                    self.lastCheck = Date().timeIntervalSince1970
                    
                    self.isRequestingMessages = false
                    if(shouldPlaySound){
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                    
                });
                
                SwiftSpinner.hide()
                
            }
            catch{
                print("FFUUUUUU")
            }
        }) 
        task.resume()

    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        
        
        
        messages+=[message!]
        
        Brain.sharedBrain().addMessageToQueue(message!)
        
        
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage(animated: true)
    }
    
    func reloadData(){
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        self.messages.remove(at: indexPath.row)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
    }
    
    
    

    
    
}
