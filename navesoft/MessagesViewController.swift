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
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(BLUE_COLOR)
    var messages = [JSQMessage]()

    var firstFetch:Bool?
    
    var timer:NSTimer?
    
    var lastCheck:Double?
    var isRequestingMessages:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        //automaticallyScrollsToMostRecentMessage = true
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
        navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "Mensajes"
        firstFetch = false
        lastCheck = 0;
        isRequestingMessages = false
        
    
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
   
        SwiftSpinner.setTitleFont(UIFont.systemFontOfSize(15))
        SwiftSpinner.show("Conectando...")
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Brain.sharedBrain().serverIp!)/api/call/getMessages")!)
        request.HTTPMethod = "POST"
        let postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&eventId=\((Brain.sharedBrain().currentEvent?._id)!)"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let length = CUnsignedLong((data?.length)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.HTTPBody = data
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            
            SwiftSpinner.hide()
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            var error:NSError?
            let newData = NSMutableArray()
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                let messages = json.objectForKey("messages") as! NSArray
                for element in messages {
                    let dict = element as! NSDictionary
                    let message = dict.objectForKey("mensaje") as! String
                    let isPatio = dict.objectForKey("isPatio") as! Bool
                    let time = ( dict.objectForKey("milliseconds") as! NSNumber).longLongValue
                    
                    
                    if(isPatio){
                        
                        let d = NSDate(timeIntervalSince1970: (Double(time/1000)))
                        let message = JSQMessage(senderId: "OTHER", senderDisplayName: "ADMIN", date: d, text: message)
                        newData.insertObject(message, atIndex: 0)
                    }
                    else{
                        let d = NSDate(timeIntervalSince1970: (Double(time/1000)))
                        let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: d, text: message)
                        
                        newData.insertObject(message, atIndex: 0)
                    }
                    

                }
                dispatch_async(dispatch_get_main_queue(), {

                self.messages = NSArray(array:newData) as! [JSQMessage]
                    self.finishSendingMessage()
                    self.firstFetch = true
                    self.lastCheck = NSDate().timeIntervalSince1970
                });
                
                SwiftSpinner.hide()
                
            }
            catch{
                print("FFUUUUUU")
            }
        }
        task.resume()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: #selector(MessagesViewController.getNewMessages), userInfo: nil, repeats: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.getNewMessages), name: "newMessage", object: Brain.sharedBrain())
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer?.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "newMessage", object: Brain.sharedBrain())
    }
    
    func getNewMessages(){
        
        if(isRequestingMessages!){
            return;
        }
        
        isRequestingMessages = true
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Brain.sharedBrain().serverIp!)/api/call/getNewMessages")!)
        request.HTTPMethod = "POST"
        let postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&eventId=\((Brain.sharedBrain().currentEvent?._id)!)&time=\((lastCheck!*1000))"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let length = CUnsignedLong((data?.length)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.HTTPBody = data
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            
            SwiftSpinner.hide()
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            var error:NSError?
            let newData = NSMutableArray(array: self.messages)
            var shouldPlaySound = false
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                let messages = json.objectForKey("messages") as! NSArray
                for element in messages {
                    let dict = element as! NSDictionary
                    let message = dict.objectForKey("mensaje") as! String
                    let isPatio = dict.objectForKey("isPatio") as! Bool
                    let time = ( dict.objectForKey("milliseconds") as! NSNumber).longLongValue
                    shouldPlaySound = true
                    
                    if(isPatio){
                        
                        let d = NSDate(timeIntervalSince1970: (Double(time/1000)))
                        let message = JSQMessage(senderId: "OTHER", senderDisplayName: "ADMIN", date: d, text: message)
                        newData.addObject(message)
                    }
                    else{
                        let d = NSDate(timeIntervalSince1970: (Double(time/1000)))
                        let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: d, text: message)
                        
                        newData.addObject(message)
                    }
                    
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.messages = NSArray(array:newData) as! [JSQMessage]
                    self.finishReceivingMessage()
                    self.lastCheck = NSDate().timeIntervalSince1970
                    
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
        }
        task.resume()

    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        
        
        
        messages+=[message]
        
        Brain.sharedBrain().addMessageToQueue(message)
        
        
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessageAnimated(true)
    }
    
    func reloadData(){
        self.collectionView.reloadData()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
    
    
    

    
    
}
