//
//  EventRegisterController.swift
//  navesoft
//
//  Created by Camilo Mariño on 2/14/16.
//  Copyright © 2016 Camilo Mariño. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import AEXML

class EventRegisterController:UIViewController,UINavigationBarDelegate {
    
    var pickUpView = UIView()
    var deliverRegisterView = UIView()
    var currentSelectedSegment = 0
    var patios:NSArray?
    var lineas:NSArray?
    override func viewDidLoad() {
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64)) // Offset by 20 pixels vertically to take the status bar into account
        
        navigationBar.backgroundColor = UIColor.whiteColor()
        navigationBar.delegate = self
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Registro"
        navigationBar.tintColor = BLUE_COLOR
        // Create left and right button for navigation item
        let rightButton =  UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(EventRegisterController.doneClicked(_:)))
        // Create two buttons for the navigation item
        navigationItem.rightBarButtonItem = rightButton
        
        let leftButton =  UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(EventRegisterController.cancelPressed(_:)))
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)

        
        self.view.backgroundColor = UIColor.whiteColor()
        
         let segmentedControl = UISegmentedControl (items: ["Retiro","Devolución"])
        segmentedControl.frame = CGRectMake(20, 74,self.view.bounds.size.width-40, 35)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(EventRegisterController.segmentedControlAction(_:)), forControlEvents: .ValueChanged)
        segmentedControl.tintColor = BLUE_COLOR
        self.view.addSubview(segmentedControl)
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        SwiftSpinner.setTitleFont(UIFont.systemFontOfSize(15))
        SwiftSpinner.show("Conectando...")
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Brain.sharedBrain().serverIp!)/api/call/getPatiosAndLines")!)
        request.HTTPMethod = "POST"
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            
            SwiftSpinner.hide()
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse  where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString!)")
            
            
          
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                let patios = json.objectForKey("patios") as! NSArray
                
                let lines = json.objectForKey("lines") as! NSArray
                
                self.pickUpView = PickUpRegisterView(frame: CGRectMake(0,110,self.view.bounds.size.width,self.view.bounds.size.height - 110),lines: lines,patios: patios)
                self.deliverRegisterView = DeliverRegisterView(frame: CGRectMake(0,110,self.view.bounds.size.width,self.view.bounds.size.height - 110),lines: lines,patios: patios)
                
                dispatch_async(dispatch_get_main_queue(), ({
                    self.view.addSubview(self.pickUpView)
                }));
                
               
                
                
                
                SwiftSpinner.hide()
                
            }
            catch{
                print("FFUUUUUU")
            }
        }
        task.resume()
        
    }
    
    func doneClicked(sender:AnyObject){
        self.view.endEditing(true);
        if(currentSelectedSegment == 0){
           let dict = (self.pickUpView as! PickUpRegisterView).fetchInfo()
            if(dict == nil){
                let alertController = UIAlertController(title: "Error", message: "Por favor complete todos los campos", preferredStyle: .Alert)
                
                // Initialize Actions
                let yesAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
                    
                }
                
                alertController.addAction(yesAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else{
                
                let booking = dict?.objectForKey("Booking") as? String
                let tamano = dict?.objectForKey("Tamano") as? String
                let linea = dict?.objectForKey("Linea") as? String
                let patio = dict?.objectForKey("Patio") as? String
                
                SwiftSpinner.setTitleFont(UIFont.systemFontOfSize(15))
                SwiftSpinner.show("Conectando...")
                
              
                
                let lastLocation:CLLocation = Brain.sharedBrain().lastLocation!
                
                let postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&booking=\(booking!)&tamano=\(tamano!)&line=\(linea!)&patio=\(patio!)&lat=\(lastLocation.coordinate.latitude)&lng=\(lastLocation.coordinate.longitude)";
                 self.checkValid(booking!, postString: postString, type: "E", params: dict)
                
            }
        }
        else{
            let dict = (self.deliverRegisterView as! DeliverRegisterView).fetchInfo()
            if(dict == nil){
                let alertController = UIAlertController(title: "Error", message: "Por favor complete todos los campos", preferredStyle: .Alert)
                
                // Initialize Actions
                let yesAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
                    print("The user is okay.")
                }
                
                alertController.addAction(yesAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else{
                let container = dict?.objectForKey("Contenedor") as? String
                let tamano = dict?.objectForKey("Tamano") as? String
                let linea = dict?.objectForKey("Linea") as? String
                let patio = dict?.objectForKey("Patio") as? String
                
                if(Brain.isValidContainer(container!) == false){
                    let alertController = UIAlertController(title: "Error", message: "El número del contenedor no es válido", preferredStyle: .Alert)
                    
                    // Initialize Actions
                    let yesAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
                    }
                    
                    alertController.addAction(yesAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return;
                }
                
                let segundo = dict?.objectForKey("Contenedor2") as? String
                
                if(segundo != nil){
                    if(Brain.isValidContainer(segundo!)==false){
                        let alertController = UIAlertController(title: "Error", message: "El número del contenedor 2 no es válido", preferredStyle: .Alert)
                        
                        // Initialize Actions
                        let yesAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
                        }
                        
                        alertController.addAction(yesAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        return;
                    }
                }
                SwiftSpinner.setTitleFont(UIFont.systemFontOfSize(15))
                SwiftSpinner.show("Conectando...")
                
                
                let lastLocation:CLLocation = Brain.sharedBrain().lastLocation!

                
                var postString = ""
                if(segundo != nil){
                     postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&container=\(container!)&line=\(linea!)&patio=\(patio!)&tamano=\(tamano!)&segundo=\(segundo!)&lat=\(lastLocation.coordinate.latitude)&lng=\(lastLocation.coordinate.longitude)";
                }
                else{
                     postString = "id=\((Brain.sharedBrain().currentUser?.id)!)&container=\(container!)&line=\(linea!)&patio=\(patio!)&tamano=\(tamano!)&lat=\(lastLocation.coordinate.latitude)&lng=\(lastLocation.coordinate.longitude)";

                }
                self.checkValid(container!, postString: postString, type: "I", params: dict)
                 //self.postDeliverEvent(postString, booking: container!, params: dict)
                
                

            }

        }
    }
    
    func postPickUpEvent(postString:String,params:NSDictionary?){
        SwiftSpinner.show("Conectando...")
        let booking = params?.objectForKey("Booking") as? String
        let linea = params?.objectForKey("Linea") as? String
        let patio = params?.objectForKey("Patio") as? String
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Brain.sharedBrain().serverIp!)/api/call/createPickUpEvent")!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = 25;
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let length = CUnsignedLong((data?.length)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.HTTPBody = data
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                SwiftSpinner.hide()
                self.showNetError();
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                SwiftSpinner.hide()
                self.showNetError()

                
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                let patioInfo = json.objectForKey("patio") as! NSDictionary
                
                let eventId = json.objectForKey("eventId") as! String
                
                let event = Event()
                event._id = eventId
                
                event.type = "pick"
                event.trailer = booking
                event.linea = linea
                event.patio = patio
                event.destino = patioInfo.objectForKey("position") as? String
                Brain.sharedBrain().currentEvent = event
                Brain.sharedBrain().save()
                
                SwiftSpinner.hide()
                dispatch_async(dispatch_get_main_queue(),{
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                });
                
                
            }
            catch{
                print("FFUUUUUU")
                SwiftSpinner.hide()
                self.showNetError()

            }
        }
        task.resume()
    }
    
    func postDeliverEvent(postString:String,params:NSDictionary?){
        let container = params?.objectForKey("Contenedor") as? String
        let linea = params?.objectForKey("Linea") as? String
        let patio = params?.objectForKey("Patio") as? String
        let segundo = params?.objectForKey("Contenedor2") as? String

        SwiftSpinner.show("Conectando...")
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Brain.sharedBrain().serverIp!)/api/call/createDeliverEvent")!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = 25;

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type")
        let data = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let length = CUnsignedLong((data?.length)!)
        request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
        request.HTTPBody = data
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                SwiftSpinner.hide()
                self.showNetError()
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                SwiftSpinner.hide()
                self.showNetError()
                return;
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                let patioInfo = json.objectForKey("patio") as! NSDictionary
                
                let eventId = json.objectForKey("eventId") as! String
                
                let event = Event()
                event._id = eventId
                
                event.type = "deliver"
                event.trailer = container
                event.linea = linea
                event.patio = patio
                event.segundo = segundo
                event.destino = patioInfo.objectForKey("position") as? String
                Brain.sharedBrain().currentEvent = event
                Brain.sharedBrain().save()
                
                SwiftSpinner.hide()
                dispatch_async(dispatch_get_main_queue(),{
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                });
                
                
            }
            catch{
                print("FFUUUUUU")
                SwiftSpinner.hide()

                self.showNetError()
            }
        }
        task.resume()
    }
    
    
    func segmentedControlAction(sender:UISegmentedControl){
        if(currentSelectedSegment == sender.selectedSegmentIndex){
            return
        }
        currentSelectedSegment = sender.selectedSegmentIndex
        if(currentSelectedSegment == 0){
            self.pickUpView.alpha = 0.0
                UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
                    self.deliverRegisterView.alpha = 0.0
                    
                    self.view.addSubview(self.pickUpView);
                    self.pickUpView.alpha = 1
                    }, completion: {(result:Bool) in self.deliverRegisterView.removeFromSuperview();})
        }
        else{
            self.deliverRegisterView.alpha = 0.0
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
                self.pickUpView.alpha = 0.0
                self.view.addSubview(self.deliverRegisterView);
                self.deliverRegisterView.alpha = 1
                }, completion: { (result:Bool) in self.pickUpView.removeFromSuperview(); })
        }
        
        
    }
    
    func cancelPressed(sender:AnyObject){
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkValid(booking:String,postString:String,type:String,params:NSDictionary?){
        
        var empresa:String?;
        var linea:String?;
        var patio:String?;
        var container:String?;
        
        if(type == "E"){
            empresa = Brain.sharedBrain().serverCode;
            linea = params?.objectForKey("Linea") as? String;
            patio = params?.objectForKey("patioCode") as? String;
            container = booking;
            
        }
        else{
            empresa = Brain.sharedBrain().serverCode;
            linea = params?.objectForKey("Linea") as? String;
            patio = params?.objectForKey("patioCode") as? String;
            
            if(params?.objectForKey("Contenedor2") != nil){
                container = "\((params?.objectForKey("Contenedor") as? String)!)_\((params?.objectForKey("Contenedor"))!)";
            }
            else{
                container = booking;
            }
        }
        
        var parameters:String = "http://190.242.124.185:7778/pls/csavchile/RES_API.get_res?parametro1=\(container!)&parametro2=\(empresa!)&parametro3=\(linea!)&parametro4=\(patio!)"
        parameters = parameters.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let url = NSURL(string: parameters);
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Current-Type");
        request.timeoutInterval = 25;

       // let data = postString.dataUsingEncoding(NSUTF8StringEncoding)
       // let length = CUnsignedLong((data?.length)!)
       // request.setValue(String(format: "%lu", arguments: [length]), forHTTPHeaderField: "Content-Length")
       // request.HTTPBody = data
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                SwiftSpinner.hide()
                self.showNetError()
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                SwiftSpinner.hide()

                self.showNetError()
                return;
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            do{
                SwiftSpinner.hide();
                let xmlDoc = try AEXMLDocument(xmlData: data!);
                
                let mensaje:String =  xmlDoc.root["mensaje"].value!;
                let flag:String = xmlDoc.root["flag"].value!;
                
                if(flag == "1"){
                    let alertController = UIAlertController(title: "Avizat", message: mensaje, preferredStyle: .Alert)
                    
                    // Initialize Actions
                        let yesAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
                            if(type=="I"){
                                self.postDeliverEvent(postString, params: params);
                            }
                            else if(type == "E"){
                                self.postPickUpEvent(postString, params: params);
                            }
                        
                    }
                        
                    
                    alertController.addAction(yesAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                    
                }
                
                else{
                    let alertController = UIAlertController(title: "Avizat", message: mensaje, preferredStyle: .Alert)
                    
                    // Initialize Actions
                    let yesAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
                        
                    }
                    
                    
                    alertController.addAction(yesAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                
                
                
            }
            catch{
                SwiftSpinner.hide()
                self.showNetError()
                print("FFUUUUUU")
            }
        }
        task.resume()

    }
    private func showNetError(){
        let alertController = UIAlertController(title: "Error", message: "No ha sido posible contactar al servidor", preferredStyle: .Alert)
        
        // Initialize Actions
        let yesAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
        }
        
        alertController.addAction(yesAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        return;

    }
}
